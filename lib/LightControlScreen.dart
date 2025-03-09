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

  bool ledState = false;
  final String serverUrl = "https://motobackend.onrender.com"; 

  Future<void> toggleLED(bool state) async {
    final response = await http.post(
      Uri.parse("$serverUrl/toggle"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"state": state}),
    );

    if (response.statusCode == 200) {
      setState(() {
        ledState = state;
      });
    }
  }

  Future<void> fetchLEDStatus() async {
    final response = await http.get(Uri.parse("$serverUrl/status"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        ledState = data["state"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLEDStatus(); // Fetch initial state on startup
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("ESP32 LED Control")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "LED is ${ledState ? "ON" : "OFF"}",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => toggleLED(!ledState),
                child: Text(ledState ? "Turn OFF" : "Turn ON"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}