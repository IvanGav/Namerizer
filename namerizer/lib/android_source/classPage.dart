import "package:flutter/material.dart";
import "package:namerizer/android_source/studentView.dart";

import "../util/student.dart";

//_____________________________Home____________________________________

class ClassHome extends StatefulWidget {
  const ClassHome({super.key, required this.title});

  final String title;

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
    _students = [
      Student(firstName: "John", lastName: "Smith", preferredName: "Ainz Ooal Gown"),
      Student(firstName: "Bocchi", lastName: "Hitori", preferredName: "Guitar Hero"),
      Student(firstName: "Kageno", lastName: "Shadow")];
    _studentsInitialized = true;
  }

  //_____________class list widget getter_______________
  Widget _getStudentList() {
    if(!_studentsInitialized) {
      return const Text("Please Wait...");
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
    );
  }
}