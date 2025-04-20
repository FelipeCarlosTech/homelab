import React from 'react';
import { Link } from 'react-router-dom';

function Home() {
  return (
    <div>
      <h1>Bienvenido a HomelabShop</h1>
      <p>El mejor E-Commerce montado en un Homelab ☄️</p>

      <div style={{ marginTop: '20px' }}>
        <Link to="/products" className="btn">Ver Productos</Link>
      </div>
    </div>
  );
}

export default Home;
