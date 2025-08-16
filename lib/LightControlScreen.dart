import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceChatScreen extends StatefulWidget {
  @override
  _VoiceChatScreenState createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;
  String _userText = "";
  int _conversationStage = 0;
  int _conversation = 0;

  double temperature = 0.0;
  double humidity = 0.0;
  // Timer? _timer;

bool _isLoading = false;

  String _status = "Unknown";

  String irStatus = "Waiting..."; // UI text for IR status
  Timer? _irTimer;

  bool isCooking = false;
  int remainingSeconds = 100; // Change this to desired countdown duration
  Timer? _timer;


Future<void> fetchTemp() async {
  try {
    final response = await http.get(Uri.parse("https://motobackend.onrender.com/dht-data"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _status = "Temp: ${data['temperature']}°C, Humidity: ${data['humidity']}%";
      });
    } else {
      setState(() => _status = "Error: ${response.statusCode}");
    }
  } catch (e) {
    setState(() => _status = "Error: $e");
  }
}

Future<void> fetchIRStatus() async {
    try {
      final response = await http.get(Uri.parse("https://motobackend.onrender.com/detection"));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _status = data["status"] == "detected" ? "HIGH" : "LOW";
        });
      } else {
        setState(() => _status = "Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _status = "Error: $e");
    }
  }
//   Future<void> fetchIRStatus() async {
//     // setState(() {
//     //   _isLoading = true;
//     // });
//   final response = await http.get(Uri.parse("$serverUrl/detection"));
//   // setState(() {
//   //   _isLoading = false;
//   // });
//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     setState(() {
//       irStatus = data["status"] == "detected" ? "Object Detected!" : "No Object";
//     });
//     print(data);
//   }
// }

void startIRPolling() {
  _irTimer?.cancel();
  _irTimer = Timer.periodic(Duration(seconds: 1), (_) {
    // fetchIRStatus();
  });
}

