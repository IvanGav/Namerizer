import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "../util/cloudStorage.dart";
import "home.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'package:google_fonts/google_fonts.dart';


import "../firebase_options.dart";
import "package:firebase_core/firebase_core.dart";

//_____________________________LoginPage____________________________________

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

//_______________________________HomeState____________________________________

class _LoginPageState extends State<LoginPage> {
  //_____________fields_______________
  final INVALID_CREDENTIALS = "invalid_cred";
  final PASSWORD_ERROR = "pass_err";
  final EMAIL_ERROR = "email_err";
  final WEAK_PASSWORD = "weak_pass";
  final EMAIL_EXISTS = "email_exists";
  final PASSWORD_DIFFERENT = "pass_diff";

  bool _firebaseInitialized = false;
  bool _loading = true;
  bool _login = true; //false = register
  final _cloud = CloudStorage();

  String? _loginError;
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _emailLoginControl = TextEditingController();
  final TextEditingController _passwordLoginControl = TextEditingController();

  String? _registerError;
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  final TextEditingController _emailRegisterControl = TextEditingController();
  final TextEditingController _passwordRegisterControl = TextEditingController();
  final TextEditingController _password2RegisterControl = TextEditingController();
  final TextEditingController _nameRegisterControl = TextEditingController();

  //_____________init_______________
  @override
  void initState() {
    super.initState();
    _tryLogin();
  }

  //____________login____________
  void _tryLogin() async {
    setState(() {
      _loading = true;
    });
    if(!_firebaseInitialized) {
      FirebaseApp app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firebaseInitialized = true;
    }
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if(uid != null) {
      _loginWithUID(uid);
    }
    setState(() {
      _loading = false;
    });
  }

