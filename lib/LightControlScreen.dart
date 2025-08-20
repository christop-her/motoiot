// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:flutter_tts/flutter_tts.dart';

// class VoiceChatScreen extends StatefulWidget {
//   @override
//   _VoiceChatScreenState createState() => _VoiceChatScreenState();
// }

// class _VoiceChatScreenState extends State<VoiceChatScreen> {
//   // ==== Services ====
//   late stt.SpeechToText _speech;
//   late FlutterTts _tts;

//   // ==== Conversation state ====
//   bool _isListening = false;
//   String _userText = "";
//   int _conversationStage = 0;

//   // ==== Sensors / readings ====
//   double temperature = 0.0;
//   double humidity = 0.0;

//   // Separate UI statuses
//   String _tempStatus = "Unknown";
//   String _irStatus = "Unknown";

//   // ==== Timers ====
//   Timer? _dhtTimer;        // periodic fetch for DHT data
//   Timer? _irTimer;         // polling IR if you want it
//   Timer? _countdownTimer;  // cooking countdown

//   // ==== Cooking / LED control ====
//   bool ledState = false;
//   final String serverUrl = "https://motobackend.onrender.com";

//   bool isCooking = false;
//   static const int cookingDuration = 100; // seconds (change as needed)
//   int remainingSeconds = cookingDuration;

//   // ==== UI flags ====
//   bool _isLoading = false;

//   // ------------------------- NETWORK CALLS -------------------------

//   Future<void> fetchDHTData() async {
//     try {
//       final response = await http.get(Uri.parse("$serverUrl/dht-data"));
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           temperature = (data["temperature"] ?? 0).toDouble();
//           humidity = (data["humidity"] ?? 0).toDouble();
//         });
//       } else {
//         // don't spam UI; keep numeric values as last success
//         debugPrint("DHT error: ${response.statusCode}");
//       }
//     } catch (e) {
//       debugPrint("Error fetching DHT data: $e");
//     }
//   }

//   Future<void> fetchTemp() async {
//     try {
//       final response = await http.get(Uri.parse("$serverUrl/dht-data"));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final t = (data['temperature']).toString();
//         final h = (data['humidity']).toString();
//         setState(() {
//           _tempStatus = "Temp: $t°C, Humidity: $h%";
//         });
//       } else {
//         setState(() => _tempStatus = "Error: ${response.statusCode}");
//       }
//     } catch (e) {
//       setState(() => _tempStatus = "Error: $e");
//     }
//   }

//   Future<void> fetchIRStatus() async {
//     try {
//       final response = await http.get(Uri.parse("$serverUrl/detection"));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           _irStatus = data["status"] == "detected" ? "HIGH" : "LOW";
//         });
//       } else {
//         setState(() => _irStatus = "Error: ${response.statusCode}");
//       }
//     } catch (e) {
//       setState(() => _irStatus = "Error: $e");
//     }
//   }

//   Future<void> toggleLED(bool state) async {
//     // start countdown on turning ON
//     if (state) startTimer();
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
//       debugPrint("toggleLED error: $e");
//     }
//   }

//   Future<void> fetchLEDStatus() async {
//     try {
//       final response = await http.get(Uri.parse("$serverUrl/status"));
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           ledState = data["state"] ?? false;
//         });
//       }
//     } catch (e) {
//       debugPrint("fetchLEDStatus error: $e");
//     }
//   }

//   // ------------------------- TIMERS -------------------------

//   void startIRPolling() {
//     _irTimer?.cancel();
//     _irTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       // Uncomment to auto-poll
//       // fetchIRStatus();
//     });
//   }

//   void startTimer() {
//     // Cancel existing countdown if any
//     _countdownTimer?.cancel();

//     setState(() {
//       isCooking = true;
//       remainingSeconds = cookingDuration;
//     });

//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (!mounted) return;
//       setState(() {
//         if (remainingSeconds > 1) {
//           remainingSeconds--;
//         } else {
//           timer.cancel();
//           isCooking = false;
//           // Optionally turn off LED when done:
//           // toggleLED(false);
//           // Optionally show a dialog/toast, etc.
//         }
//       });
//     });
//   }

