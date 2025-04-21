import React from 'react';
import { Link } from 'react-router-dom';

function Home() {
  return (
    <div>
      <h1>Bienvenido a HomelabShop</h1>
      <p>Esto es una prueba para YouTube</p>

      <div style={{ marginTop: '20px' }}>
        <Link to="/products" className="btn">Ver Productos</Link>
      </div>
    </div>
  );
}

export default Home;
