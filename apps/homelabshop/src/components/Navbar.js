import React from 'react';
import { Link } from 'react-router-dom';

function Navbar() {
  return (
    <header className="header">
      <div className="container">
        <h1>HomelabShop</h1>
        <nav>
          <ul className="nav-links">
            <li><Link to="/">Home</Link></li>
            <li><Link to="/products">Products</Link></li>
            <li><Link to="/orders">Orders</Link></li>
          </ul>
        </nav>
      </div>
    </header>
  );
}

export default Navbar;
