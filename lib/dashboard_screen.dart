import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'blynk_service.dart';
import 'payment_screen.dart';
import 'water_usage_data.dart';

class DashboardScreen extends StatefulWidget {
  final String flatProfile;

  DashboardScreen({Key? key, required this.flatProfile}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final BlynkService _blynkService; // Declare BlynkService
  WaterUsageData? _waterUsageData; // Variable to hold water usage data
  Timer? _timer; // Timer for periodic data fetch

  @override
  void initState() {
    super.initState();
    _blynkService = BlynkService(widget.flatProfile); // Initialize BlynkService
    _blynkService.logIn(); // Log in to BlynkService
    _fetchData(); // Fetch initial data

    // Set up a timer to fetch data periodically
    _timer = Timer.periodic(
        const Duration(milliseconds: 500), (Timer t) => _fetchData());
  }

  // Function to fetch data from BlynkService
  void _fetchData() async {
    await _blynkService.readAndUpdateWaterUsageData();
    if (mounted) {
      setState(() {
        _waterUsageData =
            _blynkService.waterUsageData; // Update water usage data
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer
    _blynkService.logOut(); // Log out from BlynkService
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DASHBOARD - ${widget.flatProfile}'),
        backgroundColor: Colors.blueAccent,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _blynkService.logOut(); // Log out and navigate to login screen
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ));
            },
          ),
        ],
      ),
      body: _waterUsageData == null
          ? _buildLoadingIndicator() // Show loading indicator if data is null
          : _buildDashboardContent(), // Show dashboard content if data is available
    );
  }

  // Build dashboard content
  Widget _buildDashboardContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          UsageCard(
            color: Colors.black,
            title: 'Flow Rate',
            value: '${_waterUsageData!.flowRate.toStringAsFixed(2)} L/min',
          ),
          SizedBox(height: 20),
          UsageCard(
            color: Colors.purple,
            title: 'Total Used',
            value: '${_waterUsageData!.totalUsed} L',
          ),
          SizedBox(height: 20),
          UsageCard(
            color: Colors.orange,
            title: 'Real Time Use',
            value: '${_waterUsageData!.usedToday} L',
          ),
          SizedBox(height: 20),
          UsageCard(
            color: Colors.cyan,
            title: 'Water Limit',
            value: '${_waterUsageData!.waterLimit} L',
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) =>
                        PaymentScreen(flatProfile: widget.flatProfile)),
              );
            },
            child: Text('PAYMENT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Build loading indicator
  Widget _buildLoadingIndicator() {
    return Center(child: CircularProgressIndicator());
  }
}

// UsageCard widget to display water usage data
class UsageCard extends StatelessWidget {
  final Color color;
  final String title;
  final String value;

  const UsageCard({
    Key? key,
    required this.color,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
