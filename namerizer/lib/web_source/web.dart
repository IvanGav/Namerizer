import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import "../util/cloudStorage.dart";
import "../firebase_options.dart";

class WebApp extends StatelessWidget {
  const WebApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.calistogaTextTheme(), // Use your desired font here
      ),
      home: const WebHome(),
    );
  }
}

class WebHome extends StatefulWidget {
  const WebHome({super.key});
  @override
  State<WebHome> createState() => _WebHomeState();
}


/*=====================================================
  Home Page where user input class code to join a class
  =====================================================*/ 
class _WebHomeState extends State<WebHome> {
  TextEditingController classCodeController = TextEditingController(); 
  String? error;

  void _goToVerifyPage() {
    String classCode = classCodeController.text; 
    if (classCode.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VerifyPage(classCode: classCode),
        ),
      );
    } 
    else {setState(() {error = "Code Doen't Exist";});}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          /*_______Backround Image_______*/
          Positioned(
            top: 0, left: 0, right: 0, bottom: 0,
            child: Image.asset('images/background.jpg', fit: BoxFit.cover),
          ),
          /*_______(Logo, Name, Underline) dispayed_______*/
          Positioned(
            left: (MediaQuery.of(context).size.width - 400) / 2,
            top: 50, height: 400, width: 400,
            child: Column(
              children: [
                Image.asset('images/logo.png'),
                Text('Namerizer', style: TextStyle(fontSize: 30, color: Colors.white,)),
                Container(width: 300, height:2, color:Colors.white)
              ],
            ),
          ),
          /*_______Class Code TextField_______*/ 
          Positioned(
            left: (MediaQuery.of(context).size.width - 300) / 2,
            right: (MediaQuery.of(context).size.width - 300) / 2,
            bottom: 350,
            child: TextField(
              controller: classCodeController, // Use the controller to capture input
              cursorColor: Colors.black,
              style: TextStyle(color: Colors.black, fontSize: 18),
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white,                  // textfield color
                hintText: "Enter Class Code",
                errorText: error,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 3,color: Colors.black), // border color & width
                  borderRadius: BorderRadius.circular(10)               // border shape
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 3, color: Colors.red),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          /*_______Submit Button_______*/
          Positioned(
            left: (MediaQuery.of(context).size.width - 400) / 2,
            right: (MediaQuery.of(context).size.width - 400) / 2,
            bottom: 125, height: 50,
            child: InkWell(
              onTap: _goToVerifyPage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('images/green_button.png'),
                  Text('Submit',style: TextStyle(fontSize: 20, color: Colors.white,)),
                ],
              ),
            )
          ),

        ], 
      ),
    ); 
  } 
}


/*===================================================================
  Verify Page Where Website Dispays The Class They Are Connecting To 
  ===================================================================*/ 
class VerifyPage extends StatelessWidget {
  VerifyPage({Key? key, required this.classCode}) : super(key: key);
  final String classCode;


  void _goToSubmitInfoPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubmitInfoPage(classCode: classCode),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /*_______Backround Image_______*/
          Positioned(
            top: 0, left: 0, right: 0, bottom: 0,
            child: Image.asset('images/background.jpg', fit: BoxFit.cover),
          ),
          /*_______(Logo, Name, Underline) Dispayed_______*/
          Positioned(
            left: (MediaQuery.of(context).size.width - 400) / 2,
            top: 50, height: 400, width: 400,
            child: Column(
              children: [
                Image.asset('images/logo.png'),
                Text('Namerizer', style: TextStyle(fontSize: 30, color: Colors.white,)),
                Container(width: 300, height:2, color:Colors.white)
              ],
            ),
          ),
          /*_______Class Verify Info Text_______*/ 
          /*_______Yes Button_______*/
          Positioned(
            left: (MediaQuery.of(context).size.width - 50) / 2,
            right: (MediaQuery.of(context).size.width - 400) / 2,
            bottom: 125, height: 40,
            child: InkWell(
              onTap: () => _goToSubmitInfoPage(context),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('images/green_button.png'),
                  Text('Yes',style: TextStyle(fontSize: 20, color: Colors.white,)),
                ],
              ),
            )
          ),
          /*_______No Button_______*/
          Positioned(
            left: (MediaQuery.of(context).size.width - 400) / 2,
            right: (MediaQuery.of(context).size.width - 50) / 2,
            bottom: 125, height: 40,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(), //goes back to home page
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('images/red_button.png'),
                  Text('No',style: TextStyle(fontSize: 20, color: Colors.white,)),
                ],
              ),
            )
          ),

        ],
      ),
    );
  }
}


