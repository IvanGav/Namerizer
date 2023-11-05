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

  //_____________init_______________
  @override
  void initState() {
    super.initState();
    _cloud = CloudStorage(professor: widget.uid);
    _initClasses();
  }

  void _initClasses() async {
    setState(() {
      _loading = true;
    });
    var classCodes = await _cloud.getClasses();
    if(classCodes == null) {
    setState(() {
      _loading = false;
    });
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

  //_____________add/remove a class_____________
  void _promptAddClass(BuildContext context) {
    final TextEditingController formControl = TextEditingController();
    var form = TextFormField(
      controller: formControl,
      validator: (_) => null, //always accept
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Class Name",
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
                _addClass(formControl.text);
                Navigator.of(context).pop();
              },
              child: const Text("Create")
            ),
          ],
        )
    );
  }

  void _promptRemoveClass(BuildContext context) {
    final TextEditingController formControl = TextEditingController();
    var form = TextFormField(
      controller: formControl,
      validator: (_) => null, //always accept
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Class Name",
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
                child: const Text("Cancel")
            ),
            TextButton(
                onPressed: () {
                  _removeClass(formControl.text);
                  Navigator.of(context).pop();
                },
                child: const Text("Delete", style: TextStyle(color: Colors.red))
            ),
          ],
        )
    );
  }

  Future<void> _addClass(String className) async {
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
  }

  Future<void> _removeClass(String className) async {
    setState(() {
      _loading = true;
    });
    String classCode = "";
    for(var e in _classNames.entries) {
      if(e.value == className) {
        classCode = e.key;
      }
    }
    if(classCode == "") {
      setState(() {
        _loading = false;
      });
      //no such class (name) exists
      return;
    }
    bool result = false;
    result = await _cloud.removeClass(classCode);
    if(result == false) {
      setState(() {
        _loading = false;
      });
      //no remove wasn't successful
      return;
    }
    //remove all classes with that name (CHANGE LATER MAYBE)
    setState(() {
      _loading = false;
      _classes.removeWhere((element) => element == classCode);
      _classNames.remove(classCode);
    });
  }

  //_____________class list widget getter_______________
  Widget _getClassList(BuildContext context) {
    if(!_classesInitialized) {
      return const Text("Please Wait...");
    }
    List<Widget> classList = [];
    for(var c in _classes) {
      classList.add(_getClassTile(c, context));
    }
    return Column(//ListView
      children: classList,
    );
  }

  Widget _getClassTile(String classCode, BuildContext context) {
    return ListTile(
      title: Text(_classNames[classCode] == null ? "ERROR: Class Doesn't Exist" : _classNames[classCode]!),
      onTap: () => {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ClassHome(code: classCode, cloud: _cloud),
          ),
        )
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
      body: SingleChildScrollView(
        child: _getClassList(context),
      ),
      persistentFooterButtons: [
        FloatingActionButton(
          heroTag: "add_class", //idk what it is, but it throws exceptions without this tag thing
          onPressed: () => _promptAddClass(context),
          tooltip: "Add a class",
          child: const Icon(Icons.add),
        ),
        FloatingActionButton(
          heroTag: "remove_class",
          onPressed: () => _promptRemoveClass(context),
          tooltip: "Remove a class",
          child: const Icon(Icons.remove),
        ),
      ],
      persistentFooterAlignment: AlignmentDirectional.center,
      floatingActionButton: _loading ? const CircularProgressIndicator() : null,
    );
  }
}