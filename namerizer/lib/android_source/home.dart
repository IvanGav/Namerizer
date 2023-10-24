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
  //_____________fields_______________
  int _counter = 0;
  late var _classes; //contains all classes for this professor

  //_____________add/remove a class_______________
  void _addClass() {
    setState(() {
      _counter++;
    });
  }

  void _removeClass() {
    setState(() {
      _counter--;
    });
  }

  //_____________class list widget getter_______________
  Widget _getClassList(BuildContext context) {
    if(_classes != null) {

    }
    List<Widget> classList = [];
    for(const c in _classes) {
      classList.add(_getClassTile(c, context));
    }
    return ListView(
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
            Text(
              "$_counter",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
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