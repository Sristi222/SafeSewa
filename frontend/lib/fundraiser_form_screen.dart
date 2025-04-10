import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FundraiserFormScreen extends StatefulWidget {
  const FundraiserFormScreen({Key? key}) : super(key: key);

  @override
  _FundraiserFormScreenState createState() => _FundraiserFormScreenState();
}

class _FundraiserFormScreenState extends State<FundraiserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  bool _isSubmitting = false;

  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController goalAmountController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController usageController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController bankInfoController = TextEditingController();

  String? userId;
  String selectedCategory = 'Medical';
  int _currentStep = 0;

  final List<String> categories = [
    'Medical',
    'Education',
    'Emergency',
    'Animal Help',
    'Memorial',
    'Other',
  ];

  final Map<String, IconData> categoryIcons = {
    'Medical': Icons.medical_services,
    'Education': Icons.school,
    'Emergency': Icons.emergency,
    'Animal Help': Icons.pets,
    'Memorial': Icons.volunteer_activism,
    'Other': Icons.category,
  };

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    goalAmountController.dispose();
    locationController.dispose();
    usageController.dispose();
    contactController.dispose();
    bankInfoController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  Future<void> submitFundraiser() async {
    if (!_formKey.currentState!.validate()) {
      // Find the first error and scroll to it
      _scrollToFirstError();
      return;
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ User not logged in! Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      Response response = await Dio().post(
        'http://100.64.234.91:3000/fundraise',
        data: jsonEncode({
          'title': titleController.text.trim(),
          'description': descriptionController.text.trim(),
          'goalAmount': int.parse(goalAmountController.text),
          'location': locationController.text.trim(),
          'category': selectedCategory,
          'usage': usageController.text.trim(),
          'contactNumber': contactController.text.trim(),
          'bankInfo': bankInfoController.text.trim(),
          'userId': userId,
        }),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 201) {
        _showSuccessDialog();
        _formKey.currentState!.reset();
        setState(() {
          selectedCategory = 'Medical';
          _currentStep = 0;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Submission failed. Try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _scrollToFirstError() {
    // This is a simple implementation - in a real app you might want to
    // scroll to the specific field with an error
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text("Success!"),
            ],
          ),
          content: const Text(
            "Your fundraiser has been submitted successfully and is pending approval.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text("OK", style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Basic Information",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: 'Fundraiser Title',
            hintText: 'Enter a clear, attention-grabbing title',
            prefixIcon: const Icon(Icons.title, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          validator: (value) => value!.isEmpty ? 'Title is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Explain your cause in detail',
            prefixIcon: const Icon(Icons.description, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            alignLabelWithHint: true,
          ),
          maxLines: 5,
          validator: (value) => value!.isEmpty ? 'Description is required' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField(
          value: selectedCategory,
          decoration: InputDecoration(
            labelText: 'Category',
            prefixIcon: Icon(
              categoryIcons[selectedCategory] ?? Icons.category,
              color: Colors.blue,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          items: categories.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Row(
                children: [
                  Icon(categoryIcons[cat], size: 20),
                  const SizedBox(width: 10),
                  Text(cat),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedCategory = value!),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: locationController,
          decoration: InputDecoration(
            labelText: 'Location',
            hintText: 'Where is this fundraiser based?',
            prefixIcon: const Icon(Icons.location_on, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Financial Information",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: goalAmountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Goal Amount (Rs.)',
            hintText: 'How much do you need to raise?',
            prefixIcon: const Icon(Icons.monetization_on, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Goal amount is required';
            if (int.tryParse(value) == null) return 'Enter a valid number';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: usageController,
          decoration: InputDecoration(
            labelText: 'How will funds be used?',
            hintText: 'Provide a breakdown of how you plan to use the funds',
            prefixIcon: const Icon(Icons.account_balance_wallet, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: bankInfoController,
          decoration: InputDecoration(
            labelText: 'Bank Account Info (Optional)',
            hintText: 'Account number, bank name, etc.',
            prefixIcon: const Icon(Icons.account_balance, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Contact Information",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: contactController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Contact Number',
            hintText: 'Enter your phone number',
            prefixIcon: const Icon(Icons.phone, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    "Important Information",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "• Your fundraiser will be reviewed before it goes live",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                "• You may be contacted for verification purposes",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                "• Ensure all information provided is accurate",
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.send),
            onPressed: _isSubmitting ? null : submitFundraiser,
            label: Text(_isSubmitting ? 'Submitting...' : 'Submit Fundraiser'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Fundraiser'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() {
                _currentStep += 1;
              });
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep -= 1;
              });
            }
          },
          onStepTapped: (step) {
            setState(() {
              _currentStep = step;
            });
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  if (_currentStep < 2)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Next'),
                      ),
                    ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Basic Information'),
              content: Form(
                key: _formKey,
                child: _buildBasicInfoStep(),
              ),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Financial Details'),
              content: _buildFinancialInfoStep(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Contact & Submit'),
              content: _buildContactInfoStep(),
              isActive: _currentStep >= 2,
              state: StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }
}

