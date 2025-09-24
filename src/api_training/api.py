"""Defines the FastAPI application and its endpoints."""

import os
import re
import time
from contextlib import asynccontextmanager

from fastapi import Depends, FastAPI, HTTPException
from pydantic import BaseModel
from roman_converter.V3roman_con import RomanNumeralConverter
from sqlalchemy.exc import OperationalError
from sqlalchemy.orm import Session

from api_training.database import Base, SessionLocal, engine
from api_training.models import Conversion


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Handle application lifespan events."""
    if os.getenv("ENV") != "test":
        retries = 5
        for i in range(retries):
            try:
                Base.metadata.create_all(bind=engine)
                print("✅ Database initialized")
                break
            except OperationalError:
                print(f"❌ DB not ready, retrying... ({i+1}/{retries})")
                time.sleep(5)
        else:
            raise RuntimeError("Could not connect to DB after several retries")
    yield


app = FastAPI(lifespan=lifespan)
converter = RomanNumeralConverter()  # Ensure this is initialized


# Dependency for getting DB session
def get_db():
    """Get a database session."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# Input schemas
class RomanRequest(BaseModel):
    """Request model for Roman to Arabic conversion."""

    roman: str


class ArabicRequest(BaseModel):
    """Request model for Arabic to Roman conversion."""

    arabic: int


# Endpoint 1: Convert Roman to Arabic
@app.post("/arabic")
def convert_to_arabic(data: RomanRequest, db: Session = Depends(get_db)):
    """Convert a Roman numeral to an Arabic numeral."""
    roman_upper = data.roman.upper()
    if not re.match(r"^[MDCLXVI]+$", roman_upper):
        raise HTTPException(
            status_code=400, detail="Invalid characters in Roman numeral"
        )
    try:
        result = converter.roman_to_arabic(roman_upper)
        entry = Conversion(
            input_value=roman_upper,
            output_value=str(result),
            direction="roman_to_arabic",
        )
        db.add(entry)
        db.commit()
        return {"roman": data.roman.upper(), "arabic": result}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except OperationalError:
        raise HTTPException(status_code=500, detail="Database temporarily unavailable")


# Endpoint 2: Convert Arabic to Roman
@app.post("/roman")
def convert_to_roman(data: ArabicRequest, db: Session = Depends(get_db)):
    """Convert an Arabic numeral to a Roman numeral."""
    try:
        result = converter.arabic_to_roman(data.arabic)
        entry = Conversion(
            input_value=str(data.arabic),
            output_value=result,
            direction="arabic_to_roman",
        )
        db.add(entry)
        db.commit()
        return {"arabic": data.arabic, "roman": result}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except OperationalError:
        raise HTTPException(status_code=500, detail="Database temporarily unavailable")