//   // ------------------------- TTS / SPEECH -------------------------

//   Future<void> _setupTts() async {
//     // Try to select a stable GB English voice if available
//     try {
//       final voices = await _tts.getVoices;
//       final gbVoice = (voices as List)
//           .cast<Map>()
//           .firstWhere(
//             (v) => (v["locale"]?.toString().toLowerCase() == "en-gb"),
//             orElse: () => {"name": "en-gb-x-gba-local", "locale": "en-GB"},
//           );
//       await _tts.setVoice({"name": gbVoice["name"], "locale": "en-GB"});
//     } catch (_) {
//       // fallback
//       await _tts.setVoice({"name": "en-gb-x-gba-local", "locale": "en-GB"});
//     }

//     await _tts.setSpeechRate(0.5);
//     await _tts.setPitch(1.2);
//     await _tts.setVolume(1.0);
//   }

//   void _listAvailableVoices() async {
//     var voices = await _tts.getVoices;
//     debugPrint("Available voices: $voices");
//   }

//   void _startListening(String mode) async {
//     bool available = await _speech.initialize(
//       onStatus: (status) => debugPrint("Speech status: $status"),
//       onError: (error) => debugPrint("Speech error: $error"),
//     );
//     if (available) {
//       setState(() => _isListening = true);
//       _speech.listen(onResult: (result) {
//         setState(() {
//           _userText = result.recognizedWords;
//         });
//         if (result.finalResult) {
//           final lower = _userText.toLowerCase();
//           if (mode == "main") _respondToUser(lower);
//           if (mode == "ir") _respondToUserB(lower);
//           if (mode == "temp") _respondToUserA(lower);
//         }
//       });
//     }
//   }

//   // ------------------------- DIALOG FLOWS -------------------------

//   void _respondToUser(String command) async {
//     String reply = "Hmm, I didn’t catch that. Could you say it again?";

//     // Stage 0: Waiting for start command
//     if (_conversationStage == 0 && command.contains("start cooking")) {
//       reply =
//           "Chef Bot here! Before we start, have you added water to container C and oil to container D?";
//       _conversationStage = 1;
//     }

//     // Stage 1: Water & oil confirmation
//     else if (_conversationStage == 1 && command.contains("yes")) {
//       reply =
//           "Lovely! Now, have you added the indomie noodles plus seasoning to container A, and onion plus sliced tomato to container B?";
//       _conversationStage = 2;
//     }

//     // Stage 2: Check ingredients with IR sensor
//     else if (_conversationStage == 2 && command.contains("yes")) {
//       reply = "Perfecto! Do you want me to start cooking now?";
//       _conversationStage = 3;
//     }

//     // Stage 3: Start cooking confirmation
//     else if (_conversationStage == 3 && command.contains("yes")) {
//       reply =
//           "Fantastic! Starting the cooking process. Sit back, relax, and let the aroma take over!";
//       _conversationStage = 0;
//       toggleLED(true); // trigger cooking
//     }

//     // "No" response at any stage
//     else if (command.contains("no")) {
//       reply =
//           "Alright, I’ll be waiting here in the kitchen. Just say 'Start cooking Indomie' when you’re ready.";
//       _conversationStage = 0;
//     }

//     await _tts.speak(reply);
//   }

//   void _respondToUserB(String command) async {
//     String reply = "Hmm, I didn’t catch that. Could you say it again?";

//     if (command.contains("check")) {
//       reply = "Let me check if the ingredients are in place...";
//       await _tts.speak(reply);
//       await _checkIngredientsAndContinue();
//       return; // prevent speaking twice
//     }

//     await _tts.speak(reply);
//   }

//   void _respondToUserA(String command) async {
//     String reply = "Hmm, I didn’t catch that. Could you say it again?";

//     if (command.contains("check")) {
//       reply = "Checking the temperature and humidity now...";
//       await _tts.speak(reply);
//       await _checkTemp();
//       return;
//     }

//     await _tts.speak(reply);
//   }

//   // ------------------------- HELPERS -------------------------

//   // Auto-check IR once and speak results
//   Future<void> _checkIngredientsAndContinue() async {
//     await fetchIRStatus();

