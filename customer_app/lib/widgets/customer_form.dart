import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/validators.dart';

class CustomerForm extends StatefulWidget {
  final String? initialName;
  final String? initialFatherName;
  final String? initialAadhaar;
  final String submitButtonText;
  final bool isLoading;
  final Function(String name, String fatherName, String aadhaar) onSubmit;

  const CustomerForm({
    super.key,
    this.initialName,
    this.initialFatherName,
    this.initialAadhaar,
    required this.submitButtonText,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _fatherNameController;
  late TextEditingController _aadhaarController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _fatherNameController = TextEditingController(text: widget.initialFatherName ?? '');
    _aadhaarController = TextEditingController(text: widget.initialAadhaar ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _nameController.text.trim(),
        _fatherNameController.text.trim(),
        _aadhaarController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name input field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'e.g. Ramesh Kumar',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: Validators.validateName,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Father's Name input field
          TextFormField(
            controller: _fatherNameController,
            decoration: InputDecoration(
              labelText: "Father's Name",
              hintText: 'e.g. Suresh Kumar',
              prefixIcon: const Icon(Icons.family_restroom_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: Validators.validateFatherName,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Aadhaar Number input field (unmasked 12 digits, no spaces)
          TextFormField(
            controller: _aadhaarController,
            keyboardType: TextInputType.number,
            maxLength: 12,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
            ],
            decoration: InputDecoration(
              labelText: 'Aadhaar Number',
              hintText: 'Enter 12-digit Aadhaar number',
              prefixIcon: const Icon(Icons.badge_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              counterText: '',
            ),
            validator: Validators.validateAadhaar,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submitForm(),
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      widget.submitButtonText,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
