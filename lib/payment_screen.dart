import 'package:flutter/material.dart';
import 'blynk_service.dart';

class PaymentScreen extends StatefulWidget {
  final String flatProfile;

  PaymentScreen({Key? key, required this.flatProfile}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final BlynkService _blynkService; // Declare BlynkService
  final TextEditingController _amountController =
      TextEditingController(); // Controller for amount input
  double _waterPrice = 0.0; // Variable to hold calculated water price

  @override
  void initState() {
    super.initState();
    _blynkService = BlynkService(widget.flatProfile); // Initialize BlynkService
  }

  // Function to calculate and set water price
  void _calculateAndSetPrice() {
    final double? amount = double.tryParse(_amountController.text);
    if (amount != null && amount > 0) {
      setState(() {
        _waterPrice = amount * 1; // Example calculation for water price
      });
    } else {
      setState(() {
        _waterPrice = 0.0; // Reset price if input is invalid
      });
    }
  }

  // Function to process payment
  void _processPayment() async {
    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount.');
      return;
    }

    try {
      await _blynkService
          .handlePayment(amount); // Handle payment via BlynkService
      await _blynkService
          .readAndUpdateWaterUsageData(); // Update water usage data
      _showSnackBar(
          'Payment successful! Water limit is now ${_blynkService.waterUsageData.waterLimit}');
      _amountController.clear();
      setState(() {
        _waterPrice = 0.0; // Reset price after successful payment
      });
    } catch (e) {
      _showSnackBar('Payment failed: $e');
    }
  }

  // Function to show snack bar with message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              const Text('Enter Amount to Water',
                  style: TextStyle(fontSize: 20)),
              _buildTextField(
                controller: _amountController,
                labelText: 'Amount in Liters',
                icon: Icons.water_drop,
                onChanged: (value) =>
                    _calculateAndSetPrice(), // Calculate price on input change
              ),
              const SizedBox(height: 20),
              const Text('Price of Water', style: TextStyle(fontSize: 20)),
              _buildTextField(
                controller: TextEditingController(
                    text:
                        '${_waterPrice.toStringAsFixed(2)} tk'), // Display calculated price
                icon: Icons.attach_money,
                enabled: false,
                labelText: '',
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _processPayment, // Process payment on button press
                child: Text('MAKE PAYMENT'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build text field
  Widget _buildTextField({
    required TextEditingController controller,
    String labelText = '',
    IconData? icon,
    bool obscureText = false,
    bool enabled = true,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        enabled: enabled,
        decoration: InputDecoration(
          filled: true,
          fillColor: enabled
              ? Color.fromARGB(255, 141, 145, 255).withOpacity(0.8)
              : Color.fromARGB(255, 141, 145, 255).withOpacity(0.8),
          labelText: labelText,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        keyboardType:
            enabled ? TextInputType.numberWithOptions(decimal: true) : null,
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose(); // Dispose the controller
    super.dispose();
  }
}
