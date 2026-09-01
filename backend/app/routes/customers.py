from uuid import UUID
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session
from app.database.connection import get_db
from app.schemas.customer import CustomerCreate, CustomerUpdate, CustomerOut
from app.services import customer_service

router = APIRouter(prefix="/customers", tags=["Customers"])

@router.post("", response_model=CustomerOut, status_code=status.HTTP_201_CREATED)
def create_customer_endpoint(customer_in: CustomerCreate, db: Session = Depends(get_db)):
    """Create a new customer record"""
    return customer_service.create_customer(db=db, customer_in=customer_in)

@router.get("/search", response_model=list[CustomerOut])
def search_customers_endpoint(
    name: str = Query(..., min_length=1, description="Name search query"),
    sort_by: str = Query("name", description="Field to sort by (name, created_at, aadhaar_number)"),
    order: str = Query("asc", description="Sort direction (asc or desc)"),
    db: Session = Depends(get_db)
):
    """Search customers by partial name (case-insensitive)"""
    return customer_service.search_customers_by_name(db=db, name=name, sort_by=sort_by, order=order)

@router.get("/{customer_id}", response_model=CustomerOut)
def get_customer_endpoint(customer_id: UUID, db: Session = Depends(get_db)):
    """Get single customer details by UUID"""
    return customer_service.get_customer_by_id(db=db, customer_id=customer_id)

@router.put("/{customer_id}", response_model=CustomerOut)
def update_customer_endpoint(customer_id: UUID, customer_in: CustomerUpdate, db: Session = Depends(get_db)):
    """Update existing customer details"""
    return customer_service.update_customer(db=db, customer_id=customer_id, customer_in=customer_in)

@router.delete("/{customer_id}", status_code=status.HTTP_200_OK)
def delete_customer_endpoint(customer_id: UUID, db: Session = Depends(get_db)):
    """Delete customer record"""
    return customer_service.delete_customer(db=db, customer_id=customer_id)

@router.get("", response_model=list[CustomerOut])
def list_customers_endpoint(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    sort_by: str = Query("name", description="Field to sort by (name, created_at, aadhaar_number)"),
    order: str = Query("asc", description="Sort direction (asc or desc)"),
    db: Session = Depends(get_db)
):
    """List all customers with pagination"""
    return customer_service.list_customers(db=db, skip=skip, limit=limit, sort_by=sort_by, order=order)
