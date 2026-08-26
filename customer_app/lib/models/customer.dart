class Customer {
  final String customerId;
  final String name;
  final String fatherName;
  final String aadhaarNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.customerId,
    required this.name,
    required this.fatherName,
    required this.aadhaarNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customer_id'] ?? '',
      name: json['name'] ?? '',
      fatherName: json['father_name'] ?? '',
      aadhaarNumber: json['aadhaar_number'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'name': name,
      'father_name': fatherName,
      'aadhaar_number': aadhaarNumber,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'father_name': fatherName,
      'aadhaar_number': aadhaarNumber,
    };
  }
}
