from uuid import UUID
from datetime import datetime
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.customer import Customer
from app.schemas.customer import CustomerCreate, CustomerUpdate

def create_customer(db: Session, customer_in: CustomerCreate) -> Customer:
    # Check for duplicate Aadhaar
    existing = db.query(Customer).filter(Customer.aadhaar_number == customer_in.aadhaar_number).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A customer with this Aadhaar number already exists"
        )
    
    db_customer = Customer(
        name=customer_in.name,
        father_name=customer_in.father_name,
        aadhaar_number=customer_in.aadhaar_number
    )
    db.add(db_customer)
    db.commit()
    db.refresh(db_customer)
    return db_customer

def get_customer_by_id(db: Session, customer_id: UUID) -> Customer:
    customer = db.query(Customer).filter(Customer.customer_id == customer_id).first()
    if not customer:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Customer not found"
        )
    return customer

def search_customers_by_name(db: Session, name: str) -> list[Customer]:
    if not name or not name.strip():
        return []
    cleaned_name = name.strip()
    return db.query(Customer).filter(Customer.name.ilike(f"%{cleaned_name}%")).all()

def update_customer(db: Session, customer_id: UUID, customer_in: CustomerUpdate) -> Customer:
    customer = get_customer_by_id(db, customer_id)
    
    if customer_in.aadhaar_number and customer_in.aadhaar_number != customer.aadhaar_number:
        # Check duplicate for new Aadhaar
        duplicate = db.query(Customer).filter(Customer.aadhaar_number == customer_in.aadhaar_number).first()
        if duplicate:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="A customer with this Aadhaar number already exists"
            )
        customer.aadhaar_number = customer_in.aadhaar_number
        
    if customer_in.name is not None:
        customer.name = customer_in.name
    if customer_in.father_name is not None:
        customer.father_name = customer_in.father_name
        
    customer.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(customer)
    return customer

def delete_customer(db: Session, customer_id: UUID) -> dict:
    customer = get_customer_by_id(db, customer_id)
    db.delete(customer)
    db.commit()
    return {"message": "Customer deleted successfully", "customer_id": str(customer_id)}

def list_customers(db: Session, skip: int = 0, limit: int = 100) -> list[Customer]:
    return db.query(Customer).offset(skip).limit(limit).all()
