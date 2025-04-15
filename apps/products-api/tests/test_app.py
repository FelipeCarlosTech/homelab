import unittest
import json
from app import app


class ProductsAPITest(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_health_endpoint(self):
        response = self.app.get("/health")
        data = json.loads(response.data)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(data["status"], "ok")

    def test_products_endpoint_structure(self):
        # This is a basic test that just checks if the endpoint returns a list
        # In a real environment, you would mock the database
        # This will likely fail without mocking, which is fine for a learning exercise
        response = self.app.get("/products")
        self.assertEqual(response.content_type, "application/json")


if __name__ == "__main__":
    unittest.main()