/*========================================================
  Submit Info Page where User Submits their Info To Class 
  ========================================================*/ 
class SubmitInfoPage extends StatelessWidget {
  TextEditingController firstNameController = TextEditingController(); 
  TextEditingController lastNameController = TextEditingController(); 
  TextEditingController preferedNameController = TextEditingController(); 

  SubmitInfoPage({Key? key, required this.classCode}) : super(key: key);
  final String classCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /*_______Background Image_______*/
          Positioned(
            top: 0, left: 0, right: 0, bottom: 0,
            child: Image.asset('images/background.jpg', fit: BoxFit.cover,),
          ),
          /*_______Class Name & Underline_______*/
          Positioned(
            left: (MediaQuery.of(context).size.width - 400) / 2,
            top: 50, height: 400, width: 400,
            child: Column(
              children: [
                Text('Class Name', style: TextStyle(fontSize: 30, color: Colors.white)),
                Container(width: 300, height: 2, color: Colors.white)
              ],
            ),
          ),
          /*_______First Name_______*/
          Positioned(
            left: (MediaQuery.of(context).size.width - 300) / 2,
            right: (MediaQuery.of(context).size.width - 300) / 2,
            top: 110,
            child: TextField(
              controller: firstNameController, 
              cursorColor: Colors.black,
              style: TextStyle(color: Colors.black, fontSize: 15),
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white,                  
                hintText: "Enter First Name",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 3,color: Colors.black), 
                  borderRadius: BorderRadius.circular(10)              
                ),
              ),
            ),
          ),
          /*_______Last Name_______*/
          Positioned(
            left: (MediaQuery.of(context).size.width - 300) / 2,
            right: (MediaQuery.of(context).size.width - 300) / 2,
            top: 170,
            child: TextField(
              controller: lastNameController, 
              cursorColor: Colors.black,
              style: TextStyle(color: Colors.black, fontSize: 15),
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white,                  
                hintText: "Enter Last Name",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 3,color: Colors.black), 
                  borderRadius: BorderRadius.circular(10)              
                ),
              ),
            ),
          ),
          /*_______Prefered Name_______*/
          Positioned(
            left: (MediaQuery.of(context).size.width - 300) / 2,
            right: (MediaQuery.of(context).size.width - 300) / 2,
            top: 230,
            child: TextField(
              controller: preferedNameController, 
              cursorColor: Colors.black,
              style: TextStyle(color: Colors.black, fontSize: 15),
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white,                  
                hintText: "Enter Prefered Name",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 3,color: Colors.black), 
                  borderRadius: BorderRadius.circular(10)              
                ),
              ),
            ),
          ),
          /*_______Gender_______*/
          /*_______Picture_______*/
          /*_______Pronouciation_______*/
          /*_______Submit Button_______*/
          Positioned(
            left: (MediaQuery.of(context).size.width - 400) / 2,
            right: (MediaQuery.of(context).size.width - 400) / 2,
            bottom: 50, height: 50,
            child: InkWell(
              //onTap: _goToVerifyPage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('images/green_button.png'),
                  Text('Submit',style: TextStyle(fontSize: 20, color: Colors.white,)),
                ],
              ),
            )
          ),

        ],
      ),
    );
  }
}