from sqlalchemy import Column, Integer, String
from api_training.database import Base

class Conversion(Base):
    __tablename__ = "conversions"

    id = Column(Integer, primary_key=True, index=True)
    input_value = Column(String, nullable=False)
    output_value = Column(String, nullable=False)
    direction = Column(String, nullable=False)  # e.g., "roman_to_arabic" or "arabic_to_roman"