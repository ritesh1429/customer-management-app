import re
from uuid import UUID
from datetime import datetime
from pydantic import BaseModel, Field, field_validator

class CustomerBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=150, description="Customer Name")
    father_name: str = Field(..., min_length=1, max_length=150, description="Father's Name")
    aadhaar_number: str = Field(..., description="12-digit Aadhaar Number without spaces")

    @field_validator("name", "father_name")
    @classmethod
    def validate_non_empty(cls, value: str) -> str:
        cleaned = value.strip()
        if not cleaned:
            raise ValueError("Field cannot be blank or contain only whitespace")
        return cleaned

    @field_validator("aadhaar_number")
    @classmethod
    def validate_aadhaar(cls, value: str) -> str:
        # Strip any accidental leading/trailing whitespace
        cleaned = value.strip()
        # Strictly 12 digits, no spaces
        if not re.match(r"^\d{12}$", cleaned):
            raise ValueError("Aadhaar number must be exactly 12 numeric digits without spaces or special characters")
        return cleaned

class CustomerCreate(CustomerBase):
    pass

class CustomerUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=150)
    father_name: str | None = Field(None, min_length=1, max_length=150)
    aadhaar_number: str | None = Field(None)

    @field_validator("name", "father_name")
    @classmethod
    def validate_non_empty(cls, value: str | None) -> str | None:
        if value is not None:
            cleaned = value.strip()
            if not cleaned:
                raise ValueError("Field cannot be blank or contain only whitespace")
            return cleaned
        return value

    @field_validator("aadhaar_number")
    @classmethod
    def validate_aadhaar(cls, value: str | None) -> str | None:
        if value is not None:
            cleaned = value.strip()
            if not re.match(r"^\d{12}$", cleaned):
                raise ValueError("Aadhaar number must be exactly 12 numeric digits without spaces")
            return cleaned
        return value

class CustomerOut(CustomerBase):
    customer_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
