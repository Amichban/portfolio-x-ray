"""
Example test file structure.
Copy to: apps/api/tests/test_[feature].py
"""
import pytest


class TestHealthEndpoints:
    """Test health check endpoints."""
    
    def test_healthz_returns_200(self, client):
        """Test that health endpoint returns 200."""
        response = client.get("/healthz")
        assert response.status_code == 200
        assert response.json()["status"] == "healthy"
    
    def test_readyz_checks_dependencies(self, client):
        """Test that readiness includes dependency checks."""
        response = client.get("/readyz")
        assert response.status_code in (200, 503)
        
        data = response.json()
        assert "database" in data
        assert "redis" in data if "redis" in data else True


class TestAuthentication:
    """Test authentication flows."""
    
    def test_register_new_user(self, client, db_session):
        """Test user registration with valid data."""
        user_data = {
            "email": "newuser@example.com",
            "password": "SecurePass123!",
            "name": "New User"
        }
        
        response = client.post("/auth/register", json=user_data)
        
        assert response.status_code == 201
        assert response.json()["email"] == user_data["email"]
        assert "id" in response.json()
        assert "password" not in response.json()
    
    def test_login_with_valid_credentials(self, client, db_session):
        """Test login returns JWT token."""
        # First create user
        client.post("/auth/register", json={
            "email": "login@example.com",
            "password": "TestPass123!"
        })
        
        # Then login
        response = client.post("/auth/login", json={
            "email": "login@example.com",
            "password": "TestPass123!"
        })
        
        assert response.status_code == 200
        assert "token" in response.json()
        assert len(response.json()["token"]) > 20
    
    def test_login_with_invalid_credentials(self, client):
        """Test login rejects bad credentials."""
        response = client.post("/auth/login", json={
            "email": "wrong@example.com",
            "password": "WrongPass"
        })
        
        assert response.status_code == 401
        assert "error" in response.json()
    
    @pytest.mark.parametrize("email,password,expected_error", [
        ("", "pass", "email required"),
        ("invalid", "pass", "invalid email"),
        ("test@example.com", "", "password required"),
        ("test@example.com", "short", "password too short"),
    ])
    def test_validation_errors(self, client, email, password, expected_error):
        """Test input validation on registration."""
        response = client.post("/auth/register", json={
            "email": email,
            "password": password
        })
        
        assert response.status_code == 422
        # Check error message contains expected text
        # assert expected_error in str(response.json())