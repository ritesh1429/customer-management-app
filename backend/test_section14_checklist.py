import urllib.request
import urllib.parse
import json
import uuid

BASE_URL = "http://127.0.0.1:8000"

def make_request(url, method="GET", data=None):
    headers = {"Content-Type": "application/json"}
    encoded_data = json.dumps(data).encode("utf-8") if data is not None else None
    req = urllib.request.Request(url, data=encoded_data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req) as resp:
            body = resp.read().decode("utf-8")
            return resp.status, json.loads(body) if body else {}
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8")
        return e.code, json.loads(body) if body else {}

def run_section_14_checklist():
    print("\n=======================================================")
    print("   RUNNING SECTION 14 TESTING CHECKLIST SUITE          ")
    print("=======================================================\n")
    
    created_customer_ids = []

    try:
        # TEST 1: Add Valid Customer
        print("[TEST 1] Add Valid Customer...")
        payload1 = {
            "name": "Ramesh Kumar",
            "father_name": "Suresh Kumar",
            "aadhaar_number": "111122223333"
        }
        status, res = make_request(f"{BASE_URL}/customers", "POST", payload1)
        assert status == 201, f"Failed: expected 201, got {status}"
        assert res["name"] == "Ramesh Kumar"
        assert res["aadhaar_number"] == "111122223333"
        c1_id = res["customer_id"]
        created_customer_ids.append(c1_id)
        print("  --> PASS: Customer added successfully with ID", c1_id)

        # TEST 2: Reject Empty Fields
        print("\n[TEST 2] Reject Empty Fields...")
        empty_payloads = [
            {"name": "   ", "father_name": "Suresh Kumar", "aadhaar_number": "222233334444"},
            {"name": "Ramesh", "father_name": "", "aadhaar_number": "222233334444"},
            {"name": "Ramesh", "father_name": "Suresh", "aadhaar_number": ""}
        ]
        for idx, emp_p in enumerate(empty_payloads, 1):
            status, res = make_request(f"{BASE_URL}/customers", "POST", emp_p)
            assert status == 422, f"Failed empty field subtest {idx}: expected 422, got {status}"
        print("  --> PASS: Rejected empty fields (422 Unprocessable Entity)")

        # TEST 3: Reject Invalid Aadhaar Format
        print("\n[TEST 3] Reject Invalid Aadhaar (wrong length, spaces, letters)...")
        invalid_aadhaars = [
            "12345",              # Too short (5 digits)
            "12345678901234",     # Too long (14 digits)
            "1234 5678 9012",     # Contains spaces
            "12345678901A",       # Contains letters
        ]
        for idx, inv_a in enumerate(invalid_aadhaars, 1):
            inv_p = {"name": "Test User", "father_name": "Father User", "aadhaar_number": inv_a}
            status, res = make_request(f"{BASE_URL}/customers", "POST", inv_p)
            assert status == 422, f"Failed invalid Aadhaar subtest {idx} for '{inv_a}': expected 422, got {status}"
        print("  --> PASS: Rejected invalid Aadhaar formats")

        # TEST 4: Reject Duplicate Aadhaar
        print("\n[TEST 4] Reject Duplicate Aadhaar...")
        dup_payload = {
            "name": "Different Name",
            "father_name": "Different Father",
            "aadhaar_number": "111122223333"  # Same as c1
        }
        status, res = make_request(f"{BASE_URL}/customers", "POST", dup_payload)
        assert status == 400, f"Failed: expected 400 for duplicate Aadhaar, got {status}"
        assert "already exists" in res["detail"].lower()
        print("  --> PASS: Rejected duplicate Aadhaar (400 Bad Request)")

        # TEST 5: Search Exact Name
        print("\n[TEST 5] Search Exact Name...")
        status, res = make_request(f"{BASE_URL}/customers/search?name=Ramesh%20Kumar")
        assert status == 200 and len(res) >= 1
        assert any(c["customer_id"] == c1_id for c in res)
        print(f"  --> PASS: Found exact name match ({len(res)} record(s))")

        # TEST 6: Search Partial Name
        print("\n[TEST 6] Search Partial Name ('Ramesh')...")
        status, res = make_request(f"{BASE_URL}/customers/search?name=Ramesh")
        assert status == 200 and len(res) >= 1
        assert any(c["customer_id"] == c1_id for c in res)
        print(f"  --> PASS: Found partial name match ({len(res)} record(s))")

        # TEST 7: Case-Insensitive Search
        print("\n[TEST 7] Case-Insensitive Search ('rAmEsH')...")
        status, res = make_request(f"{BASE_URL}/customers/search?name=rAmEsH")
        assert status == 200 and len(res) >= 1
        assert any(c["customer_id"] == c1_id for c in res)
        print(f"  --> PASS: Case-insensitive search works correctly")

        # TEST 8: Handle Multiple Customers with Same Name
        print("\n[TEST 8] Handle Multiple Customers with Same Name...")
        payload2 = {
            "name": "Ramesh Kumar",  # Same name
            "father_name": "Mahesh Kumar", # Different father
            "aadhaar_number": "555566667777" # Different Aadhaar
        }
        status, res2 = make_request(f"{BASE_URL}/customers", "POST", payload2)
        assert status == 201
        c2_id = res2["customer_id"]
        created_customer_ids.append(c2_id)

        status, same_name_results = make_request(f"{BASE_URL}/customers/search?name=Ramesh%20Kumar")
        assert status == 200 and len(same_name_results) >= 2
        print(f"  --> PASS: Correctly handled {len(same_name_results)} customers with identical name 'Ramesh Kumar'")

        # TEST 9: View Customer Details
        print("\n[TEST 9] View Customer Details...")
        status, detail = make_request(f"{BASE_URL}/customers/{c1_id}")
        assert status == 200
        assert detail["name"] == "Ramesh Kumar"
        assert detail["aadhaar_number"] == "111122223333"
        print("  --> PASS: Retrieved full details for customer")

        # TEST 10: Update Customer Name
        print("\n[TEST 10] Update Customer Name...")
        status, updated = make_request(f"{BASE_URL}/customers/{c1_id}", "PUT", {"name": "Ramesh Kumar Singh"})
        assert status == 200 and updated["name"] == "Ramesh Kumar Singh"
        print("  --> PASS: Updated customer name")

        # TEST 11: Update Father's Name
        print("\n[TEST 11] Update Father's Name...")
        status, updated = make_request(f"{BASE_URL}/customers/{c1_id}", "PUT", {"father_name": "Suresh Kumar Senior"})
        assert status == 200 and updated["father_name"] == "Suresh Kumar Senior"
        print("  --> PASS: Updated father's name")

        # TEST 12: Update Aadhaar Number
        print("\n[TEST 12] Update Aadhaar Number...")
        status, updated = make_request(f"{BASE_URL}/customers/{c1_id}", "PUT", {"aadhaar_number": "999988887777"})
        assert status == 200 and updated["aadhaar_number"] == "999988887777"
        print("  --> PASS: Updated Aadhaar number")

        # TEST 13: Handle Customer-Not-Found (404)
        print("\n[TEST 13] Handle Customer-Not-Found (404)...")
        fake_uuid = str(uuid.uuid4())
        status, res = make_request(f"{BASE_URL}/customers/{fake_uuid}")
        assert status == 404
        assert "not found" in res["detail"].lower()
        print("  --> PASS: Handled non-existent customer ID with 404 Not Found")

        # TEST 14: Delete Customer with Confirmation
        print("\n[TEST 14] Delete Customer Endpoint...")
        status, del_res = make_request(f"{BASE_URL}/customers/{c1_id}", "DELETE")
        assert status == 200
        # Verify it's gone
        status, _ = make_request(f"{BASE_URL}/customers/{c1_id}")
        assert status == 404
        created_customer_ids.remove(c1_id)
        print("  --> PASS: Successfully deleted customer record")

        # TEST 15: List Customers with Pagination
        print("\n[TEST 15] List Customers with Pagination...")
        status, customer_list = make_request(f"{BASE_URL}/customers?skip=0&limit=10")
        assert status == 200 and isinstance(customer_list, list)
        print(f"  --> PASS: Paginated listing retrieved {len(customer_list)} records")

    finally:
        # Cleanup remaining created test records
        for cid in created_customer_ids:
            make_request(f"{BASE_URL}/customers/{cid}", "DELETE")

    print("=======================================================")
    print("   ALL 15 SECTION 14 CHECKLIST TEST CASES PASSED SUCCESSFULLY!")
    print("=======================================================\n")

if __name__ == "__main__":
    run_section_14_checklist()
