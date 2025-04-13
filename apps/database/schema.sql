-- Crear tablas para la aplicación de e-commerce

-- Tabla de productos
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de clientes
CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de órdenes
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),
    total DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de items de orden (relación entre órdenes y productos)
CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- Insertar algunos datos de ejemplo
INSERT INTO products (name, description, price, stock, category) VALUES
('Laptop Pro', 'Potente laptop para desarrolladores', 1299.99, 10, 'Electronics'),
('Monitor 4K', 'Monitor de alta resolución', 349.99, 15, 'Electronics'),
('Teclado mecánico', 'Teclado para programadores', 129.99, 20, 'Accessories'),
('Mouse ergonómico', 'Mouse inalámbrico de alta precisión', 49.99, 30, 'Accessories');

INSERT INTO customers (name, email) VALUES
('Usuario Demo', 'user@example.com');
