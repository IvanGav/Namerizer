import "package:flutter/material.dart";
import "../util/cloudStorage.dart";
import "classPage.dart";

//_____________________________Home____________________________________

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

//_______________________________HomeState____________________________________

class _HomeState extends State<Home> {
  //_____________fields_______________
  bool _classesInitialized = false;
  late List<String> _classes; //contains all classes for this professor
  final cloud = CloudStorage("prof");

  //_____________init_______________
  @override
  void initState() {
    super.initState();
    _initClasses();
  }

  //_____________init classes_____________
  void _initClasses() async {
    _classes = await cloud.getClasses();
    setState(() {
      _classesInitialized = true;
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
    await cloud.addClass(className);
    setState(() {
      _classes.add(className);
    });
  }

  void _removeClass(String className) async {
    await cloud.removeClass(className);
    setState(() {
      _classes.removeWhere((element) => element == className);
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

  Widget _getClassTile(String className, BuildContext context) {
    return ListTile(
      title: Text(className),
      onTap: () => {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ClassHome(title: className),
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
        title: Text(widget.title),
        leading: IconButton(
          onPressed: () => {print("Logout is not yet implemented")},
          tooltip: "Logout",
          icon: const Icon(Icons.logout),
        ),
      ),
      body: _getClassList(context),
      persistentFooterButtons: [
        FloatingActionButton(
          onPressed: () => _promptAddClass(context),
          tooltip: "Add a class",
          child: const Icon(Icons.add),
        ),
        FloatingActionButton(
          onPressed: () => _promptRemoveClass(context),
          tooltip: "Remove a class",
          child: const Icon(Icons.remove),
        ),
      ],
      persistentFooterAlignment: AlignmentDirectional.center,
    );
  }
}