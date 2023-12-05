import "package:google_fonts/google_fonts.dart";
import "package:image_picker/image_picker.dart";
import "package:flutter/material.dart";
import "package:camera/camera.dart";

import "../util/cloudStorage.dart";
import "../util/student.dart";

final iconImg = Image.asset("images/logo.png");
//Image.network("https://pbs.twimg.com/profile_images/1294200194226171904/qOiiCE6c_400x400.png", height: 200); 
final bgImg = Image.asset("images/background.jpg", fit: BoxFit.cover);
//Image.network("https://images.unsplash.com/photo-1483232539664-d89822fb5d3e?q=80&w=1964&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", fit: BoxFit.cover);
final emptyImg = Image.asset("images/emptyPicFrame.png");
//Image.network("https://fiverr-res.cloudinary.com/images/t_main1,q_auto,f_auto,q_auto,f_auto/gigs/118947646/original/9fb85fe56953295c5592270439d44b477c742ca5/create-a-pixel-art-charakter-for-you.png");
final TextTheme? textTheme = GoogleFonts.calistogaTextTheme(); //null; 

class WebApp extends StatelessWidget {
  const WebApp({super.key});
  @override
  Widget build(BuildContext context) {
    /* prevents from website going horizantal */
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData(
        textTheme: textTheme,
        inputDecorationTheme: InputDecorationTheme(
          filled: true, fillColor: Colors.white,
          errorStyle: const TextStyle(color: Colors.red),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 2, color: Colors.black),
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
    String? profName = await CloudStorage().getClassProfessor(classCode);
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
          proffName: profName
        ),
      ),
    );

    setState(() {_loading = false;});
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
              child: bgImg
            ),
            Center(child: Column(
              children: [
                /*_______(Logo, Name, Underline) displayed_______*/
                const SizedBox(height: 20),
                iconImg,
                const Text("Namerizer", style: TextStyle(fontSize: 30, color: Colors.white)),
                Container(width: 300, height: 2, color: Colors.white),
                /*_______Class Code Text Field_______*/
                const SizedBox(height: 180),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: classCodeController,
                    cursorColor: Colors.black,
                    style: const TextStyle(color: Colors.black, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: "Enter Class Code",
                      errorText: error
                    )
                  )
                ),
                /*_______Submit Button_______*/
                const SizedBox(height: 180),
                ElevatedButton(
                  onPressed: _loading ? null : _goToVerifyPage,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(170, 60),
                    primary: Colors.green,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: Colors.black, width: 2)
                    )             
                  ),
                  child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit", style: TextStyle(fontSize: 22))
                )
              ]
            )
          )
        ]
      ),
    );
  }
}

/*===================================================================
  Verify Page Where Website Dispays The Class They Are Connecting To 
  ===================================================================*/ 
class VerifyPage extends StatelessWidget {
  const VerifyPage({Key? key, required this.classCode, required this.className, required this.proffName}) : super(key: key);
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
      body: Stack(
        children: [
          /*_______Backround Image_______*/
          Positioned(
              top: 0, left: 0, right: 0, bottom: 0,
              child: bgImg
          ),
      
          Center(child: Column(
            children: [
              /*_______(Logo, Name, Underline) Dispayed_______*/
              const SizedBox(height: 20),
              iconImg,
              const Text("Namerizer", style: TextStyle(fontSize: 30, color: Colors.white,)),
              Container(width: 300, height:2, color:Colors.white),
              /*______Prints Class Name & Proff Name_______*/
              const SizedBox(height: 120),
              const Text("Is This Your Class?", style: TextStyle(fontSize: 20, color: Colors.white)),
              const SizedBox(height: 10),
              Container(
                height: 80, width: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 2, color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    Row(children: [
                      const Text("  Class: ", style: TextStyle(fontSize: 20)),
                      Text("$className", style: TextStyle(fontSize: 20))
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Text("  Proff: ", style: TextStyle(fontSize: 20)),
                      Text("$proffName", style: TextStyle(fontSize: 20))
                    ]),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              const SizedBox(height: 130),
              Center(child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {Navigator.of(context).pop();},
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(150, 50),
                      primary: Colors.red,
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.black, width: 2)
                      )             
                    ),
                    child: const Text("No", style: TextStyle(fontSize: 20))
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {_goToSubmitInfoPage(context);},
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(150, 50),
                      primary: Colors.green,
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.black, width: 2)
                      )             
                    ),
                    child: const Text("Yes", style: TextStyle(fontSize: 20))
                  )                    
                ]
              ))
            ],
          ))

        ],
      ),
    );
  }
}


