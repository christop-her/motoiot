import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moto/verifyemail.dart';
import 'package:moto/ipconfig.dart';


class signUp extends StatefulWidget {

  
  const signUp({super.key});

  @override
  State<signUp> createState() => _signUpState();
}

class _signUpState extends State<signUp> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cpasswordController = TextEditingController();

  String address = 'Not available';
  double latitude = 0.0;
  double longitude = 0.0;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  bool onLoading = false;

  void _showToast(String message, bool isError) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _agreeToTerms){
      setState(() {
        _isLoading = true;
      });

      // Simulating a network request
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // Here, you would send data to your backend
      requestCode();
      
    }
     else if (!_agreeToTerms) {
      _showToast("Please agree to the terms and conditions", true);
    }
  }

  String? _validate(String? value){
    if(value == null || value.isEmpty){
      return "This field is required";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters long";
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Password must contain at least one uppercase letter";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Password must contain at least one number";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Confirm Password is required";
    }
    if (value != passwordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

   void requestCode() async {
  if (_formKey.currentState!.validate()) {
setState(() {
  _isLoading = true;
});
  final response = await http.post(
    Uri.parse('http://$ipconfig:3000/send_email_code'),
    body: json.encode({
      'email': emailController.text,
      }),
    headers: {'Content-Type': 'application/json'},
  );
setState(() {
  _isLoading = false;
});
  if (response.statusCode == 200) {
    // _showToast("Sign-up successful!", false);
    Navigator.push(context, MaterialPageRoute(builder: (context) => Verifyemail(dataEmail: emailController.text, dataAddress: address, dataName: nameController.text, dataPassword: passwordController.text, datacPassword: cpasswordController.text, dataLatt: latitude.toString(), dataLong: longitude.toString())));
    print('code sent.');
  } else {
    print('Error: ${response.body}');
  }
}
 }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("WELCOME", style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 16),
              // Email Field
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              SizedBox(height: 16),

              // Username Field
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Username is required";
                  }
                  if (value.length < 4) {
                    return "Username must be at least 4 characters long";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                obscureText: true,
                validator: _validatePassword,
              ),
              SizedBox(height: 16),

              // Confirm Password Field
              TextFormField(
                controller: cpasswordController,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                obscureText: true,
                validator: _validateConfirmPassword,
              ),
              SizedBox(height: 24),

               // Terms and Conditions Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _agreeToTerms = !_agreeToTerms;
                          });
                        },
                        child: Text(
                          "I agree to the terms and conditions",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
