import 'package:cloud_firestore/cloud_firestore.dart';
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import "../util/cloudStorage.dart";
import "../firebase_options.dart";
import "../util/student.dart";


class WebApp extends StatelessWidget {
  const WebApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.calistogaTextTheme(), 
        inputDecorationTheme: InputDecorationTheme(
          filled: true, fillColor: Colors.white,
          errorStyle: TextStyle(color: Colors.red),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Colors.red.shade900),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      home: const WebHome(),
    );
  }
}

/*=====================================================
  Home Page where user input class code to join a class
  =====================================================*/
class WebHome extends StatefulWidget {
  const WebHome({super.key});
  @override
  State<WebHome> createState() => _WebHomeState();
}
 
class _WebHomeState extends State<WebHome> {
  final classCodeController = TextEditingController(); 
  bool _loading = false;
  String? error;

  void _goToVerifyPage() async{
    String classCode = classCodeController.text;
    if (classCode.isEmpty){setState((){error = "Please Enter A Code";}); return;}
    setState((){_loading = true;});

    /* gets the class & proff name from code */
    String? className = await CloudStorage().getClassName(classCode);
    String? proffName = await CloudStorage().getClassProfessor(classCode);
    if (className == null){
      setState((){error = "Class Not Found";});
      setState(() {_loading = false;}); 
      return;
    }

    /* goes to next page */
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VerifyPage(
          classCode: classCode, 
          className: className,
          proffName: proffName
        ),
      ),
    );

    setState(() {_loading = false;});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container( 
        height: double.infinity, width: double.infinity,
        /*_______backround image_______*/
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        /*_______main structure_______*/
        child: SingleChildScrollView(child: Column(
          children: [
            /*_______(Logo, Name, Underline) displayed_______*/
            SizedBox(height: 20),
            Image.asset('images/logo.png'),
            Text('Namerizer', style: TextStyle(fontSize: 30, color: Colors.white)),
            Container(width: 300, height: 2, color: Colors.white),
            /*_______Class Code Text Field_______*/
            SizedBox(height: 180),
            Container(
              width: 300,
              child: TextField(
                controller: classCodeController,
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black, fontSize: 18),
                decoration: InputDecoration(
                  hintText: "Enter Class Code",
                  errorText: error
                )
              )
            ),
            /*_______Submit Button_______*/
            SizedBox(height: 180),
            ElevatedButton(
              onPressed: _loading ? null : _goToVerifyPage,
              child: _loading
                ? CircularProgressIndicator(color: Colors.white)
                : Text("Submit", style: TextStyle(fontSize: 22)),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(170, 60),
                primary: Colors.green,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: Colors.black, width: 2) 
                )             
              )
            ),
            SizedBox(height: 50),  
            
          ]
      ))
      ),

    );
  }
}

/*===================================================================
  Verify Page Where Website Dispays The Class They Are Connecting To 
  ===================================================================*/ 
class VerifyPage extends StatelessWidget {
  VerifyPage({Key? key, required this.classCode, required this.className, required this.proffName}) : super(key: key);
  final String classCode;
  final String? className;
  final String? proffName;


  void _goToSubmitInfoPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubmitInfoPage(
          classCode: classCode, 
          className: className,
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity, width: double.infinity,
        /*_______backround image_______*/
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(child: Column(
          children: [
            /*_______(Logo, Name, Underline) Dispayed_______*/
            SizedBox(height: 20),
            Image.asset('images/logo.png'),
            Text('Namerizer', style: TextStyle(fontSize: 30, color: Colors.white,)),
            Container(width: 300, height:2, color:Colors.white),
            /*______Prints Class Name & Proff Name_______*/
            SizedBox(height: 120),
            Text("Is This Your Class?", style: TextStyle(fontSize: 20, color: Colors.white)),
            SizedBox(height: 10),
            Container(
              height: 80, width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 2, color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  SizedBox(height: 4),
                  Row(children: [
                    Text("  Class: ", style: TextStyle(fontSize: 20)),
                    Text("$className", style: TextStyle(fontSize: 20))
                  ]),
                  SizedBox(height: 8),
                  Row(children: [
                    Text("  Proff: ", style: TextStyle(fontSize: 20)),
                    Text("$proffName", style: TextStyle(fontSize: 20))
                  ]),
                  SizedBox(height: 4),
                ],
              ),
            ),
            SizedBox(height: 130),
            Center(child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {Navigator.of(context).pop();},
                  child: Text("No", style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50),
                    primary: Colors.red,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.black, width: 2) 
                    )             
                  )
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {_goToSubmitInfoPage(context);},
                  child: Text("Yes", style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50),
                    primary: Colors.green,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.black, width: 2) 
                    )             
                  )
                )                   
              ]
            )),
            SizedBox(height: 50), 
          ],
        ))
      ),
    );
  }
}


/*========================================================
  Submit Info Page where User Submits their Info To Class 
  ========================================================*/ 
class SubmitInfoPage extends StatefulWidget {
  SubmitInfoPage({Key? key, required this.classCode, required this.className}) : super(key: key);
  final String classCode;
  final String? className;
  @override
  _SubmitInfoPageState createState() => _SubmitInfoPageState();
}


class _SubmitInfoPageState extends State<SubmitInfoPage> {
  TextEditingController firstNameController = TextEditingController(); 
  TextEditingController lastNameController = TextEditingController(); 
  TextEditingController preferedNameController = TextEditingController(); 
  final List<Widget> genders = <Widget> [Text("Male"),Text("Female"),Text("Non-Binary")];
  final List<bool> _selectedGenders = <bool>[true, false, false]; 
  late CameraController _cameraController;
  XFile? _capturedPhoto;
  late Student _student;
  String _message = "";
  bool _loading = false;

