import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'water_usage_data.dart';
import 'notification_service.dart';

class BlynkService {
  final String _baseURL = 'https://sgp1.blynk.cloud/external/api';
  final String _authToken;
  Timer? _dataTimer;
  bool notificationFor500mlSent = false;
  bool notificationForZeroLimitSent = false;
  static bool isLoggedIn = false;
  static String currentProfile = '';

  // Constructor to initialize the BlynkService with the appropriate auth token
  BlynkService(String profile)
      : _authToken = profile == 'Flat-1'
            ? 'kNw74G7YouH-PGudvMaOFkjhOcBRYut9'
            : 'l4_Gv6GCcvAmEZ6btEQzYWNhtNl8imGk' {
    setCurrentProfile(profile);
  }

  // Set the current profile
  static void setCurrentProfile(String profile) {
    currentProfile = profile;
  }

  WaterUsageData waterUsageData = WaterUsageData.initial();

  // Log in and start the data timer
  void logIn() {
    isLoggedIn = true;
    print("Logged in as $currentProfile.");
    startDataTimer();
  }

  // Log out and stop the data timer
  void logOut() {
    isLoggedIn = false;
    print("Logged out from $currentProfile.");
    stopDataTimer();
  }

  // Start the timer to periodically fetch and update data
  void startDataTimer() {
    _dataTimer?.cancel();
    _dataTimer = Timer.periodic(
        const Duration(minutes: 1), (Timer t) => fetchAndUpdateData());
  }

  // Stop the data timer
  void stopDataTimer() {
    _dataTimer?.cancel();
    _dataTimer = null;
  }

  // Fetch and update data periodically
  Future<void> fetchAndUpdateData() async {
    if (!isLoggedIn) {
      print("User is not logged in. Aborting data fetch and update.");
      return;
    }
    await readAndUpdateWaterUsageData();
    if (isLoggedIn && currentProfile == BlynkService.currentProfile) {
      await sendDataToXAMPP();
    }
  }

  // Read water usage data from the Blynk server and update local data
  Future<void> readAndUpdateWaterUsageData() async {
    var url = Uri.parse('$_baseURL/get?token=$_authToken&v1&v2&v3&v5');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      waterUsageData = WaterUsageData(
        waterLimit: double.tryParse(jsonData['v3'].toString()) ?? 0.0,
        flowRate: double.tryParse(jsonData['v2'].toString()) ?? 0.0,
        usedToday: double.tryParse(jsonData['v1'].toString()) ?? 0.0,
        totalUsed: double.tryParse(jsonData['v5'].toString()) ?? 0.0,
      );
      checkAndSendNotifications();
    } else {
      print(
          "Failed to read water usage data. Status Code: ${response.statusCode}. Body: ${response.body}");
    }
  }

  // Handle payment and reset notifications
  Future<void> handlePayment(double amount) async {
    notificationFor500mlSent = false;
    notificationForZeroLimitSent = false;

    await readAndUpdateWaterUsageData();
    double newWaterLimit = waterUsageData.waterLimit + amount;
    await writeData('v4', '1'); // Reset valve state
    await writeData('v3', newWaterLimit.toString()); // Update water limit
  }

  // Write data to the Blynk server
  Future<void> writeData(String pin, String value) async {
    var url = Uri.parse('$_baseURL/update?token=$_authToken&$pin=$value');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        print("Successfully updated datastream $pin with value $value");
      } else {
        print(
            "Failed to update datastream $pin. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception when updating datastream $pin: $e");
    }
  }

  // Send data to XAMPP server
  Future<void> sendDataToXAMPP() async {
    if (!isLoggedIn) {
      print("Data sending aborted due to user not being logged in.");
      return;
    }
    var url = Uri.parse('http://192.168.68.101/water_app/api.php');
    var response = await http.post(url, body: {
      'user_id': _authToken,
      'flow_rate': waterUsageData.flowRate.toString(),
      'total_used': waterUsageData.totalUsed.toString(),
      'used_today': waterUsageData.usedToday.toString(),
      'water_limit': waterUsageData.waterLimit.toString(),
    });
    if (response.statusCode == 200) {
      print("Data successfully sent to the server for $currentProfile.");
    } else {
      print(
          "Failed to send data for $currentProfile. Status Code: ${response.statusCode}. Response Body: ${response.body}");
    }
  }

  // Check and send notifications based on water usage data
  void checkAndSendNotifications() {
    if (!isLoggedIn) {
      return;
    }
    double gap = waterUsageData.waterLimit - waterUsageData.usedToday;
    if (waterUsageData.waterLimit == 0 && !notificationForZeroLimitSent) {
      NotificationService().showNotifications('Water Limit Reached',
          'Your Water Limit has been Reached. Please Pay Again.');
      notificationForZeroLimitSent = true;
    } else if (waterUsageData.waterLimit > 0 &&
        gap <= 0.5 &&
        !notificationFor500mlSent) {
      NotificationService().showNotifications('Water Limit Alert',
          'You have 500ml of Water left to use! Please Pay Again.');
      notificationFor500mlSent = true;
    }
    if (waterUsageData.waterLimit > 0 && gap > 0.5) {
      notificationFor500mlSent = false;
      notificationForZeroLimitSent = false;
    }
  }
}
