import urllib.request
import urllib.parse
import json

BASE_URL = "http://127.0.0.1:8000"

def make_request(url, method="GET", data=None):
    headers = {"Content-Type": "application/json"}
    encoded_data = json.dumps(data).encode("utf-8") if data else None
    req = urllib.request.Request(url, data=encoded_data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req) as resp:
            body = resp.read().decode("utf-8")
            return resp.status, json.loads(body) if body else {}
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8")
        return e.code, json.loads(body) if body else {}

def run_tests():
    print("--- TESTING API ENDPOINTS ---")
    
    # 1. Health check
    status_code, body = make_request(f"{BASE_URL}/")
    print(f"Health Check: {status_code} -> {body}")
    
    # 2. Add Customer
    customer_payload = {
        "name": "Ramesh Kumar",
        "father_name": "Suresh Kumar",
        "aadhaar_number": "987654321012"
    }
    status_code, new_customer = make_request(f"{BASE_URL}/customers", method="POST", data=customer_payload)
    print(f"Create Customer: {status_code} -> {new_customer}")
    assert status_code == 201, f"Expected 201, got {status_code}"
    customer_id = new_customer["customer_id"]
    assert new_customer["aadhaar_number"] == "987654321012", "Aadhaar must be unmasked 12 digits"

    # 3. Duplicate Aadhaar Rejection
    status_code, dup_resp = make_request(f"{BASE_URL}/customers", method="POST", data=customer_payload)
    print(f"Duplicate Aadhaar Check: {status_code} -> {dup_resp}")
    assert status_code == 400, f"Expected 400 for duplicate Aadhaar, got {status_code}"

    # 4. Search Customer by Name (Case-insensitive & Partial)
    status_code, search_results = make_request(f"{BASE_URL}/customers/search?name=ramesh")
    print(f"Search 'ramesh': {status_code} -> Found {len(search_results)} items")
    assert status_code == 200 and len(search_results) > 0

    # 5. Get Customer by ID
    status_code, fetched = make_request(f"{BASE_URL}/customers/{customer_id}")
    print(f"Get by ID: {status_code} -> {fetched['name']}")

    # 6. Update Customer
    update_payload = {"father_name": "Suresh Kumar Updated"}
    status_code, updated = make_request(f"{BASE_URL}/customers/{customer_id}", method="PUT", data=update_payload)
    print(f"Update Customer: {status_code} -> {updated['father_name']}")
    assert updated["father_name"] == "Suresh Kumar Updated"

    # 7. List Customers
    status_code, customer_list = make_request(f"{BASE_URL}/customers")
    print(f"List All Customers: {status_code} -> Total: {len(customer_list)}")

    # 8. Delete Customer
    status_code, deleted_resp = make_request(f"{BASE_URL}/customers/{customer_id}", method="DELETE")
    print(f"Delete Customer: {status_code} -> {deleted_resp}")
    assert status_code == 200

    # 9. Verify Ascending Order Sorting
    print("\n--- Ascending Order Sorting Test ---")
    u1 = {"name": "Zack", "father_name": "Father Z", "aadhaar_number": "100000000001"}
    u2 = {"name": "Alice", "father_name": "Father A", "aadhaar_number": "100000000002"}
    u3 = {"name": "Bob", "father_name": "Father B", "aadhaar_number": "100000000003"}
    
    id1 = make_request(f"{BASE_URL}/customers", "POST", u1)[1]["customer_id"]
    id2 = make_request(f"{BASE_URL}/customers", "POST", u2)[1]["customer_id"]
    id3 = make_request(f"{BASE_URL}/customers", "POST", u3)[1]["customer_id"]
    
    status_code, sorted_list = make_request(f"{BASE_URL}/customers?sort_by=name&order=asc")
    names = [c["name"] for c in sorted_list if c["customer_id"] in (id1, id2, id3)]
    print(f"Ascending Order returned: {names}")
    assert names == ["Alice", "Bob", "Zack"], f"Expected ['Alice', 'Bob', 'Zack'], got {names}"
    
    # Cleanup test records
    for cid in (id1, id2, id3):
        make_request(f"{BASE_URL}/customers/{cid}", method="DELETE")
    print("  --> PASS: Ascending Order Sorting verified successfully!")

    print("--- ALL BACKEND API TESTS PASSED PERFECTLY! ---")

if __name__ == "__main__":
    run_tests()
