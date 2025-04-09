import React, { useState, useEffect } from 'react';
import axios from 'axios';

function OrderList() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    axios.get('/orders')
      .then(response => {
        setOrders(response.data);
        setLoading(false);
      })
      .catch(err => {
        console.error('Error fetching orders:', err);
        setError('Error al cargar los pedidos. Por favor, intente nuevamente.');
        setLoading(false);
      });
  }, []);

  if (loading) {
    return <div>Cargando pedidos...</div>;
  }

  if (error) {
    return <div>{error}</div>;
  }

  return (
    <div>
      <h1>Mis Pedidos</h1>

      {orders.length === 0 ? (
        <p>No tienes pedidos todavía.</p>
      ) : (
        <div>
          {orders.map(order => (
            <div key={order.id} style={{
              marginBottom: '20px',
              padding: '15px',
              backgroundColor: '#fff',
              borderRadius: '8px',
              boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)'
            }}>
              <h3>Pedido #{order.id}</h3>
              <p>Estado: {order.status}</p>
              <p>Total: ${order.total}</p>
              <p>Fecha: {new Date(order.created_at).toLocaleDateString()}</p>

              <h4>Productos:</h4>
              <ul>
                {order.items.map(item => (
                  <li key={item.id}>
                    Producto #{item.product_id}: {item.quantity} x ${item.price} = ${item.total}
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default OrderList;