  @override
  void initState() {super.initState();}

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[0], 
      ResolutionPreset.low,
      enableAudio: false
    );
    await _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

 
  void _genderButtons(int index) async{
    setState(() {
      for(int i = 0; i < _selectedGenders.length; i++){
        _selectedGenders[i] = i == index;
      }
    });
  }

  void _takePhoto() async{
    await _initializeCamera();
    final XFile file = await _cameraController.takePicture();
    await _cameraController.dispose();
    if (file != null){
      setState(() {_capturedPhoto = file;});
    } 
  }

  void _choosePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery
    );
    if (pickedFile != null) {
      setState(() {_capturedPhoto = pickedFile;});
    }
  }

  void _submitInfo() async{
    setState(() {_loading = true;});
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    if (firstName.isEmpty || lastName.isEmpty || _capturedPhoto == null){
      setState(() {_message = "Missing Info";});
      setState(() {_loading = false;});
      return;
    }

    String? preferredName = preferedNameController.text.trim();
    XFile? capturedPhoto = _capturedPhoto;
    late Gender gender;
    for (int i = 0; i < _selectedGenders.length; i++) {
      if (_selectedGenders[i]) {
        gender = Gender.values[i];
        break;
      }
    }   
    _student = Student(
      firstName: firstName,
      lastName: lastName,
      preferredName: preferredName,
      photo: capturedPhoto!,
      gender: gender,
    );

    bool submited = await CloudStorage().addStudent(widget.classCode, _student);
    if (submited) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ExitPage(className: widget.className),
        )
      );
    } else {
      setState(() {_message = "Error Uploading";});
    }
    setState(() {_loading = false;});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity, width: double.infinity,
        /*_______backround image_______*/
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(child: Column(
          children: [
            /*_______Class Name & Underline_______*/
            SizedBox(height: 20),
            Text('${widget.className}', style: TextStyle(fontSize: 25, color: Colors.white)),
            Container(width: 300, height: 2, color: Colors.white),
          
            /*_______Name TextFields_______*/
            Container(
              width: 300,
              child: Column(children: [
                SizedBox(height: 10),
                TextField(
                  controller: firstNameController, 
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: "Enter First Name",
                  )
                ),
                SizedBox(height: 5),
                TextField(
                  controller: lastNameController, 
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: "Enter Last Name",
                  )
                ),
                SizedBox(height: 5),
                TextField(
                  controller: preferedNameController, 
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: "Enter Preffered Name",
                  )
                ),
              ])
            ),

            /*_______Gender Buttons_______*/
            SizedBox(height: 10),
            Text("Gender", style: TextStyle(fontSize: 18, color: Colors.white)),
            SizedBox(height: 4),
            ToggleButtons(
              onPressed: (int index) {_genderButtons(index);},
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              selectedBorderColor: Colors.black,
              selectedColor: Colors.black,
              fillColor: Colors.white,
              color: Colors.white,
              constraints: const BoxConstraints(
                minHeight: 40.0,
                minWidth: 95.0,
              ),
              isSelected: _selectedGenders,
              children: genders,
            ),

            /*____Upload Portrait Options____*/
            SizedBox(height: 10),
            Text("Portrait", style: TextStyle(fontSize: 18, color: Colors.white)),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _takePhoto,
                  child: Text(" Take "),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(130, 50),
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), 
                      side: BorderSide(color: Colors.black, width: 2) 
                    ),               
                  ),
                ),
                SizedBox(width:4),
                ElevatedButton(
                  onPressed: _choosePhoto,
                  child: Text("Choose"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(130, 50),
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.black, width: 2)
                    ),               
                  ),
                ),
              ]
            ),

            /*____Display Portrait____*/
            SizedBox(height: 5),
            SizedBox(  
              height: 200,
              width: 200,
              child: _capturedPhoto  != null
                ? Image.network(_capturedPhoto!.path)
                : Placeholder(
                  fallbackHeight: 200,
                  fallbackWidth: 200,
                  child: Image.asset("images/emptyPicFrame.png"),
                ),
            ),
            Text("$_message", style: TextStyle(fontSize: 15, color: Colors.white)),
            ElevatedButton(
              onPressed: _loading ? null : _submitInfo,
              child: _loading
                ? CircularProgressIndicator(color: Colors.white)
                : Text("Submit", style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(150, 50),
                primary: Colors.green,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: Colors.black, width: 2) 
                )             
              )
            ),
            SizedBox(height: 40)  
            
          ],
        )),
      ),
    );
  }
}

class ExitPage extends StatelessWidget {
  ExitPage({Key? key, required this.className}) : super(key: key);
  final String? className;

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
          Center(child: Column(children: [
            SizedBox(height: 20),
            Image.asset('images/logo.png'),
            Text('Namerizer', style: TextStyle(fontSize: 30, color: Colors.white)),
            Container(width: 300, height: 2, color: Colors.white),

            SizedBox(height: 130),


            Container(
                height: 150, width: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 2, color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 22),
                    Text("You Have Successfully", style: TextStyle(fontSize: 20, color: Colors.black)),
                    Text("Submited Your Information To", style: TextStyle(fontSize: 20, color: Colors.black)),
                    SizedBox(height: 4),
                    Container(width: 300, height: 2, color: Colors.black),
                    SizedBox(height: 10),
                    Text("$className", style: TextStyle(fontSize: 20, color: Colors.black)),
                    SizedBox(height: 4),
                  ],
                ),
              ),

          ]))
        ]
      )
    );
  }
}