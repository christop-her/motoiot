import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class RecipeDetailScreen extends StatefulWidget {
  final String recipeName;
  final String imageUrl;
  final String duration;
  final List<String> ingredients;
  final List<String> containerA;
  final List<String> containerB;

  const RecipeDetailScreen({
    super.key,
    required this.recipeName,
    required this.imageUrl,
    required this.duration,
    required this.ingredients,
    required this.containerA,
    required this.containerB,
  });

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {


  String irStatus = "Waiting..."; // UI text for IR status
  Timer? _irTimer;

  bool isCooking = false;
  int remainingSeconds = 100; // Change this to desired countdown duration
  Timer? _timer;


  Future<void> fetchIRStatus() async {
  final response = await http.get(Uri.parse("$serverUrl/detection"));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    setState(() {
      irStatus = data["status"] == "detected" ? "Object Detected!" : "No Object";
    });
  }
}

void startIRPolling() {
  _irTimer?.cancel();
  _irTimer = Timer.periodic(Duration(seconds: 1), (_) {
    fetchIRStatus();
  });
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
        toggleLED(false);

        // ✅ Show completion dialog here
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
                    Navigator.of(context).pop(); // Close the dialog
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
      }
    });
  });
}


bool isLoading = false;
   var productData;
  // double _lightIntensity = 65;
  // DateTime _selectedDateTime = DateTime.now();
  // String get formattedDateTime => DateFormat('EEEE, MMM d, yyyy HH:mm:ss').format(_selectedDateTime);
  // Timer? _timer;

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

  @override
  void dispose() {
    _timer?.cancel();
  _irTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.yellow[700],
        title: Text(widget.recipeName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe image
            ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Image.asset(
                widget.imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cooking Time
                  Row(
                    children: [
                      Icon(Icons.timer, color: Colors.yellow[700]),
                      SizedBox(width: 6),
                      Text(
                        widget.duration,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Ingredients
                  Text(
                    'Ingredients',
                    style: TextStyle(
                      color: Colors.yellow[700],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  ...widget.ingredients.map((item) => Text("• $item",
                      style: TextStyle(color: Colors.white70))),
                  SizedBox(height: 20),

                  // Container A
                  Text(
                    'Container A',
                    style: TextStyle(
                      color: Colors.yellow[700],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 8, bottom: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.containerA
                          .map((item) => Text("• $item",
                              style: TextStyle(color: Colors.white70)))
                          .toList(),
                    ),
                  ),

                  // Container B
                  Text(
                    'Container B',
                    style: TextStyle(
                      color: Colors.yellow[700],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.containerB
                          .map((item) => Text("• $item",
                              style: TextStyle(color: Colors.white70)))
                          .toList(),
                    ),
                  ),

                  SizedBox(height: 20),
Text(
  "IR Status: $irStatus",
  style: TextStyle(color: Colors.white, fontSize: 18),
),

                  SizedBox(height: 30),
        
                  // Action Button or Timer
                  Center(
                    child: isCooking
                        ? Column(
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.yellow[700]!),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Cooking... $remainingSeconds s',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                        : ElevatedButton.icon(
                            onPressed:(){
                              toggleLED(true);
                              startIRPolling(); // start fetching detection updates
                            } ,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow[700],
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(Icons.play_arrow),
                            label: Text('Start Cooking'),
                          ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
