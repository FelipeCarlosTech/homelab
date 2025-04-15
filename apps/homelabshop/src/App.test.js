import { render, screen } from '@testing-library/react';
import App from './App';

// Mocking react-router-dom
jest.mock('react-router-dom', () => ({
  BrowserRouter: ({ children }) => <div>{children}</div>,
  Routes: ({ children }) => <div>{children}</div>,
  Route: () => <div />,
  Link: ({ children }) => <div>{children}</div>,
}));

// Mocking components
jest.mock('./components/Navbar', () => () => <div data-testid="navbar">Navbar</div>);
jest.mock('./components/Footer', () => () => <div data-testid="footer">Footer</div>);

test('renders main app structure', () => {
  render(<App />);
  const navbarElement = screen.getByTestId('navbar');
  const footerElement = screen.getByTestId('footer');

  expect(navbarElement).toBeInTheDocument();
  expect(footerElement).toBeInTheDocument();
});
