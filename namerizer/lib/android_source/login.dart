import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "../util/cloudStorage.dart";
import "home.dart";
import "package:firebase_auth/firebase_auth.dart";

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
      if (e.code == "INVALID_LOGIN_CREDENTIALS") {
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
    final emailForm = TextFormField(
      controller: _emailLoginControl,
      validator: (_) {
        if(_loginError == EMAIL_ERROR) {
          return "Email doesn't exist.";
        } else if(_loginError == INVALID_CREDENTIALS) {
          return "Email or password is incorrect.";
        }
        return null;
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Email",
      ),
    );
    final passwordForm = TextFormField(
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
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Password",
      ),
    );
    final loginButton = FloatingActionButton(
      heroTag: "login",
      onPressed: !_loading ? () => _submitLogin(context) : null,
      tooltip: "Login",
      child: const Text("Login"),
    );
    final toRegisterButton = FloatingActionButton(
      heroTag: "to_register",
      onPressed: !_loading ? () { setState(() { _login = false; }); } : null,
      tooltip: "Sign up",
      child: const Text("Sign up"),
    );
    const box = SizedBox(height: 20);
    final img = Image.network("https://static-sl.files.edl.io/waes-lausd-ca.schoolloop.com/brtimiyx4g55xptb.png").image;
    return Form(
      key: _loginFormKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text("Welcome to Namerizer!"),
            box,
            Image(image: img, height: 200),
            box,
            emailForm,
            box,
            passwordForm,
            box,
            loginButton,
            box,
            toRegisterButton,
          ],
        ),
      ),
    );
  }

  Widget _getRegisterPage(BuildContext context) {
    final emailForm = TextFormField(
      controller: _emailRegisterControl,
      validator: (_) => _registerError == EMAIL_EXISTS ? "Email is already in use." : null,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Email",
      ),
    );
    final passwordForm = TextFormField(
      obscureText: true,
      controller: _passwordRegisterControl,
      validator: (_) => _registerError == WEAK_PASSWORD ? "Weak password." : null,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Password",
      ),
    );
    final password2Form = TextFormField(
      obscureText: true,
      controller: _password2RegisterControl,
      validator: (_) => _registerError == PASSWORD_DIFFERENT ? "Password is different, please try again." : null,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Repeat Password",
      ),
    );
    final nameForm = TextFormField(
      controller: _nameRegisterControl,
      validator: (_) => null, //always accept
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Full Name",
      ),
    );
    final registerButton = FloatingActionButton(
      heroTag: "register",
      onPressed: !_loading ? () => _submitRegister(context) : null,
      tooltip: "Sign Up",
      child: const Text("Sign Up"),
    );
    final toLoginButton = FloatingActionButton(
      heroTag: "to_login",
      onPressed: !_loading ? () { setState(() { _login = true; }); } : null,
      tooltip: "Cancel",
      child: const Text("Cancel"),
    );
    const box = SizedBox(height: 20);
    final img = Image.network("https://static-sl.files.edl.io/waes-lausd-ca.schoolloop.com/brtimiyx4g55xptb.png").image;
    return Form(
      key: _registerFormKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text("Signing Up!"),
            box,
            Image(image: img, height: 100),
            box,
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
          ],
        ),
      ),
    );
  }

  //_____________build_______________
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Login or Register"),
        leading: IconButton(
          onPressed: () => SystemChannels.platform.invokeMethod("SystemNavigator.pop"),
          tooltip: "Quit to Home",
          icon: const Icon(Icons.home),
        ),
      ),
      body: _login ? _getLoginPage(context) : _getRegisterPage(context),
      persistentFooterAlignment: AlignmentDirectional.center,
      floatingActionButton: _loading ? const CircularProgressIndicator() : null,
    );
  }
}