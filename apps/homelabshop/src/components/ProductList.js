import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Link } from 'react-router-dom';

function ProductList() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Aquí usamos una URL relativa que se resolverá con el ingress
    // En un entorno de desarrollo, configura proxy en package.json o usa una URL absoluta
    axios.get('/products')
      .then(response => {
        setProducts(response.data);
        setLoading(false);
      })
      .catch(err => {
        console.error('Error fetching products:', err);
        setError('Error al cargar los productos. Por favor, intente nuevamente.');
        setLoading(false);
      });
  }, []);

  if (loading) {
    return <div>Cargando productos...</div>;
  }

  if (error) {
    return <div>{error}</div>;
  }

  return (
    <div>
      <h1>Nuestros Productos</h1>

      <div className="products-grid">
        {products.map(product => (
          <div key={product.id} className="product-card">
            <h3>{product.name}</h3>
            <p>{product.description}</p>
            <p className="product-price">${product.price}</p>
            <p>Stock: {product.stock}</p>
            <Link to={`/products/${product.id}`} className="btn">Ver Detalles</Link>
          </div>
        ))}
      </div>
    </div>
  );
}

export default ProductList;
