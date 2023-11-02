import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "../util/cloudStorage.dart";
import "home.dart";

//_____________________________LoginPage____________________________________

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

//_______________________________HomeState____________________________________

class _LoginPageState extends State<LoginPage> {
  //_____________fields_______________
  bool _loading = false;
  bool _login = true; //false = register
  final _cloud = CloudStorage("none");

  bool _loginActive = true;
  final TextEditingController usernameLoginControl = TextEditingController();
  final TextEditingController passwordLoginControl = TextEditingController();

  //_____________init_______________
  @override
  void initState() {
    super.initState();
  }

  //_____________forms_____________
  void _submitLogin(BuildContext context) async {
    setState(() {
      _loginActive = false;
      _loading = true;
    });
    var users = await _cloud.getUsers();
    String? profUID = users[(usernameLoginControl.text,passwordLoginControl.text)];
    if (profUID != null) {
      setState(() {
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
        );
      });
    }
    setState(() {
      _loginActive = true;
      _loading = false;
    });
  }

  //_____________body_______________

  Widget _getLoginPage(BuildContext context) {
    var usernameForm = TextFormField(
      controller: usernameLoginControl,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Username",
      ),
    );
    var passwordForm = TextFormField(
      controller: passwordLoginControl,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Password",
      ),
    );
    var loginButton = FloatingActionButton(
      heroTag: "login",
      onPressed: _loginActive ? () => _submitLogin(context) : null,
      tooltip: "Remove a class",
      child: const Text("Login"),
    );
    var registerButton = FloatingActionButton(
      heroTag: "register",
      onPressed: _loginActive ? () { setState(() { _login = false; }); } : null,
      tooltip: "Sign up",
      child: const Text("Sign up"),
    );
    var box = const SizedBox(height: 20);
    var img = Image.network("https://static-sl.files.edl.io/waes-lausd-ca.schoolloop.com/brtimiyx4g55xptb.png", height: 200).image;
    return Center(
      child: Column(
        children: [
          const Text("Welcome to Namerizer!"),
          box,
          Image(image: img),
          box,
          usernameForm,
          box,
          passwordForm,
          box,
          loginButton,
          box,
          registerButton,
        ],
      ),
    );
  }

  Widget _getRegisterPage(BuildContext context) {
    return Text("register");
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