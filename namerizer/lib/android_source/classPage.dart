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
        /*_______backround color_______*/ 
        flexibleSpace: Container( 
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        /*_______title & buttons_______*/
        title: Text(_title, style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [ //tailing
          IconButton(
            onPressed: () { print("--Not yet implemented"); },
            tooltip: "Set Up",
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () => _openCodePage(context),
            tooltip: "Go to Code Page",
            icon: const Text("Code", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      /*_______students_______*/
      body: Container(
        color: Colors.grey.shade50,       // backround color
        child: _getStudentList(),         // lists of students
      ),  
      /*_______footer_______*/
      bottomNavigationBar: Container( height: 100,
        /*_______backround image_______*/
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        /*_______Buttons for clases_______*/
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _studentsInitialized ? () => _playFlash(context) : null,
              child: const Text("Flash\nCards"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(100, 70),
                primary: Colors.white, onPrimary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.black, width: 2) 
                )             
              )
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: _studentsInitialized ? () => _playNameMatch(context) : null,
              child: const Text("Match\nName"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(100, 70),
                primary: Colors.white, onPrimary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.black, width: 2) 
                )             
              )
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: _studentsInitialized ? () => _playPhotoMatch(context) : null,
              child: const Text("Match\nPhoto"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(100, 70),
                primary: Colors.white, onPrimary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.black, width: 2) 
                )             
              )
            ),
          ],
        ),
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
    );
  }
}