class Validators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateFatherName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Father's Name is required";
    }
    if (value.trim().length < 2) {
      return "Father's Name must be at least 2 characters";
    }
    return null;
  }

  static String? validateAadhaar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Aadhaar Number is required';
    }
    final cleaned = value.trim();
    final aadhaarRegex = RegExp(r'^\d{12}$');
    if (!aadhaarRegex.hasMatch(cleaned)) {
      return 'Aadhaar must be exactly 12 digits without spaces';
    }
    return null;
  }
}
