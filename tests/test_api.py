"""Tests for the API endpoints."""

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from api_training.models import Conversion


def test_convert_to_arabic_success(client: TestClient):
    """Test successful conversion from Roman to Arabic."""
    response = client.post("/arabic", json={"roman": "XIV"})
    assert response.status_code == 200
    assert response.json() == {"roman": "XIV", "arabic": 14}


def test_convert_to_arabic_invalid_chars(client: TestClient):
    """Test conversion with invalid characters in the Roman numeral."""
    response = client.post("/arabic", json={"roman": "INVALID"})
    assert response.status_code == 400
    assert "Invalid characters in Roman numeral" in response.json()["detail"]


def test_convert_to_roman_success(client: TestClient):
    """Test successful conversion from Arabic to Roman."""
    response = client.post("/roman", json={"arabic": 14})
    assert response.status_code == 200
    assert response.json() == {"arabic": 14, "roman": "XIV"}


def test_convert_to_roman_out_of_range(client: TestClient):
    """Test conversion with an out-of-range Arabic numeral."""
    response = client.post("/roman", json={"arabic": 0})
    assert response.status_code == 400
    assert "Number out of range (must be 1..3999)" in response.json()["detail"]


def test_conversion_is_saved_to_db(client: TestClient, db_session: Session):
    """Test that a successful conversion is saved to the database."""
    response = client.post("/arabic", json={"roman": "C"})
    assert response.status_code == 200

    # Check that the conversion was saved
    conversion = db_session.query(Conversion).first()
    assert conversion is not None
    assert conversion.input_value == "C"
    assert conversion.output_value == "100"
    assert conversion.direction == "roman_to_arabic"
