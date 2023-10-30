import "package:flutter/material.dart";
import "package:namerizer/android_source/games/flashCardGame.dart";
import "package:namerizer/android_source/studentView.dart";

import "../util/student.dart";
import "../util/cloudStorage.dart";

//_____________________________Home____________________________________

class ClassHome extends StatefulWidget {
  const ClassHome({super.key, required this.code, required this.cloud});

  final String code; //class code
  final CloudStorage cloud;

  @override
  State<ClassHome> createState() => _ClassHomeState();
}

//_______________________________HomeState____________________________________

class _ClassHomeState extends State<ClassHome> {
  //_____________fields_______________
  bool _studentsInitialized = false;
  late List<Student> _students;
  String _title = "loading...";

  //_____________init_______________
  @override
  void initState() {
    super.initState();
    _initStudents();
    _initTitle();
  }

  void _initStudents() async {
    _students = await widget.cloud.getStudents(widget.code);
    setState(() {
      _studentsInitialized = true;
    });
  }

  void _initTitle() async {
    String title = await widget.cloud.getClassName(widget.code);
    setState(() { _title = title; });
  }

  //_____________class list widget getter_______________
  Widget _getStudentList() {
    if(!_studentsInitialized) {
      return const CircularProgressIndicator();
    }
    List<Widget> studentList = [];
    for(var s in _students) {
      studentList.add(StudentView(student: s));
    }
    return Column(//ListView
      children: studentList,
    );
  }

  //_____________play games_______________
  void _playFlash(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlashCardGame(title: _title, students: _students),
      ),
    );
  }

  //_____________build_______________
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_title),
      ),
      body: Center(
          child: _getStudentList(),
      ),
      persistentFooterButtons: [
        FloatingActionButton(
          heroTag: "flash_game",
          onPressed: () => _playFlash(context),
          tooltip: "Flash Cards",
          child: const Text("Flash"),
        ),
        FloatingActionButton(
          heroTag: "match_name_game",
          onPressed: () { print("The game is not yet implemented"); },
          tooltip: "Match Name",
          child: const Text("Match Name"),
        ),
        FloatingActionButton(
          heroTag: "match_photo_game",
          onPressed: () { print("The game is not yet implemented"); },
          tooltip: "Match Photo",
          child: const Text("Match Photo"),
        ),
      ],
      persistentFooterAlignment: AlignmentDirectional.center,
    );
  }
}