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

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print("Speech status: $status"),
      onError: (error) => print("Speech error: $error"),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _userText = result.recognizedWords;
        });

        if (result.finalResult) {
          _respondToUser(_userText.toLowerCase());
        }
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _respondToUser(String command) async {
    String reply = "I didn't understand that.";

    if (command.contains("get 2k")) {
      reply = "Okay, turning the LED on.";
    } else if (command.contains("turn off")) {
      reply = "Alright, turning the LED off.";
    } else if (command.contains("hello")) {
      reply = "Hi there! How can I help you today?";
    }

    // Speak the reply
    await _tts.speak(reply);
  }

// void _respondToUser(String command) async {
//     String reply = "I didn't understand that.";

//     if (command.contains("turn on")) {
//       reply = "Okay, turning the LED on.";
//     } else if (command.contains("turn off")) {
//       reply = "Alright, turning the LED off.";
//     } else if (command.contains("hello")) {
//       reply = "Hi there! How can I help you today?";
//     }

//     // Speak the reply
//     await _tts.speak(reply);
//   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Voice Chat")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_userText.isEmpty ? "Say something..." : _userText,
                style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
              label: Text(_isListening ? "Stop" : "Start Talking"),
              onPressed: _isListening ? _stopListening : _startListening,
            ),
          ],
        ),
      ),
    );
  }
}
