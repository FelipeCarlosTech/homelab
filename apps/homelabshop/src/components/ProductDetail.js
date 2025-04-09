import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import axios from 'axios';

function ProductDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [product, setProduct] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    axios.get(`/products/${id}`)
      .then(response => {
        setProduct(response.data);
        setLoading(false);
      })
      .catch(err => {
        console.error('Error fetching product details:', err);
        setError('Error al cargar los detalles del producto.');
        setLoading(false);
      });
  }, [id]);

  const handleOrder = () => {
    // Esta es una simplificación. En un caso real, tendrías un carrito de compras
    // y un flujo de checkout más completo.
    const orderData = {
      customer_id: 1, // Cliente demo
      items: [
        {
          product_id: product.id,
          quantity: 1
        }
      ]
    };

    axios.post('/orders', orderData)
      .then(response => {
        alert(`¡Pedido creado con éxito! ID de pedido: ${response.data.id}`);
        navigate('/orders');
      })
      .catch(err => {
        console.error('Error creating order:', err);
        alert('Error al crear el pedido. Por favor, intente nuevamente.');
      });
  };

  if (loading) {
    return <div>Cargando detalles del producto...</div>;
  }

  if (error || !product) {
    return <div>{error || 'Producto no encontrado'}</div>;
  }

  return (
    <div>
      <h1>Detalles del Producto</h1>

      <div className="product-detail">
        <div className="product-image">
          {/* Imagen de placeholder */}
          <div style={{
            backgroundColor: '#ddd',
            width: '100%',
            height: '300px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center'
          }}>
            Imagen del Producto
          </div>
        </div>

        <div className="product-info">
          <h2>{product.name}</h2>
          <p>{product.description}</p>
          <p className="product-price">${product.price}</p>
          <p>Stock: {product.stock}</p>
          <p>Categoría: {product.category}</p>

          <button className="btn" onClick={handleOrder} disabled={product.stock < 1}>
            {product.stock < 1 ? 'Sin Stock' : 'Comprar Ahora'}
          </button>
        </div>
      </div>
    </div>
  );
}

export default ProductDetail;