  void _loginWithUID(String uid) {
    setState(() {
      Navigator.pop(context);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Home(uid: uid),
        ),
      );
    });
  }

  //_____________forms submit_____________
  void _submitLogin(BuildContext context) async {
    setState(() {
      _loading = true;
      _loginError = null;
    });
    UserCredential? credential;
    String? error;
    try {
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailLoginControl.text,
          password: _passwordLoginControl.text
      );
      print("--credentials passed");
    } on FirebaseAuthException catch (e) {
      if (e.code == "INVALID_LOGIN_CREDENTIALS" || e.code == "channel-error") {
        error = INVALID_CREDENTIALS;
      } else if (e.code == "user-not-found" || e.code == "invalid-email") {
        error = EMAIL_ERROR;
      } else if (e.code == "wrong-password") {
        error = PASSWORD_ERROR;
      } else {
        error = "Unknown Error";
        print("--other firebase error: ${e.code}");
      }
    } catch (e) {
      error = "Unknown error";
      print("--other error: $e");
    }
    if(error == null && credential?.user?.uid != null) {
      _loginWithUID(credential!.user!.uid);
    }
    setState(() {
      _loading = false;
      _loginError = error;
      _loginFormKey.currentState!.validate();
    });
  }

  void _submitRegister(BuildContext context) async {
    setState(() {
      _loading = true;
      _registerError = null;
    });
    String? error;
    if(_passwordRegisterControl.text != _password2RegisterControl.text) {
      error = PASSWORD_DIFFERENT;
    } else {
      try {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailRegisterControl.text,
          password: _passwordRegisterControl.text,
        );
        bool success = await _cloud.addUser(credential.user!.uid, _nameRegisterControl.text, _emailRegisterControl.text, _passwordRegisterControl.text);
        _loginWithUID(credential.user!.uid);
      } on FirebaseAuthException catch (e) {
        if (e.code == "weak-password") {
          error = WEAK_PASSWORD;
        } else if (e.code == "email-already-in-use") {
          error = EMAIL_EXISTS;
        } else {
          error = "Unknown error";
          print("--other firebase error: ${e.code}");
        }
      } catch (e) {
        error = "Unknown error";
        print("--other error: $e");
      }
    }
    setState(() {
      _loading = false;
      _registerError = error;
      _registerFormKey.currentState!.validate();
    });
  }

  //FirebaseAuth.instance.sendPasswordResetEmail(email: "user@example.com");

  //_____________body_______________
  Widget _getLoginPage(BuildContext context) {
    final emailForm = Container(width: 370,
      child: TextFormField(
        controller: _emailLoginControl,
        validator: (_) {
          if(_loginError == EMAIL_ERROR) {
            return "Email doesn't exist.";
          } else if(_loginError == INVALID_CREDENTIALS) {
            return "Email or password is incorrect.";
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: "Email",
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0),),
        ),
      ),
    );
    final passwordForm = Container(width: 370,
      child: TextFormField(
        obscureText: true,
        controller: _passwordLoginControl,
        validator: (_) {
          if(_loginError == PASSWORD_ERROR) {
            return "Incorrect password.";
          } else if(_loginError == INVALID_CREDENTIALS) {
            return "Email or password is incorrect.";
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: "Password",
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      ),
    );
    final loginButton = ElevatedButton(
      onPressed: !_loading ? () => _submitLogin(context) : null,
      child: const Text("Login", style: TextStyle(fontSize: 22)),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(160, 50),
        primary: Colors.green, onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: Colors.black, width: 2) 
        )             
      )
    );
    final toRegisterButton = ElevatedButton(
      onPressed: !_loading ? () { setState(() { _login = false; }); } : null,
      child: const Text("Sign up", style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(120, 40),
        primary: Colors.white, onPrimary: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: Colors.black, width: 2) 
        )             
      )
    );
    const box = SizedBox(height: 20);
    const largeWidthBox = SizedBox(width: 500);
    final img = AssetImage('images/logo.png');
    final greeting = Text("Welcome To Namerizer !", 
                     style: TextStyle(fontSize: 20, color: Colors.white,));
   
    return Form(
      key: _loginFormKey,
      child: Container( height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              box,
              Image(image: img),
              box,
              greeting,
              SizedBox(height: 80),
              emailForm,
              box,
              passwordForm,
              SizedBox(height: 60), 
              loginButton,
              box,
              toRegisterButton,
              largeWidthBox, 
            ],
          ),
      ),),
    );
  }

  Widget _getRegisterPage(BuildContext context) {
    final emailForm = Container(width: 370,
      child: TextFormField(
        controller: _emailRegisterControl,
        validator: (_) => _registerError == EMAIL_EXISTS ? "Email is already in use." : null,
        decoration: InputDecoration(
          hintText: "Email",
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      ),
    );
    final passwordForm = Container(width: 370,
      child: TextFormField(
        obscureText: true,
        controller: _passwordRegisterControl,
        validator: (_) => _registerError == WEAK_PASSWORD ? "Weak password." : null,
        decoration: InputDecoration(
          hintText: "Password",
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      ),
    );
    final password2Form = Container(width: 370,
      child: TextFormField(
        obscureText: true,
        controller: _password2RegisterControl,
        validator: (_) => _registerError == PASSWORD_DIFFERENT ? "Password is different, please try again." : null,
        decoration: InputDecoration(
          hintText: "Repeat Password",
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      ),
    );
    final nameForm = Container(width: 370,
      child: TextFormField(
        controller: _nameRegisterControl,
        validator: (_) => null, //always accept
        decoration: InputDecoration(
          hintText: "Full Name",
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      ),
    );
    final registerButton = ElevatedButton(
      onPressed: !_loading ? () => _submitRegister(context) : null,
      child: const Text("Sign Up", style: TextStyle(fontSize: 20)),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(150, 50),
        primary: Colors.green, onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: Colors.black, width: 2) 
        )             
      )
    );
    final toLoginButton = ElevatedButton(
      onPressed: !_loading ? () { setState(() { _login = true; }); } : null,
      child: const Text("Cancel", style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(110, 35),
        primary: Colors.white, onPrimary: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: Colors.black, width: 2) 
        )             
      )      
    );
    const box = SizedBox(height: 20);
    const largeWidthBox = SizedBox(width: 500);
    final img = AssetImage('images/logo.png');
    final greeting = Text("Signing Up!", 
                     style: TextStyle(fontSize: 18, color: Colors.white,));

    return Form(
      key: _registerFormKey,
      child: Container(height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            box,
            Image(image: img, height: 100),
            SizedBox(height: 10),
            greeting,
            SizedBox(height: 10),
            nameForm,
            box,
            emailForm,
            box,
            passwordForm,
            box,
            password2Form,
            box,
            registerButton,
            box,
            toLoginButton,
            largeWidthBox
          ],
        ),
      ),),
    );
  }

  //_____________build_______________
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        title: Text("Login or Register"),
        leading: IconButton(
          onPressed: () => SystemChannels.platform.invokeMethod("SystemNavigator.pop"),
          tooltip: "Quit to Home",
          icon: const Icon(Icons.home),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: _login ? _getLoginPage(context) : _getRegisterPage(context),
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      floatingActionButton: _loading ? const CircularProgressIndicator(color: Colors.white) : null,
    );
  }
}