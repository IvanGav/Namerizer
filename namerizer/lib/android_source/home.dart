import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "../util/cloudStorage.dart";
import "classPage.dart";
import "login.dart";

//_____________________________Home____________________________________

class Home extends StatefulWidget {
  const Home({super.key, required this.uid});

  final String uid; //unique id of a professor

  @override
  State<Home> createState() => _HomeState();
}

//_______________________________HomeState____________________________________

class _HomeState extends State<Home> {
  //_____________fields_______________
  bool _classesInitialized = false;
  late List<String> _classes; //contains all classes for this professor
  late Map<String,String> _classNames; //maps class code -> class name
  late final CloudStorage _cloud;
  bool _loading = false; //can be set to true to show that a process is executing (such as async functions). Don't forget to set to false when done.
  bool _deleting = false;

  //_____________init_______________
  @override
  void initState() {
    super.initState();
    _cloud = CloudStorage(professor: widget.uid);
    _initClasses();
  }

  Future<void> _initClasses() async {
    setState(() {
      _classesInitialized = false;
      _loading = true;
    });
    var classCodes = await _cloud.getClasses();
    if(classCodes == null) {
      setState(() {
        _loading = false;
      });
      print("--could not get class codes");
      return;
    }
    _classes = classCodes;
    _classNames = {};
    for(String code in _classes) {
      String? name = await _cloud.getClassName(code);
      if(name == null) {
        print("--Class name doesn't exist for class code: $code");
        continue; //just silently ignore lol
      }
      _classNames[code] = name;
    }
    setState(() {
      _loading = false;
      _classesInitialized = true;
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      Navigator.pop(context);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    });
  }

  void _snack(BuildContext context, String message) {
    var snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  //_____________add/remove a class_____________
  void _promptAddClass(BuildContext context) {
    final TextEditingController formControl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var form = Form(
      key: formKey,
      child: TextFormField(
        controller: formControl,
        validator: (text) => (text == null || text.isEmpty) ? "Class must have a name." : null,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Class Name",
        ),
      ),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter a Class Name:"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("A class with this name will be created."),
            const SizedBox(height: 20),
            form,
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel")
          ),
          TextButton(
            onPressed: () {
              if(formKey.currentState!.validate()) {
                _addClass(formControl.text).then((value) { //if returns false, say couldn't create a class
                  if(value == false) {
                    _snack(context,"Couldn't add a class.");
                  }
                  return value;
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text("Create")
          ),
        ],
      )
    );
  }

  void _promptRemoveClass(BuildContext context, String classCode) {
    final TextEditingController formControl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var form = Form(
      key: formKey,
      child: TextFormField(
        controller: formControl,
        validator: (text) => (text == _classNames[classCode]) ? null : "Please enter the displayed name to delete.",
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: _classNames[classCode],
        ),
      ),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter a Class Name:"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("A class with this name will be permanently deleted.", style: TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            form,
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
          ),
          TextButton(
              onPressed: () {
                if(formKey.currentState!.validate()) {
                  _removeClass(classCode).then((value) { //if returns false, say couldn't remove a class
                    if(value == false) {
                      _snack(context,"Couldn't remove a class.");
                    }
                    return value;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red))
          ),
        ],
      )
    );
  }

  Future<bool> _addClass(String className) async {
    setState(() {
      _loading = true;
    });
    String? classCode = await _cloud.addClass(className);
    setState(() {
      _loading = false;
      if(classCode != null) {
        _classes.add(classCode);
        _classNames[classCode] = className;
      }
    });
    return classCode != null;
  }

  Future<bool> _removeClass(String classCode) async {
    setState(() {
      _loading = true;
    });
    bool result = await _cloud.removeClass(classCode);
    setState(() {
      _loading = false;
      if(result) {
        //i could also retrieve them from firebase again, but you know, why bother
        _classes.removeWhere((element) => element == classCode);
        _classNames.remove(_classNames[classCode]);
      }
    });
    return result;
  }

  //_____________class list widget getter_______________
  Widget _getClassList(BuildContext context) {
    if(!_classesInitialized) {
      return RefreshIndicator( //TEST TODO
        onRefresh: _initClasses,
        child: Center(
          child: _loading ? const CircularProgressIndicator() : const Text("Something went wrong, try refreshing.")
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _initClasses,
      child: ListView.builder(
        itemBuilder: (context,index) => _getClassTile(_classes[index],context),
        itemCount: _classes.length,
      ),
    );
  }

  Widget _getClassTile(String classCode, BuildContext context) {
    return ListTile(
      title: Text(_classNames[classCode] == null ? "ERROR: Class Doesn't Exist" : _classNames[classCode]!),
      onTap: () {
        if(_deleting) {
          _promptRemoveClass(context, classCode);
          setState(() {
            _deleting = false;
          });
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ClassHome(code: classCode, cloud: _cloud),
            ),
          );
        }
      }
    );
  }

  //_____________build_______________
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Choose or create a class"),
        leading: IconButton(
          onPressed: () => SystemChannels.platform.invokeMethod("SystemNavigator.pop"),
          tooltip: "Quit to Home",
          icon: const Icon(Icons.home),
        ),
        actions: [ //tailing
          IconButton(
            onPressed: _logout, //maybe grey out the button while trying to log out?
            tooltip: "Logout",
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _getClassList(context),
      persistentFooterButtons: _deleting ? [ //deleting (cancel button)
        FloatingActionButton(
          heroTag: "cancel_remove",
          onPressed: _loading ? null : () => setState(() => _deleting = false),
          tooltip: "Cancel",
          child: const Icon(Icons.cancel),
        ),
      ] : [ //not deleting (add/remove class buttons)
        FloatingActionButton(
          heroTag: "add_class", //idk what it is, but it throws exceptions without this tag thing
          onPressed: _loading ? null : () => _promptAddClass(context),
          tooltip: "Add a class",
          child: const Icon(Icons.add),
        ),
        FloatingActionButton(
          heroTag: "remove_class",
          onPressed: _loading ? null : () => setState(() => _deleting = true),
          tooltip: "Remove a class",
          child: const Icon(Icons.remove),
        ),
      ],
      persistentFooterAlignment: AlignmentDirectional.center,
      floatingActionButton: _loading ? const CircularProgressIndicator() : null,
    );
  }
}