bool ledState = false;
  final String serverUrl = "https://motobackend.onrender.com"; 

  Future<void> toggleLED(bool state) async {
    print(ledState);
    startTimer();
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

void startTimer() {
  setState(() {
    isCooking = true;
    remainingSeconds = 100; // Reset timer each time
  });

  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    setState(() {
      if (remainingSeconds > 1) {
        remainingSeconds--;
      } else {
        timer.cancel();
        isCooking = false; // Show "Start Cooking" again
        // toggleLED(false);

        // // ✅ Show completion dialog here
        // showDialog(
        //   context: context,
        //   barrierDismissible: false,
        //   builder: (BuildContext context) {
        //     return AlertDialog(
        //       backgroundColor: Color(0xFF2C2C2E),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(16),
        //       ),
        //       title: Text(
        //         'Done Cooking!',
        //         style: TextStyle(color: Colors.yellow[700]),
        //       ),
        //       content: Text(
        //         'Your cooking process is complete.',
        //         style: TextStyle(color: Colors.white70),
        //       ),
        //       actions: [
        //         TextButton(
        //           onPressed: () {
        //             Navigator.of(context).pop(); // Close the dialog
        //           },
        //           child: Text(
        //             'OK',
        //             style: TextStyle(color: Colors.yellow[700]),
        //           ),
        //         ),
        //       ],
        //     );
        //   },
        // );
      }
    });
  });
}

  

  @override
  void initState() {
    super.initState();
    fetchDHTData();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();

    _setupTts();
    _listAvailableVoices(); // Just to check what voices your device supports
    // startIRPolling();
    _timer = Timer.periodic(Duration(seconds: 2), (_) => fetchDHTData());
  }

  Future<void> fetchDHTData() async {
    try {
      print('object');
      final response = await http.get(Uri.parse("$serverUrl/dht-data"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        setState(() {
          temperature = (data["temperature"] ?? 0).toDouble();
          humidity = (data["humidity"] ?? 0).toDouble();
        });
      }
    } catch (e) {
      print("Error fetching DHT data: $e");
    }
  }


  void _setupTts() async {
    // You can try changing to another voice from the printed list
    await _tts.setVoice({
      "name": "en-gb-x-gba-local",
      "locale": "en-UK"
    });

    await _tts.setSpeechRate(0.5); // Normal pace but not too fast
    await _tts.setPitch(1.2);      // Slightly cheerful tone
    await _tts.setVolume(1.0);     // Full volume
  }

  void _listAvailableVoices() async {
    var voices = await _tts.getVoices;
    print("Available voices: $voices");
  }

void _startListening() async { bool available = await _speech.initialize( onStatus: (status) => print("Speech status: $status"), onError: (error) => print("Speech error: $error"), ); if (available) { setState(() => _isListening = true); _speech.listen(onResult: (result) { setState(() { _userText = result.recognizedWords; }); if (result.finalResult) { _respondToUser(_userText.toLowerCase()); } }); } }
void _startListeningB() async { bool available = await _speech.initialize( onStatus: (status) => print("Speech status: $status"), onError: (error) => print("Speech error: $error"), ); if (available) { setState(() => _isListening = true); _speech.listen(onResult: (result) { setState(() { _userText = result.recognizedWords; }); if (result.finalResult) { _respondToUserB(_userText.toLowerCase()); } }); } }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _respondToUser(String command) async {
  String reply = "Hmm, I didn’t catch that. Could you say it again?";

  // Stage 0: Waiting for start command
  if (_conversationStage == 0 && command.contains("start cooking indomie")) {
    reply = "Chef Bot here! Before we start, have you added water to container C and oil to container D?";
    _conversationStage = 1;
  }

  // Stage 1: Water & oil confirmation
  else if (_conversationStage == 1 && command.contains("yes")) {
    reply = "Lovely! Now, have you added the indomie noodles plus seasoning to container A, and onion plus sliced tomato to container B?";
    _conversationStage = 2;
  }

  // Stage 2: Check ingredients with IR sensor
  else if (_conversationStage == 2 && command.contains("yes")) {
    reply = "Perfecto! Do you want me to start cooking now?";
    _conversationStage = 3; // stay in stage 2 until detected
    // await _tts.speak(reply);
    // _checkIngredientsAndContinue();
    // return; // prevent speaking twice
  }

  // Stage 3: Start cooking confirmation
  else if (_conversationStage == 3 && command.contains("yes")) {
    reply = "Fantastic! Starting the cooking process. Sit back, relax, and let the aroma take over!";
    _conversationStage = 0;
    toggleLED(true); // trigger cooking
  }

  // "No" response at any stage
  else if (command.contains("no")) {
    reply = "Alright, I’ll be waiting here in the kitchen. Just say 'Start cooking Indomie' when you’re ready.";
    _conversationStage = 0;
  }

  await _tts.speak(reply);
}

void _respondToUserB(String command) async {
  String reply = "Hmm, I didn’t catch that. Could you say it again?";

   if (command.contains("check")) {
    reply = "Let me check if the ingredients are in place...";
    
    await _tts.speak(reply);
    _checkIngredientsAndContinue();
    return; // prevent speaking twice
    
  }
//   if (command.contains("check")) {
//     reply = "Perfecto! I see the ingredients are in place. Do you want me to start cooking now?";
    
//   }

//  else {
//       reply = "Hmm, it looks like some ingredients are missing. Please add everything into the right containers.";
      
//     }

  await _tts.speak(reply);
}


// Auto-check IR status until ingredients are detected
Future<void> _checkIngredientsAndContinue() async{

  await  fetchIRStatus();

  if (_status == "HIGH") {
      // setState(() {
      //   _isLoading = false;
      // });
    
      await _tts.speak("Perfecto! Your ingredients are in place!");
      // return;
    }

 else {
  await _tts.speak("Hmm, it looks like some ingredients are missing. Please add everything into the right containers.");
      
    }


  
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: Colors.grey[100],
  appBar: AppBar(
    title: Text(
      "🤖 Chef Bot Assistant",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    centerTitle: true,
    backgroundColor: Colors.black87,
    elevation: 6,
    shadowColor: Colors.black54,
  ),
  body: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // Robot Status
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 6,
            shadowColor: Colors.black45,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                children: [
                  Icon(
                    ledState ? Icons.lightbulb : Icons.lightbulb_outline,
                    size: 60,
                    color: ledState ? Colors.green[600] : Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    ledState ? "Power: ON" : "Power: OFF",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: ledState ? Colors.green[800] : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 25),

          // Temperature & Humidity Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Icon(Icons.thermostat, color: Colors.orange, size: 30),
                  //     SizedBox(width: 8),
                  //     Text(
                  //       "Temperature: ${temperature.toStringAsFixed(1)} °C",
                  //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  //     ),
                  //   ],
                  // ),

                  ElevatedButton(
  onPressed: fetchTemp,
  child: Text("Check Temperature"),
),

                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.water_drop, color: Colors.blueGrey, size: 30),
                      SizedBox(width: 8),
                      Text(
                        "Humidity: ${humidity.toStringAsFixed(1)} %",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 25),

 ElevatedButton.icon(
            onPressed: _startListeningB,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[600],
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
            ),
            icon: Icon(Icons.mic, size: 28),
            label: Text(
              "Start Talking",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
            SizedBox(height: 20),
            Text(
              "IR Status: $_status",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

          // IR Status
          Card(
            color: Colors.grey[200],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "📡 IR Status: $irStatus",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.blueGrey[700]),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          SizedBox(height: 25),

          // User Command / Suggestions
          Text(
            _userText.isEmpty
                ? "💬 Say something like: Start cooking Indomie"
                : _userText,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),

          if (_isLoading) ...[
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],

          SizedBox(height: 40),

          // Voice Button
          ElevatedButton.icon(
            onPressed: _startListening,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[600],
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
            ),
            icon: Icon(Icons.mic, size: 28),
            label: Text(
              "Start Talking",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: 20),

          // 🔌 Shutdown Button
          ElevatedButton.icon(
            onPressed: () {toggleLED(false);
              // TODO: call shutdown function here
              // e.g., send shutdown command to robot
              print("Shutdown pressed");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
            ),
            icon: Icon(Icons.power_settings_new, size: 28),
            label: Text(
              "Shutdown",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ),
  ),
);

  }
}

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:flutter_tts/flutter_tts.dart';

// class VoiceChatScreen extends StatefulWidget {
//   @override
//   _VoiceChatScreenState createState() => _VoiceChatScreenState();
// }

// class _VoiceChatScreenState extends State<VoiceChatScreen> {
//   final String serverUrl = "https://motobackend.onrender.com";

//   late stt.SpeechToText _speech;
//   late FlutterTts _tts;

//   bool ledState = false;
//   String irStatus = "Unknown";
//   String temperature = "--";
//   String humidity = "--";

//   int _conversationStage = 0; // 0 idle, 2 waiting for IR, 3 confirm cooking
//   bool _isLoading = false;
//   String _recognizedText = "";

//   Timer? _statusTimer;
//   Timer? _dhtTimer;
//   Timer? _irTimer;

//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//     _tts = FlutterTts();

//     _setupTts();
//     _listAvailableVoices();

//     _statusTimer = Timer.periodic(Duration(seconds: 2), (_) => fetchLEDStatus());
//     _dhtTimer = Timer.periodic(Duration(seconds: 2), (_) => fetchDHTData());
//   }

//   @override
//   void dispose() {
//     _statusTimer?.cancel();
//     _dhtTimer?.cancel();
//     _irTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _setupTts() async {
//     await _tts.setLanguage("en-US");
//     await _tts.setSpeechRate(0.5);
//     await _tts.setVolume(1.0);
//     await _tts.setPitch(1.0);
//   }

//   Future<void> _listAvailableVoices() async {
//     var voices = await _tts.getVoices;
//     print("Available voices: $voices");
//   }

//   // 🎤 Start listening to user
//   void _startListening() async {
//     bool available = await _speech.initialize();
//     if (available) {
//       _speech.listen(onResult: (result) {
//         setState(() {
//           _recognizedText = result.recognizedWords;
//         });
//         if (result.finalResult) {
//           _speech.stop();
//           _respondToUser(_recognizedText.toLowerCase());
//         }
//       });
//     } else {
//       await _tts.speak("Speech recognition is not available.");
//     }
//   }

//   // 🗣 Respond based on command & stage
//   Future<void> _respondToUser(String command) async {
//     if (_conversationStage == 0) {
//       if (command.contains("start cooking")) {
//         await toggleLED(true);
//         await _tts.speak(
//             "Cooking mode activated. Please place the ingredients in the container.");
//         setState(() {
//           _conversationStage = 2;
//         });
//         startIRPolling();
//       } else {
//         await _tts.speak("Say 'start cooking' to begin.");
//       }
//     } else if (_conversationStage == 3) {
//       if (command.contains("yes")) {
//         await _tts.speak("Starting cooking now.");
//         // here you could send command to ESP32 to run motors, etc.
//         setState(() {
//           _conversationStage = 0;
//         });
//       } else if (command.contains("no")) {
//         await _tts.speak("Okay, cancelling cooking process.");
//         setState(() {
//           _conversationStage = 0;
//         });
//       }
//     }
//   }

//   // 🌐 Toggle cooking mode
//   Future<void> toggleLED(bool state) async {
//     try {
//       final response = await http.post(
//         Uri.parse("$serverUrl/toggle"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"state": state}),
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           ledState = state;
//         });
//       }
//     } catch (e) {
//       print("Error toggling LED: $e");
//     }
//   }

//   // 🌐 Fetch cooking mode
//   Future<void> fetchLEDStatus() async {
//     try {
//       final response = await http.get(Uri.parse("$serverUrl/status"));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         bool newState = data["state"];

//         if (newState != ledState) {
//           setState(() {
//             ledState = newState;
//           });
//         }

//         if (ledState && _conversationStage == 0) {
//           print("Cooking mode ON → auto starting stage 2");
//           setState(() {
//             _conversationStage = 2;
//           });
//           await _tts.speak(
//               "Cooking mode activated. Please place the ingredients in the container.");
//           startIRPolling();
//         }
//       }
//     } catch (e) {
//       print("Error fetching LED status: $e");
//     }
//   }

//   // 🌐 Fetch IR status
//   Future<void> fetchIRStatus() async {
//     try {
//       final response = await http.get(Uri.parse("$serverUrl/detection"));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         String statusText =
//             data["status"] == "detected" ? "Object Detected!" : "No Object";

//         setState(() {
//           irStatus = statusText;
//         });

//         print("IR API Response → $statusText");

//         if (statusText == "Object Detected!" && _conversationStage == 2) {
//           _irTimer?.cancel();
//           _irTimer = null;
//           setState(() {
//             _isLoading = false;
//             _conversationStage = 3;
//           });
//           await _tts.speak("Perfecto! Do you want me to start cooking now?");
//         }
//       }
//     } catch (e) {
//       print("Error fetching IR status: $e");
//     }
//   }

//   // ⏳ Poll IR until detected or timeout
//   void startIRPolling() {
//     setState(() {
//       _isLoading = true;
//     });
//     int secondsWaited = 0;
//     const int maxWaitTime = 40;

//     _irTimer?.cancel();
//     _irTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
//       secondsWaited++;
//       await fetchIRStatus();

//       if (secondsWaited >= maxWaitTime && _conversationStage == 2) {
//         timer.cancel();
//         _irTimer = null;
//         setState(() {
//           _isLoading = false;
//           _conversationStage = 0;
//         });
//         await _tts.speak(
//             "The container is empty. Please add the ingredients before we continue.");
//       }
//     });
//   }

//   // 🌡 Fetch DHT sensor data
//   Future<void> fetchDHTData() async {
//     try {
//       final response = await http.get(Uri.parse("$serverUrl/dht-data"));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           temperature = data["temperature"]?.toStringAsFixed(1) ?? "--";
//           humidity = data["humidity"]?.toStringAsFixed(1) ?? "--";
//         });
//       }
//     } catch (e) {
//       print("Error fetching DHT data: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Voice Chat Cooking Assistant")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text("Cooking Mode: ${ledState ? "ON" : "OFF"}"),
//             Text("IR Status: $irStatus"),
//             Text("Temperature: $temperature°C"),
//             Text("Humidity: $humidity%"),
//             SizedBox(height: 20),
//             if (_isLoading) CircularProgressIndicator(),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _startListening,
//               child: Text("🎤 Speak"),
//             ),
//             SizedBox(height: 10),
//             Text("You said: $_recognizedText"),
//           ],
//         ),
//       ),
//     );
//   }
// }