/*========================================================
  Submit Info Page where User Submits their Info To Class 
  ========================================================*/ 
class SubmitInfoPage extends StatefulWidget {
  const SubmitInfoPage({Key? key, required this.classCode, required this.className}) : super(key: key);
  final String classCode;
  final String? className;
  @override
  State<SubmitInfoPage> createState() => _SubmitInfoPageState();
}


class _SubmitInfoPageState extends State<SubmitInfoPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _preferredNameController = TextEditingController();
  final List<Widget> _genders = <Widget> [Text(Gender.male.name), Text(Gender.female.name), Text(Gender.nonbinary.name)];
  final List<bool> _selectedGenders = <bool>[true, false, false]; 
  late CameraController _cameraController;
  XFile? _capturedPhoto;
  late Student _student;
  String _message = "";
  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[0], 
      ResolutionPreset.high,
    );
    await _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

 
  void _genderButtons(int index) async {
    setState(() {
      for(int i = 0; i < _selectedGenders.length; i++){
        _selectedGenders[i] = i == index;
      }
    });
  }

  void _takePhoto() async {
    await _initializeCamera();
    final XFile file = await _cameraController.takePicture();
    await _cameraController.dispose();
    setState(() {_capturedPhoto = file;});
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

  void _submitInfo() async {
    setState(() {_loading = true;});
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    if (firstName.isEmpty || lastName.isEmpty || _capturedPhoto == null){
      setState(() {_message = "Missing Info";});
      setState(() {_loading = false;});
      return;
    }

    String? preferredName = _preferredNameController.text.trim();
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

    bool submitted = await CloudStorage().addStudent(widget.classCode, _student);
    if (submitted) {
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
      body: Stack(
        children: [
          /*_______Background Image_______*/
          Positioned(
              top: 0, left: 0, right: 0, bottom: 0,
              child: bgImg
          ),
          
          Center(child: Column(children: [
            /*_______Class Name & Underline_______*/
            const SizedBox(height: 20),
            Text("${widget.className}", style: const TextStyle(fontSize: 25, color: Colors.white)),
            Container(width: 300, height: 2, color: Colors.white),
          
            /*_______Name TextFields_______*/
            SizedBox(
              width: 300,
              child: Column(children: [
                const SizedBox(height: 10),
                TextField(
                  controller: _firstNameController,
                  cursorColor: Colors.black,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: "Enter First Name",
                  )
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _lastNameController,
                  cursorColor: Colors.black,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: "Enter Last Name",
                  )
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _preferredNameController,
                  cursorColor: Colors.black,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: "Enter Preferred Name",
                  )
                ),
              ])
            ),

            /*_______Gender Buttons_______*/
            // citation: https://api.flutter.dev/flutter/material/ToggleButtons-class.html
            const SizedBox(height: 10),
            const Text("Gender", style: TextStyle(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 4),
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
              children: _genders,
            ),

            /*____Upload Portrait Options____*/
            const SizedBox(height: 10),
            const Text("Portrait", style: TextStyle(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _takePhoto,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(130, 50),
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), 
                      side: const BorderSide(color: Colors.black, width: 2)
                    ),               
                  ),
                  child: const Text(" Take "),
                ),
                const SizedBox(width:4),
                ElevatedButton(
                  onPressed: _choosePhoto,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(130, 50),
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: Colors.black, width: 2)
                    ),               
                  ),
                  child: const Text("Choose"),
                ),
              ]
            ),

            /*____Display Portrait____*/
            const SizedBox(height: 5),
            SizedBox(  
              height: 200,
              width: 200,
              child: _capturedPhoto  != null
                ? Image.network(_capturedPhoto!.path)
                : Placeholder(
                  fallbackHeight: 200,
                  fallbackWidth: 200,
                  child: emptyImg
                ),
            ),
            Text(_message, style: const TextStyle(fontSize: 15, color: Colors.white)),
            ElevatedButton(
              onPressed: _loading ? null : _submitInfo,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 50),
                primary: Colors.green,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: const BorderSide(color: Colors.black, width: 2)
                )             
              ),
              child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Submit", style: TextStyle(fontSize: 20))
            )  
    
          ]))
          
        ],
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
              child: bgImg
          ),
          Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                iconImg,
                const Text("Namerizer", style: TextStyle(fontSize: 30, color: Colors.white)),
                Container(width: 300, height: 2, color: Colors.white),

                const SizedBox(height: 130),

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
              ]
            )
          )
        ]
      )
    );
  }
}