//     if (_irStatus == "HIGH") {
//       await _tts.speak("Perfecto! Your ingredients are in place!");
//     } else if (_irStatus == "LOW") {
//       await _tts.speak(
//           "Hmm, it looks like some ingredients are missing. Please add everything into the right containers.");
//     } else {
//       await _tts.speak("I couldn't determine the IR status. Please try again.");
//     }
//   }

//   Future<void> _checkTemp() async {
//     await fetchTemp();
//     await _tts.speak(_tempStatus);
//   }

//   // ------------------------- LIFECYCLE -------------------------

//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//     _tts = FlutterTts();

//     _setupTts();
//     _listAvailableVoices();

//     // initial fetch
//     fetchDHTData();
//     fetchLEDStatus();

//     // periodic DHT refresh
//     _dhtTimer = Timer.periodic(const Duration(seconds: 2), (_) => fetchDHTData());

//     // Optional IR polling (kept off by default)
//     // startIRPolling();
//   }

//   @override
//   void dispose() {
//     _dhtTimer?.cancel();
//     _irTimer?.cancel();
//     _countdownTimer?.cancel();
//     _speech.stop();
//     _tts.stop();
//     super.dispose();
//   }

//   // ------------------------- UI -------------------------

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text(
//           "🤖 Chef Bot Assistant",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.black87,
//         elevation: 6,
//         shadowColor: Colors.black54,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Robot Status
//               Card(
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                 elevation: 6,
//                 shadowColor: Colors.black45,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
//                   child: Column(
//                     children: [
//                       Icon(
//                         ledState ? Icons.lightbulb : Icons.lightbulb_outline,
//                         size: 60,
//                         color: ledState ? Colors.green[600] : Colors.grey,
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         ledState ? "Power: ON" : "Power: OFF",
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: ledState ? Colors.green[800] : Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       if (isCooking) ...[
//                         Text(
//                           "Cooking... ${remainingSeconds}s",
//                           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 25),

//               // Temperature & Humidity Card
//               Card(
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                 elevation: 6,
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(Icons.thermostat, size: 30),
//                           const SizedBox(width: 8),
//                           Text(
//                             "Temperature: ${temperature.toStringAsFixed(1)} °C",
//                             style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(Icons.water_drop, size: 30),
//                           const SizedBox(width: 8),
//                           Text(
//                             "Humidity: ${humidity.toStringAsFixed(1)} %",
//                             style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: fetchTemp,
//                         child: const Text("Check Temperature"),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         "Temperature Status: $_tempStatus",
//                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 25),

//               // Speech buttons
//               ElevatedButton.icon(
//                 onPressed: () => _startListening("temp"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.amber[600],
//                   foregroundColor: Colors.black,
//                   padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                   elevation: 6,
//                 ),
//                 icon: const Icon(Icons.mic, size: 28),
//                 label: const Text(
//                   "Speak: Temperature",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               const SizedBox(height: 20),

//               ElevatedButton.icon(
//                 onPressed: () => _startListening("ir"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.amber[600],
//                   foregroundColor: Colors.black,
//                   padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                   elevation: 6,
//                 ),
//                 icon: const Icon(Icons.mic, size: 28),
//                 label: const Text(
//                   "Speak: IR Check",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: fetchIRStatus,
//                 child: const Text("Check IR Now"),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 "IR Status: $_irStatus",
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 25),

//               // User command / suggestions
//               Text(
//                 _userText.isEmpty ? "💬 Say something like: Start cooking Indomie" : _userText,
//                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
//                 textAlign: TextAlign.center,
//               ),

//               if (_isLoading) ...[
//                 const SizedBox(height: 20),
//                 const CircularProgressIndicator(),
//               ],

//               const SizedBox(height: 40),

//               // Main voice button
//               ElevatedButton.icon(
//                 onPressed: () => _startListening("main"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.amber[600],
//                   foregroundColor: Colors.black,
//                   padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                   elevation: 6,
//                 ),
//                 icon: const Icon(Icons.mic, size: 28),
//                 label: const Text(
//                   "Speak: Main Flow",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // Shutdown Button
//               ElevatedButton.icon(
//                 onPressed: () {
//                   toggleLED(false);
//                   debugPrint("Shutdown pressed");
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black87,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                   elevation: 6,
//                 ),
//                 icon: const Icon(Icons.power_settings_new, size: 28),
//                 label: const Text(
//                   "Shutdown",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


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


// Future<void> fetchTemp() async {
//   try {
//     final response = await http.get(Uri.parse("https://motobackend.onrender.com/dht-data"));
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       setState(() {
//         _status = "Temp: ${data['temperature']}°C, Humidity: ${data['humidity']}%";
//       });
//     } else {
//       setState(() => _status = "Error: ${response.statusCode}");
//     }
//   } catch (e) {
//     setState(() => _status = "Error: $e");
//   }
// }

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
    remainingSeconds = 600; // ✅ 10 minutes (600 seconds)
  });

  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    setState(() {
      if (remainingSeconds > 1) {
        remainingSeconds--;
      } else {
        timer.cancel();
        isCooking = false;
        ledState = false; // ✅ Ensure toggle is set to false
        toggleLED(false); // ✅ Actually send shutdown to backend

        // ✅ Show completion dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color(0xFF2C2C2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Done Cooking!',
                style: TextStyle(color: Colors.yellow[700]),
              ),
              content: Text(
                'Your cooking process is complete.',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(color: Colors.yellow[700]),
                  ),
                ),
              ],
            );
          },
        );

        // ✅ Optionally also use voice feedback
        _tts.speak("Cooking is complete. Please enjoy your meal!");
      }
    });
  });
}


