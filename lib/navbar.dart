import 'package:flutter/material.dart';
import 'package:moto/LightControlScreen.dart';
import 'package:moto/homescreen.dart';
import 'package:moto/recipelist.dart';




class NavBar extends StatefulWidget {
  @override
  NavBarState createState() => NavBarState();
}

class NavBarState extends State<NavBar> { 

  final _pages = [
    RecipeScreen(),
    // SmartScreen(),
    VoiceChatScreen()
    // LightControlScreen(),
    // firstPage_2(),
    // Selectstore(),
    // umessage_tab_all(),
    // ProfileScreen(),

  ];

  var _currentIndex = 0;

  @override
 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 247, 247),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue.shade900,
        backgroundColor: Color.fromARGB(255, 247, 247, 247),
        unselectedItemColor: Colors.green.shade900,
        currentIndex: _currentIndex,
        selectedLabelStyle:
        TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        items: [

           BottomNavigationBarItem(
            label: 'Select',
            icon: Icon(Icons.food_bank)
          ),
          
          BottomNavigationBarItem(
            label: 'Voice',
            icon: Icon(Icons.gamepad_rounded)
          ),
          // BottomNavigationBarItem(
          //   label: 'GPS Tracker',
          //   icon: Icon(Icons.location_on)
          // ),

         
     
          
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: _pages[_currentIndex],
    );
  }
}
