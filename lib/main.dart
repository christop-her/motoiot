import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moto/LightControlScreen.dart';
import 'package:moto/login.dart';
import 'package:moto/onboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load SharedPreferences and get the stored value
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String storedValue = prefs.getString('key') ?? '1'; // Default value is 1
  SharedPreferences prefsphone = await SharedPreferences.getInstance();
  String phonen = prefsphone.getString('phone') ?? ''; // Default value is 1

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? pass;

  @override
  void initState() {
    super.initState();
    // Initialize the WebSocket service with the doctor's email
    initializeSocketConnection();
    valueint();
  }

  // Method to initialize the WebSocket connection with the stored email
  Future<void> initializeSocketConnection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email =
        prefs.getString('email') ?? ''; // Fetch email from SharedPreferences
    // WebSocketService().initSocket(email);  // Initialize the socket with the stored email
  }

  Future<void> valueint() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedValue = prefs.getString('key') ?? '1'; // Default value is 1
    SharedPreferences prefsphone = await SharedPreferences.getInstance();
    String phonen = prefsphone.getString('phone') ?? ''; // Default value is 1
    setState(() {
      pass = prefsphone.getString('key') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
   
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MOTO',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            // home: pass == '2' ? const mobilefirstPage_2() : const Screen1(),
            home: LightControlScreen(),
          );
        }
}