// void startTimer() {
//   setState(() {
//     isCooking = true;
//     remainingSeconds = 100; // Reset timer each time
//   });

//   _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//     setState(() {
//       if (remainingSeconds > 1) {
//         remainingSeconds--;
//       } else {
//         timer.cancel();
//         isCooking = false; // Show "Start Cooking" again
//         // toggleLED(false);

//         // // ✅ Show completion dialog here
//         // showDialog(
//         //   context: context,
//         //   barrierDismissible: false,
//         //   builder: (BuildContext context) {
//         //     return AlertDialog(
//         //       backgroundColor: Color(0xFF2C2C2E),
//         //       shape: RoundedRectangleBorder(
//         //         borderRadius: BorderRadius.circular(16),
//         //       ),
//         //       title: Text(
//         //         'Done Cooking!',
//         //         style: TextStyle(color: Colors.yellow[700]),
//         //       ),
//         //       content: Text(
//         //         'Your cooking process is complete.',
//         //         style: TextStyle(color: Colors.white70),
//         //       ),
//         //       actions: [
//         //         TextButton(
//         //           onPressed: () {
//         //             Navigator.of(context).pop(); // Close the dialog
//         //           },
//         //           child: Text(
//         //             'OK',
//         //             style: TextStyle(color: Colors.yellow[700]),
//         //           ),
//         //         ),
//         //       ],
//         //     );
//         //   },
//         // );
//       }
//     });
//   });
// }

  

  @override
  void initState() {
    super.initState();
    fetchDHTData();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();

    _setupTts();
    _listAvailableVoices(); // Just to check what voices your device supports
  
    // _timer = Timer.periodic(Duration(seconds: 2), (_) => fetchDHTData());
    // _timer = Timer.periodic(Duration(seconds: 2), (_) => fetchIRStatus());
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
      "locale": "en-GB"
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
// void _startListeningB() async { bool available = await _speech.initialize( onStatus: (status) => print("Speech status: $status"), onError: (error) => print("Speech error: $error"), ); if (available) { setState(() => _isListening = true); _speech.listen(onResult: (result) { setState(() { _userText = result.recognizedWords; }); if (result.finalResult) { _respondToUserB(_userText.toLowerCase()); } }); } }
// void _startListeningA() async { bool available = await _speech.initialize( onStatus: (status) => print("Speech status: $status"), onError: (error) => print("Speech error: $error"), ); if (available) { setState(() => _isListening = true); _speech.listen(onResult: (result) { setState(() { _userText = result.recognizedWords; }); if (result.finalResult) { _respondToUserA(_userText.toLowerCase()); } }); } }



  // void _stopListening() {
  //   _speech.stop();
  //   setState(() => _isListening = false);
  // }

  void _respondToUser(String command) async {
  String reply = "Hmm, I didn’t catch that. Could you say it again?";

  // Stage 0: Waiting for start command
  if (_conversationStage == 0 && command.contains("start cooking")) {
    reply = "Chef Bot here! Before we start, have you added water to container C and oil to container D?";
    _conversationStage = 1;
  }

   else if (command.contains("check")) {
    reply = "Let me check if the ingredients are in place...";
    
    await _tts.speak(reply);
    _checkIngredientsAndContinue();
    return; // prevent speaking twice
    
  }

  else if (command.contains("one")) {
    reply = "Let me check if everything is in place...";
    
    await _tts.speak(reply);
    _checkTemp();
    return; // prevent speaking twice
    
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
    toggleLED(false);
    startTimer();
  }

  // "No" response at any stage
  else if (command.contains("no")) {
    reply = "Alright, I’ll be waiting here in the kitchen. Just say 'Start cooking Indomie' when you’re ready.";
    _conversationStage = 0;
  }

  await _tts.speak(reply);
}

// Auto-check IR status until ingredients are detected
Future<void> _checkIngredientsAndContinue() async{

  await  fetchIRStatus();

  if (_status == "HIGH") {

    
      await _tts.speak("Perfecto! Your ingredients are in place!");
      // return;
    }

 else {
  await _tts.speak("Hmm, it looks like some ingredients are missing. Please add everything into the right containers.");
      
    }


  
}


Future<void> _checkTemp() async{

     await fetchDHTData();

      await _tts.speak('${temperature.toString()} degree celcius');
     
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: Colors.grey[50],
  appBar: AppBar(
    title: Text(
      "🤖 Chef Bot Assistant",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
    ),
    centerTitle: true,
    backgroundColor: Colors.black87,
    elevation: 8,
    shadowColor: Colors.black45,
  ),
  body: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // === Power Status Card ===
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 6,
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    ledState ? Icons.power : Icons.power_off,
                    size: 70,
                    color: ledState ? Colors.green[600] : Colors.red[400],
                  ),
                  SizedBox(height: 12),
                  Text(
                    ledState ? "Cooking in Progress" : "Standby",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: ledState ? Colors.green[800] : Colors.red[600],
                    ),
                  ),
                  if (isCooking) ...[
                    SizedBox(height: 16),
                    Text(
                      "⏳ ${Duration(seconds: remainingSeconds).inMinutes}:${(remainingSeconds % 60).toString().padLeft(2, '0')}",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Time Remaining",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ]
                ],
              ),
            ),
          ),

          SizedBox(height: 25),

          // === Environment Sensors Card ===
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 6,
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "📊 Environment Status",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.thermostat, color: Colors.orange, size: 36),
                          SizedBox(height: 6),
                          Text(
                            "${temperature.toStringAsFixed(1)} °C",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          Text("Temp", style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.water_drop, color: Colors.blue, size: 36),
                          SizedBox(height: 6),
                          Text(
                            "${humidity.toStringAsFixed(1)} %",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          Text("Humidity", style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.sensors, color: Colors.deepPurple, size: 36),
                          SizedBox(height: 6),
                          Text(
                            _status,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          Text("IR Sensor", style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 25),

          // === User Command Feedback ===
          Card(
            color: Colors.amber[50],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _userText.isEmpty
                    ? "💬 Say something like: Start cooking Indomie"
                    : _userText,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          if (_isLoading) ...[
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],

          SizedBox(height: 40),

          // === Voice Command Button ===
          ElevatedButton.icon(
            onPressed: _startListening,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 6,
            ),
            icon: Icon(Icons.mic, size: 28),
            label: Text(
              "Start Talking",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: 20),

          // === Shutdown Button ===
          ElevatedButton.icon(
            onPressed: () {
              toggleLED(false);
              print("Shutdown pressed");
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 6,
            ),
            icon: Icon(Icons.power_settings_new, size: 28, color: Colors.redAccent),
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
