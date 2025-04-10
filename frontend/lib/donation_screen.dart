import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
// Using open_file instead of share_plus for better compatibility
import 'package:open_file/open_file.dart';

class DonationScreen extends StatefulWidget {
  final String fundraiserId;

  const DonationScreen({Key? key, required this.fundraiserId}) : super(key: key);

  @override
  _DonationScreenState createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen>
    with WidgetsBindingObserver {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _donorNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final String backendUrl = "http://100.64.234.91:3000";
  final formatter = NumberFormat('#,##0', 'en_US');

  bool _openedKhalti = false;
  String? _latestPidx;
  bool _isLoading = true;
  bool _isSubmitting = false;
  Map<String, dynamic> _fundraiserDetails = {};
  String _errorMessage = '';
  String? _receiptPath;
  Map<String, dynamic> _donationDetails = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchFundraiserDetails();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _amountController.dispose();
    _donorNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchFundraiserDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('$backendUrl/fundraisers/${widget.fundraiserId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _fundraiserDetails = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load fundraiser details";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network error: Unable to fetch fundraiser details";
        _isLoading = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _openedKhalti) {
      _openedKhalti = false;

      // ✅ Verify donation on return
      verifyDonation().then((_) {
        _generateDonationReceipt();
      });
    }
  }

  Future<void> _generateDonationReceipt() async {
    final pdf = pw.Document();
    final donorName = _donorNameController.text;
    final amount = int.parse(_amountController.text);
    final date = DateTime.now();
    final receiptNumber = 'RCT-${date.millisecondsSinceEpoch.toString().substring(5)}';
    
    // Store donation details for receipt
    _donationDetails = {
      'donorName': donorName,
      'amount': amount,
      'date': date,
      'receiptNumber': receiptNumber,
      'fundraiserTitle': _fundraiserDetails['title'] ?? 'Fundraiser',
    };

    // Generate PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'DONATION RECEIPT',
                      style: pw.TextStyle(
                        fontSize: 24, 
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Receipt #: $receiptNumber',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Thank you for your generous donation!',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.purple,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Your contribution will make a real difference.',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 30),
                _buildReceiptRow('Donor Name:', donorName),
                _buildReceiptRow('Donation Amount:', 'NPR ${formatter.format(amount)}'),
                _buildReceiptRow('Donation Date:', DateFormat('MMM dd, yyyy').format(date)),
                _buildReceiptRow('Donation Time:', DateFormat('hh:mm a').format(date)),
                _buildReceiptRow('Fundraiser:', _fundraiserDetails['title'] ?? 'Fundraiser'),
                _buildReceiptRow('Payment Method:', 'Khalti'),
                pw.SizedBox(height: 30),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    'This receipt is computer generated and does not require a signature.',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Save PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/donation_receipt_$receiptNumber.pdf');
    await file.writeAsBytes(await pdf.save());
    
    setState(() {
      _receiptPath = file.path;
    });

    // Show success dialog with receipt option
    _showSuccessDialog();
  }

  pw.Widget _buildReceiptRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text("Donation Completed"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Thank you for your generous donation!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Your contribution will make a real difference.",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            if (_receiptPath != null)
              OutlinedButton.icon(
                icon: Icon(Icons.download),
                label: Text("View Receipt"),
                onPressed: () {
                  Navigator.pop(context);
                  _openReceipt();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple.shade800,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to fundraiser screen
            },
            child: Text("Close", style: TextStyle(fontSize: 16, color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Future<void> _openReceipt() async {
    if (_receiptPath != null) {
      // Using OpenFile to open the PDF with the default PDF viewer
      await OpenFile.open(_receiptPath!);
    }
  }

  Future<void> verifyDonation() async {
    if (_latestPidx == null) return;

    final verifyUrl = "$backendUrl/verify-donation?pidx=$_latestPidx";

    try {
      final response = await http.get(Uri.parse(verifyUrl));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        print("✅ Donation verified successfully");
      } else {
        print("❌ Donation verification failed: ${data['message']}");
      }
    } catch (e) {
      print("❌ Error verifying donation: $e");
    }
  }

  Future<void> _donate() async {
    String amount = _amountController.text.trim();
    String donorName = _donorNameController.text.trim();

    if (donorName.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your name and amount'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final apiUrl = "$backendUrl/donate";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "donorName": donorName,
          "amount": int.parse(amount),
          "fundraiserId": widget.fundraiserId,
          "website_url": backendUrl,
        }),
      );

      final data = jsonDecode(response.body);
      print("Response Status: ${response.statusCode}");
      print("Response Data: $data");

      if (response.statusCode == 200 && data['success']) {
        String khaltiUrl = data['payment']['payment_url'];
        _latestPidx = data['payment']['pidx']; // ✅ Save pidx for verification

        if (await canLaunch(khaltiUrl)) {
          _openedKhalti = true;
          await launch(khaltiUrl);
        } else {
          throw 'Could not launch $khaltiUrl';
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${data['message'] ?? 'Unknown error'}"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to connect to server"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildFundraiserDetails() {
    if (_isLoading) {
      return Container(
        height: 150,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Container(
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 40),
              SizedBox(height: 10),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final title = _fundraiserDetails['title'] ?? 'No Title';
    final goal = _fundraiserDetails['goalAmount'] ?? 0;
    final raised = _fundraiserDetails['raisedAmount'] ?? 0;
    final category = _fundraiserDetails['category'] ?? 'Other';
    
    double progress = goal > 0 ? (raised / goal).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade50, Colors.purple.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.purple.shade800,
              ),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          category,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NPR ${formatter.format(raised)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.purple.shade800,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Goal: NPR ${formatter.format(goal)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}% Complete',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.purple.shade800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'medical':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      case 'emergency':
        return Icons.emergency;
      case 'animal help':
        return Icons.pets;
      case 'memorial':
        return Icons.volunteer_activism;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donate Now'),
        backgroundColor: Colors.purple.shade800,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFundraiserDetails(),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Information",
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _donorNameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        hintText: 'Enter your full name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.purple.shade800),
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email (for receipt)',
                        hintText: 'Enter your email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.email, color: Colors.purple.shade800),
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount (NPR)',
                        hintText: 'Enter amount',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.money, color: Colors.purple.shade800),
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _donate,
                        icon: _isSubmitting 
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.payment),
                        label: Text(_isSubmitting ? 'Processing...' : 'Donate via Khalti'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF5C2D91), // Khalti purple color
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.purple.shade800, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Your payment information is processed securely. A donation receipt will be available to download after payment.",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

