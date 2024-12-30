import 'dart:convert';
import 'package:http/http.dart' as http;

class IpService {
  static const String localServerUrl = 'http://10.0.2.2:3000/get-ip';

  Future<String> fetchIpAddress() async {
    try {
      final response = await http.get(Uri.parse(localServerUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('ip')) {
          print('Fetched IP address: ${data['ip']}');
          return data['ip'];
        } else {
          throw Exception('IP address not found in response');
        }
      } else {
        throw Exception('Failed to fetch IP address: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching IP address: $e');
      throw Exception('Error fetching IP address: $e');
    }
  }
}
