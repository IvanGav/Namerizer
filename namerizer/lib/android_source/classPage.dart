import "package:flutter/material.dart";

//_____________________________Home____________________________________

class ClassHome extends StatefulWidget {
  const ClassHome({super.key, required this.title});

  final String title;

  @override
  State<ClassHome> createState() => _ClassHomeState();
}

//_______________________________HomeState____________________________________

class _ClassHomeState extends State<ClassHome> {
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
            Text(
              "You chose class ${widget.title} ",
            ),
          ],
        ),
      ),
    );
  }
}