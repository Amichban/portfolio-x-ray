"""
Pytest configuration and fixtures for test suite.
Copy to: apps/api/tests/conftest.py
"""
import os
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from starlette.testclient import TestClient

# Import your app and database models
# from src.main import app, get_db
# from src.database import Base

# Test database URL (use separate test DB)
TEST_DATABASE_URL = os.getenv(
    "TEST_DATABASE_URL",
    "postgresql://postgres:postgres@localhost:5432/test"
)

@pytest.fixture(scope="session")
def db_engine():
    """Create test database engine."""
    engine = create_engine(TEST_DATABASE_URL)
    # Base.metadata.create_all(engine)
    yield engine
    # Base.metadata.drop_all(engine)
    engine.dispose()

@pytest.fixture
def db_session(db_engine):
    """Create isolated database session for each test."""
    connection = db_engine.connect()
    transaction = connection.begin()
    Session = sessionmaker(bind=connection)
    session = Session()
    
    yield session
    
    session.close()
    transaction.rollback()
    connection.close()

@pytest.fixture
def client(db_session):
    """Create test client with mocked database."""
    def _get_db_override():
        try:
            yield db_session
        finally:
            pass
    
    # app.dependency_overrides[get_db] = _get_db_override
    
    # with TestClient(app) as test_client:
    #     yield test_client
    pass  # Uncomment above when app is available

@pytest.fixture
def auth_headers(client):
    """Create authenticated headers for protected routes."""
    # Create test user and login
    response = client.post("/auth/register", json={
        "email": "test@example.com",
        "password": "TestPass123!",
        "name": "Test User"
    })
    
    login_response = client.post("/auth/login", json={
        "email": "test@example.com",
        "password": "TestPass123!"
    })
    
    token = login_response.json()["token"]
    return {"Authorization": f"Bearer {token}"}