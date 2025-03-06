import 'dart:convert';
// import 'package:mini/responsivity/forgotpassword.dart';
import 'package:moto/ipconfig.dart';
import 'package:moto/navbar.dart';
import 'package:moto/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;


class mobilefirstPage_2 extends StatefulWidget {
  const mobilefirstPage_2({super.key});

  @override
  State<mobilefirstPage_2> createState() => _mobilefirstPage_2State();
}

class _mobilefirstPage_2State extends State<mobilefirstPage_2> {
  bool obscuretext = true;
  bool isRememberMeChecked = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController= TextEditingController();

 void _showToast(String message, bool isError) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> logIn() async{
    try {

      if (_formKey.currentState!.validate()){
    setState(() {
      _isLoading = true;
    });
     var url = "http://$ipconfig/apisocial/user_login.php";
    var response = await http.post(Uri.parse(url),
    body: {
        'email': emailController.text,
        'password': passwordController.text,
    }
    );
    setState(() {
      _isLoading = false;
    });
   if(response.statusCode == 200){
    var jsonResponse = json.decode(response.body);
    if(jsonResponse['success'] == 'login successful'){
     print('login successful');

     SharedPreferences preferences = await SharedPreferences.getInstance();
     preferences.setString('email', emailController.text);
     
     Navigator.push(context, MaterialPageRoute(builder: (context) => NavBar()));
    }else{
      _showToast("Incorrect Email or Password.", true);
    print('not successful');
   }
   }else{
    print('request failed with status: ${response.statusCode}');
   }
  }

    } catch (e) {
       _showToast("Network is unreachable, Check your connection.", true);
       setState(() {
         _isLoading = false;
       });
    }
    
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

  
  @override
  void initState(){
    super.initState();
  }
  
 Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 120),
            Center(
              child: Text(
                "Login",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              height: 550,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                       TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                                ),
                      const SizedBox(height: 20),
                    
                              TextFormField(
                                
                  controller: passwordController,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                              icon: Icon(
                                obscuretext ? Icons.visibility_off : Icons.visibility,
                                size: 20,
                              ),
                              onPressed: () => setState(() => obscuretext = !obscuretext),
                            ),
                    labelText: "Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  obscureText: obscuretext,
                  validator: _validatePassword,
                                ),
                  
                      const SizedBox(height: 10),
                      // Remember Me Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: isRememberMeChecked,
                            onChanged: (value) {
                              isRememberMeChecked = value!;
                            },
                            activeColor: const Color(0xFF010043),
                          ),
                          const Text(
                            "Remember Me",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Login Button
                      Center(
                        child: // Submit Button
                                ElevatedButton(
                  onPressed:  logIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 120),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          "Sign In",
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                                ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const signUp()));
                            },
                            child: Text('New user?Signup')),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPassword()));
                            },
                            child: Text('Forgot password?')),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


