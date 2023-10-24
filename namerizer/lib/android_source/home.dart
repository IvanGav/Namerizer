import "package:flutter/material.dart";
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

  @override
  void initState() {
    super.initState();
    _initClasses();
  }

  //_____________fields_______________
  int _counter = 0;
  bool _classesInitialized = false;
  late List<String> _classes; //contains all classes for this professor

  //
  void _initClasses() async {
    _classes = ["Class1", "Class2"];
    _classesInitialized = true;
  }

  //_____________add/remove a class_______________
  void _addClass() async {
    setState(() {
      _classes.add("NewClass");
    });
  }

  void _removeClass() {
    setState(() {
      _classes.removeLast();
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Classes: ",
            ),
            _getClassList(context),
          ],
        ),
      ),
      persistentFooterButtons: [
        FloatingActionButton(
          onPressed: () => {print("Logout is not yet implemented")},
          tooltip: "Logout",
          child: const Icon(Icons.logout),
        ),
        const SizedBox(width: 20),
        FloatingActionButton(
          onPressed: _addClass,
          tooltip: "Add a class",
          child: const Icon(Icons.add),
        ),
        FloatingActionButton(
          onPressed: _removeClass,
          tooltip: "Remove a class",
          child: const Icon(Icons.remove),
        ),
      ],
      persistentFooterAlignment: AlignmentDirectional.center,
    );
  }
}