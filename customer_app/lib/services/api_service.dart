import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/customer.dart';

class ApiService {
  // Production FastAPI Backend deployed on Render (connected to Neon PostgreSQL)
  static String baseUrl = 'https://customer-management-app-b2ul.onrender.com';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Add customer
  static Future<Customer> createCustomer({
    required String name,
    required String fatherName,
    required String aadhaarNumber,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/customers'),
      headers: _headers,
      body: jsonEncode({
        'name': name.trim(),
        'father_name': fatherName.trim(),
        'aadhaar_number': aadhaarNumber.trim(),
      }),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return Customer.fromJson(responseData);
    } else {
      final errorMessage = responseData['detail'] ?? 'Failed to add customer';
      throw Exception(errorMessage);
    }
  }

  // Search customers by name
  static Future<List<Customer>> searchCustomers(String name, {String sortBy = 'name', String order = 'asc'}) async {
    final encodedName = Uri.encodeComponent(name.trim());
    final response = await http.get(
      Uri.parse('$baseUrl/customers/search?name=$encodedName&sort_by=$sortBy&order=$order'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      final customers = list.map((item) => Customer.fromJson(item)).toList();
      customers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return customers;
    } else {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['detail'] ?? 'Search failed');
    }
  }

  // Get single customer details
  static Future<Customer> getCustomerDetails(String customerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/customers/$customerId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return Customer.fromJson(jsonDecode(response.body));
    } else {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['detail'] ?? 'Customer not found');
    }
  }

  // Update customer
  static Future<Customer> updateCustomer(
    String customerId, {
    String? name,
    String? fatherName,
    String? aadhaarNumber,
  }) async {
    final Map<String, dynamic> updateData = {};
    if (name != null) updateData['name'] = name.trim();
    if (fatherName != null) updateData['father_name'] = fatherName.trim();
    if (aadhaarNumber != null) updateData['aadhaar_number'] = aadhaarNumber.trim();

    final response = await http.put(
      Uri.parse('$baseUrl/customers/$customerId'),
      headers: _headers,
      body: jsonEncode(updateData),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return Customer.fromJson(responseData);
    } else {
      throw Exception(responseData['detail'] ?? 'Failed to update customer');
    }
  }

  // Delete customer
  static Future<void> deleteCustomer(String customerId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/customers/$customerId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['detail'] ?? 'Failed to delete customer');
    }
  }

  // Fetch all customers (paginated)
  static Future<List<Customer>> fetchAllCustomers({int skip = 0, int limit = 100, String sortBy = 'name', String order = 'asc'}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/customers?skip=$skip&limit=$limit&sort_by=$sortBy&order=$order'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      final customers = list.map((item) => Customer.fromJson(item)).toList();
      customers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return customers;
    } else {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['detail'] ?? 'Failed to fetch customer list');
    }
  }
}
