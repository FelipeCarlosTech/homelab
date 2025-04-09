import React from 'react';

function Footer() {
  return (
    <footer className="footer">
      <div className="container">
        <p>&copy; {new Date().getFullYear()} HomelabShop - Proyecto para Homelab</p>
      </div>
    </footer>
  );
}

export default Footer;
