import "package:flutter/material.dart";
import "package:namerizer/android_source/codePage.dart";
import "package:namerizer/android_source/games/flashCardGame.dart";
import "package:namerizer/android_source/games/matchPhotoGame.dart";
import "package:namerizer/android_source/games/matchNameGame.dart";
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
        itemBuilder: (context, index) => StudentView(student: _students[index], deleteFun: _promptDeleteStudent),
        itemCount: _students.length,
      ),
    );
  }

  //_____________other functions______________
  void _promptDeleteStudent(BuildContext context, Student student) {
    if(student.id == null) {
      _snack(context,"Student doesn't have an ID, try refreshing.");
      return;
    }
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Remove a student?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("A student with this name will be permanently deleted:", style: TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              Text(student.fullName),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
                onPressed: () {
                  _deleteStudent(student.id!).then((success) {
                    if(!success) {
                      _snack(context,"Couldn't delete a student, try refreshing.");
                    }
                    return success;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text("Delete", style: TextStyle(color: Colors.red))
            ),
          ],
        )
    );
  }

  Future<bool> _deleteStudent(String studentID) async {
    setState(() {
      _studentsInitialized = false;
    });
    bool? success = await widget.cloud.deleteStudentById(widget.code, studentID);
    setState(() {
      if(success) {
        _students.removeWhere((element) => element.id == studentID);
      }
      _studentsInitialized = true;
    });
    return success;
  }

  void _snack(BuildContext context, String message) {
    var snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
    void _playNameMatch(BuildContext context){
      Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MatchNameGame(title: _title, students: _students),
      ),
    );
  }

  void _openCodePage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CodePage(code: widget.code, title: _title),
      ),
    );
  }

  //_____________build_______________
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /*_______background color_______*/
        flexibleSpace: Container( 
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        /*_______title & buttons_______*/
        title: Text(_title, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [ //tailing
          IconButton(
            onPressed: () => _openCodePage(context),
            tooltip: "Go to Code Page",
            icon: const Text("Code", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      /*_______students_______*/
      body: Container(
        color: Colors.grey.shade50,       // background color
        child: _getStudentList(),         // lists of students
      ),  
      /*_______footer_______*/
      bottomNavigationBar: Container( height: 100,
        /*_______background image_______*/
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        /*_______Buttons for classes_______*/
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _studentsInitialized ? () => _playFlash(context) : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                minimumSize: const Size(100, 70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: const BorderSide(color: Colors.black, width: 2)
                )
              ),
              child: const Text("Flash\nCards")
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _studentsInitialized ? () => _playNameMatch(context) : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                minimumSize: const Size(100, 70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: const BorderSide(color: Colors.black, width: 2)
                )             
              ),
              child: const Text("Match\nName")
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _studentsInitialized ? () => _playPhotoMatch(context) : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                minimumSize: const Size(100, 70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: const BorderSide(color: Colors.black, width: 2)
                )
              ),
              child: const Text("Match\nPhoto")
            ),
          ],
        ),
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
    );
  }
}