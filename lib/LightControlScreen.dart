import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moto/ipconfig.dart';

class LightControlScreen extends StatefulWidget {
  const LightControlScreen({super.key});

  @override
  State<LightControlScreen> createState() => _LightControlScreenState();
}

class _LightControlScreenState extends State<LightControlScreen> {

  bool isLightOn = false;
  final String serverUrl = 'http://$ipconfig';

  Future<void> toggleLight(bool turnOn) async {
    String url = turnOn ? '$serverUrl/on' : '$serverUrl/off';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() => isLightOn = turnOn);
      } else {
        showError('Failed to update light status');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  Future<void> getLightStatus() async {
    try {
      final response = await http.get(Uri.parse('$serverUrl/status'));
      if (response.statusCode == 200) {
        setState(() => isLightOn = json.decode(response.body)['status'] == 'on');
      }
    } catch (e) {
      showError('Error fetching status');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    getLightStatus();
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(title: Text('MOTOCONTROLLER')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLightOn ? Icons.lightbulb : Icons.lightbulb_outline,
              size: 100,
              color: isLightOn ? Colors.yellow : Colors.grey,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => toggleLight(true),
              child: Text('Turn ON'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => toggleLight(false),
              child: Text('Turn OFF'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}