import "package:flutter/material.dart";
import "package:namerizer/android_source/games/flashCardGame.dart";
import "package:namerizer/android_source/games/matchPhotoGame.dart";
import "package:namerizer/android_source/studentView.dart";

import "../util/student.dart";
import "../util/cloudStorage.dart";

//________________________ClassHome________________________

class ClassHome extends StatefulWidget {
  const ClassHome({super.key, required this.code, required this.cloud});

  final String code; //class code
  final CloudStorage cloud;

  @override
  State<ClassHome> createState() => _ClassHomeState();
}

//___________________ClassHomeState____________________

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

  Future<void> _initStudents() async {
    setState(() {
      _studentsInitialized = false;
    });
    _students = (await widget.cloud.getStudents(widget.code))!; //should be fine
    print("--${_students.length}");
    setState(() {
      _studentsInitialized = true;
    });
  }

  Future<void> _initTitle() async {
    String title = (await widget.cloud.getClassName(widget.code))!; //should also be fine
    setState(() { _title = title; });
  }

  //_____________class list widget getter_______________
  Widget _getStudentList() {
    if(!_studentsInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _initStudents,
      child: ListView.builder(
        itemBuilder: (context, index) => StudentView(student: _students[index]),
        itemCount: _students.length,
      ),
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
  void _playPhotoMatch(BuildContext context){
      Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MatchPhotoGame(title: _title, students: _students),
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
        actions: [ //tailing
          IconButton(
            onPressed: () { print("--Not yet implemented"); },
            tooltip: "Set Up",
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: _getStudentList(),
      persistentFooterButtons: [
        FloatingActionButton(
          heroTag: "flash_game",
          onPressed: _studentsInitialized ? () => _playFlash(context) : null,
          tooltip: "Flash Cards",
          child: const Text("Flash"),
        ),
        FloatingActionButton(
          heroTag: "match_name_game",
          onPressed: () { print("--The game is not yet implemented"); },
          tooltip: "Match Name",
          child: const Text("Match Name"),
        ),
        FloatingActionButton(
          heroTag: "match_photo_game",
          onPressed: _studentsInitialized ? () => _playPhotoMatch(context) : null,
          tooltip: "Match Photo",
          child: const Text("Match Photo"),
        ),
      ],
      persistentFooterAlignment: AlignmentDirectional.center,
    );
  }
}