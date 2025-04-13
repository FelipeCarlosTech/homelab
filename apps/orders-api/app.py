from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from prometheus_flask_exporter import PrometheusMetrics
import os
import requests

app = Flask(__name__)

# Configuración de base de datos desde variables de entorno
db_user = os.environ.get("DB_USER", "ecommerce_user")
db_password = os.environ.get("DB_PASSWORD", "change_me_in_production")
db_host = os.environ.get("DB_HOST", "postgresql.databases.svc.cluster.local")
db_name = os.environ.get("DB_NAME", "ecommerce")
products_api_url = os.environ.get("PRODUCTS_API_URL", "http://products-api")

app.config["SQLALCHEMY_DATABASE_URI"] = (
    f"postgresql://{db_user}:{db_password}@{db_host}/{db_name}"
)
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

# Inicializar extensiones
db = SQLAlchemy(app)
metrics = PrometheusMetrics(app)


# Definir modelos
class Customer(db.Model):
    __tablename__ = "customers"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), nullable=False, unique=True)
    created_at = db.Column(db.DateTime, server_default=db.func.current_timestamp())

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "email": self.email,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }


class Order(db.Model):
    __tablename__ = "orders"

    id = db.Column(db.Integer, primary_key=True)
    customer_id = db.Column(db.Integer, db.ForeignKey("customers.id"))
    total = db.Column(db.Numeric(10, 2), nullable=False)
    status = db.Column(db.String(20), default="pending")
    created_at = db.Column(db.DateTime, server_default=db.func.current_timestamp())

    items = db.relationship("OrderItem", backref="order", lazy=True)

    def to_dict(self):
        return {
            "id": self.id,
            "customer_id": self.customer_id,
            "total": float(self.total),
            "status": self.status,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "items": [item.to_dict() for item in self.items],
        }


class OrderItem(db.Model):
    __tablename__ = "order_items"

    id = db.Column(db.Integer, primary_key=True)
    order_id = db.Column(db.Integer, db.ForeignKey("orders.id"))
    product_id = db.Column(db.Integer)
    quantity = db.Column(db.Integer, nullable=False)
    price = db.Column(db.Numeric(10, 2), nullable=False)

    def to_dict(self):
        return {
            "id": self.id,
            "order_id": self.order_id,
            "product_id": self.product_id,
            "quantity": self.quantity,
            "price": float(self.price),
            "total": float(self.price) * self.quantity,
        }

@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    return response

# Rutas
@app.route("/health")
def health():
    return jsonify({"status": "ok"})


@app.route("/orders")
def get_orders():
    try:
        orders = Order.query.all()
        return jsonify([order.to_dict() for order in orders])
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/orders/<int:order_id>")
def get_order(order_id):
    try:
        order = Order.query.get(order_id)
        if order:
            return jsonify(order.to_dict())
        return jsonify({"error": "Order not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/orders", methods=["POST"])
def create_order():
    try:
        data = request.json
        customer_id = data.get("customer_id")
        items = data.get("items", [])

        # Validar customer
        customer = Customer.query.get(customer_id)
        if not customer:
            return jsonify({"error": "Customer not found"}), 404

        # Validar productos y calcular total
        total = 0
        for item in items:
            # Consultar el producto en la API de productos
            product_id = item.get("product_id")
            quantity = item.get("quantity", 1)

            try:
                response = requests.get(f"{products_api_url}/products/{product_id}")
                if response.status_code != 200:
                    return jsonify({"error": f"Product {product_id} not found"}), 400

                product = response.json()
                if product["stock"] < quantity:
                    return jsonify(
                        {"error": f"Not enough stock for product {product_id}"}
                    ), 400

                item["price"] = product["price"]
                total += product["price"] * quantity

            except requests.RequestException as e:
                return jsonify(
                    {"error": f"Error accessing products API: {str(e)}"}
                ), 500

        # Crear orden
        order = Order(customer_id=customer_id, total=total, status="pending")
        db.session.add(order)
        db.session.flush()  # Para obtener el ID de la orden

        # Crear items de la orden
        for item in items:
            order_item = OrderItem(
                order_id=order.id,
                product_id=item["product_id"],
                quantity=item["quantity"],
                price=item["price"],
            )
            db.session.add(order_item)

        db.session.commit()
        return jsonify(order.to_dict()), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
