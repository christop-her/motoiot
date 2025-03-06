import 'package:flutter/material.dart';
import 'package:moto/ipconfig.dart';
import 'package:moto/login.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class Verifyemail extends StatefulWidget {
  final String dataName;
  final String dataEmail;
  final String dataPassword; 
  final String datacPassword;
  final String dataLatt; 
  final String dataLong; 
  final String dataAddress; 
  const Verifyemail({super.key, required this.dataName, required this.dataEmail, required this.dataLatt, required this.dataLong, required this.dataAddress, required this.dataPassword, required this.datacPassword});

  @override
  State<Verifyemail> createState() => _VerifyemailState();
}

class _VerifyemailState extends State<Verifyemail> {
 String verifypin = '';
 bool isLoading = false;



  Future<void> signUp() async {
  setState(() {
    isLoading = true;
  });
 final url = Uri.parse("http://$ipconfig/apisocial/signup.php");

  var request = http.MultipartRequest('POST', url);
  request.fields['address_locality'] = widget.dataAddress;
  request.fields['name'] = widget.dataName;
  request.fields['email'] = widget.dataEmail;
  request.fields['password'] = widget.dataPassword;
  request.fields['cpassword'] = widget.datacPassword;
  request.fields['lattitude'] = widget.dataLatt;
  request.fields['longitude'] = widget.dataLong;

  print("Request prepared: ${request.fields}");

  // if (_image != null) {
  //   var pic = await http.MultipartFile.fromPath("image_01", _image!.path);
  //   request.files.add(pic);
  // }

      var response = await request.send();
setState(() {
  isLoading = false;
});
      if (response.statusCode == 200) {
       
        var responseData = await response.stream.bytesToString();
        print('account already exist $responseData');
        var jsonResponse = json.decode(responseData);
        if (jsonResponse['success'] == 'account already exist') {
          print('account already exist');
        } else {
           _showSuccessDialog(context,'Success','Your account has been \n successfully registerd');
          
        }
      } else {
        print('request failed with status: ${response.statusCode}');
         _unSuccessDialog(context,'Unsuccessful','try to login');
      }
    
  
}
  void verifyCode(String resetCode) async {
    setState(() {
      isLoading = true;
    });
     print('Error: $resetCode, ${widget.dataEmail}');
  final response = await http.post(
    Uri.parse('http://$ipconfig:3000/verify_code'),
    body: json.encode({
      'email': widget.dataEmail, 
      'resetCode': resetCode,
      }),
    headers: {'Content-Type': 'application/json'},
  );
   setState(() {
     isLoading = false;
   });
  if (response.statusCode == 200) {
    print('Code verified');
    await signUp();

    // Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPassword(dataUrl: widget.dataUrl)));
  } else {
    _unSuccessDialog(context, 'Invalid or expired code ', 'unsuccessful');
    print('Error: ${response.body}');
  }
}

void _showSuccessDialog(BuildContext context,String text,String body) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set background color to white
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Optional: make it a square
          ),
          content: SizedBox(
            height: 290.0, // Adjust the height
            width: 200.0, // Adjust the width to make it a square
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.check,
                      color: Color(0xFF010043),
                      size: 50.0, // Adjust the size if needed
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Registration $text',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,

                  ),
                ),
                const SizedBox(height: 5.0),

                Text(
                  body,
                  style: TextStyle(
                    fontSize: 18.0,
                      color: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF010043), // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) =>  mobilefirstPage_2()));
                  },
                  child: const Text('Login now',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


void _unSuccessDialog(BuildContext context,String text,String body) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), 
          ),
          content: SizedBox(
            height: 290.0,
            width: 200.0, 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.check,
                      color: Color(0xFF010043),
                      size: 50.0, 
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  '$text',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,

                  ),
                ),
                const SizedBox(height: 5.0),

                Text(
                  body,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey.shade300,
                  ),
                ),


              ],
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Verification Pin'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF010043)),
              ),
            )
          :
           Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter the 5-digit code sent to your email',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Pinput(
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration?.copyWith(
                  border: Border.all(color: Colors.grey),
                ),
              ),
              onCompleted: (pin) {
                // Handle pin completion
                debugPrint('Entered PIN: $pin');
                
                setState(() {
                  verifypin = pin;
                  print('Entered PIN: $verifypin');
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Submit the verification code
                debugPrint('Verify button pressed');
                verifyCode(verifypin);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              ),
              child: const Text(
                'Verify',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
