import "package:flutter/material.dart";
import "package:namerizer/android_source/studentView.dart";

import "../../util/cloudStorage.dart";
import "../../util/student.dart";

//_____________________________Home____________________________________

class ClassHome extends StatefulWidget {
  const ClassHome({super.key, required this.title, required this.cloud});

  final String title; //class name
  final CloudStorage cloud;

  @override
  State<ClassHome> createState() => _ClassHomeState();
}

//_______________________________HomeState____________________________________

class _ClassHomeState extends State<ClassHome> {
  //_____________fields_______________
  bool _studentsInitialized = false;
  late List<Student> _students;

  //_____________init_______________
  @override
  void initState() {
    super.initState();
    _initStudents();
  }

  void _initStudents() async {
    _students = await widget.cloud.getStudents(widget.title);
    setState(() {
      _studentsInitialized = true;
    });
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

  //_____________build_______________
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: _getStudentList(),
      ),
      persistentFooterButtons: [
        FloatingActionButton(
          onPressed: () => {print("The game is not yet implemented")},
          tooltip: "Flash Cards",
          child: const Text("Flash"),
        ),
        FloatingActionButton(
          onPressed: () => {print("The game is not yet implemented")},
          tooltip: "Match Name",
          child: const Text("Match Name"),
        ),
        FloatingActionButton(
          onPressed: () => {print("The game is not yet implemented")},
          tooltip: "Match Photo",
          child: const Text("Match Photo"),
        ),
      ],
      persistentFooterAlignment: AlignmentDirectional.center,
    );
  }
}