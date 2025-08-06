import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:moto/select.dart';

class SmartScreen extends StatefulWidget {
  @override
  _SmartScreenState createState() => _SmartScreenState();
}

class _SmartScreenState extends State<SmartScreen> {
  bool isLoading = false;
   var productData;
  double _lightIntensity = 65;
  DateTime _selectedDateTime = DateTime.now();
  String get formattedDateTime => DateFormat('EEEE, MMM d, yyyy HH:mm:ss').format(_selectedDateTime);
  Timer? _timer;

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

  void _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
        postService(context);
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (DateTime.now().isAfter(_selectedDateTime)) {
        toggleLED(!ledState);
        print("Started");
        timer.cancel();
      }
    });
  }

Future<void> fetchdata() async {

  var url = "https://motobackend.onrender.com/getUploaded";
  var response = await http.post(Uri.parse(url), body: {
    'email': 'wilfredc685@gmail.com',
  });

  
    var jsonResponse = json.decode(response.body);
    print(jsonResponse);
    if (jsonResponse['message'] == "Data fetched successfully") {
      setState(() {
        productData = jsonResponse['data'];
        // name = productData['name'];
        // price = productData['price'];
        // category = productData['category'];
        // mainImage = productData['image_01'];
      });
    }
  
}


Future<void> postService(BuildContext context) async {
  final uri = Uri.parse("https://motobackend.onrender.com/uploaddata");

  var response = await http.post(
    uri,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": "wilfredc685@gmail.com",
      "datetime": _selectedDateTime.toString()
    }),
  );

  if (response.statusCode == 200) {
    print('Datetime set successfully');
    showPopup(context, 'Datetime set');
  } else {
    print('Failed to set datetime');
    showPopup(context, 'Not set');
  }
}

void showPopup(BuildContext context, String message) {
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        
        Future.delayed(Duration(seconds: 6), () {
          Navigator.of(context).pop();
        });

        
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          insetPadding: EdgeInsets.only(bottom: 650),
            child: Container(
              // color:Color(0xFF248560),
              color: Colors.black,
              width: MediaQuery.of(context).size.width,
              height: 80,
              child: Column(
                
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: Text(message, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),),
                  )
                ],
              ),
            ),
        );
      },
    );
  }
  

  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Section
          Container(
            height: 400,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.blue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(height: 40),
                Text(
                  ledState ? "ON" : "OFF",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                ledState ? 
                Icon(Icons.drive_eta, size: 100, color: Colors.yellowAccent):
                Icon(Icons.drive_eta, size: 100, color: Colors.grey[200]),
                Slider(
                  value: _lightIntensity,
                  min: 0,
                  max: 100,
                  onChanged: (value) {
                    setState(() {
                      _lightIntensity = value;
                    });
                  },
                  activeColor: Colors.yellowAccent,
                  inactiveColor: Colors.white54,
                ),
                Text(
                  "Rev Engine: ${_lightIntensity.toInt()}%",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 5),
        Text(formattedDateTime, style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),

          // Power Button
          // Padding(
          //   padding: const EdgeInsets.all(20.0),
          //   child: ElevatedButton(
          //     onPressed: () {},
          //     style: ElevatedButton.styleFrom(
          //       shape: CircleBorder(),
          //       padding: EdgeInsets.all(20),
          //       backgroundColor: Colors.redAccent,
          //     ),
          //     child: Icon(Icons.power_settings_new, color: Colors.white, size: 40),
          //   ),
          // ),

          // // Rooms Selection
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       GestureDetector(
          //         onTap: _pickDateTime,
          //         child: _dateTile(formattedDateTime),
          //       ),
          //       _roomTile(Iconsax.home, "Living Room"),
          //       _roomTile(Iconsax.add_square1, "Reset Timer", selected: true),
          //       // _dateTile(_currentDate),
          //     ],
          //   ),
          // ),
SizedBox(height: 20,),
          profile_list(
                      icon: Icons.power_settings_new,
                      title: ledState ?  "Power Off" : "Power On",
                      color: Colors.black87,
                      onTap: (){toggleLED(!ledState);}
                    ),
                     const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      child: Divider(),
                    ),

           profile_list(
                      icon: Icons.calendar_today,
                      title: "Set Timer",
                      color: Colors.black87,
                      onTap:  _pickDateTime
                    ),
                     const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      child: Divider(),
                    ),

                     profile_list(
                      icon: Icons.timer,
                      title: "Reset Timer",
                      color: Colors.black87,
                      onTap:  _pickDateTime
                    ),
        ],
      ),
    );
  }

Widget _dateTile(String date) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.calendar_today, color: Colors.white),
        ),
        SizedBox(height: 5),
        // Text(date, style: TextStyle(color: Colors.black54)),
        Text('Set Timer', style: TextStyle(color: Colors.black54))
      ],
    );
  }

  Widget _roomTile(IconData icon, String label, {bool selected = false}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: selected ? Colors.blueAccent : Colors.grey[300],
          child: Icon(icon, color: selected ? Colors.white : Colors.black54),
        ),
        SizedBox(height: 5),
        Text(label, style: TextStyle(color: Colors.black54)),
      ],
    );
  }
}
