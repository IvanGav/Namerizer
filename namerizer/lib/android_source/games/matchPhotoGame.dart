import 'package:google_fonts/google_fonts.dart';
import "package:flutter/material.dart";
import "dart:math";

import "../../util/student.dart";

/*_______________Home_______________*/

class MatchPhotoGame extends StatefulWidget {
    const MatchPhotoGame({super.key, required this.title, required this.students});
    final List<Student> students;
    final String title; //class name, class code is not required here

    @override
    State<MatchPhotoGame> createState() => _MatchPhotoGameState();
}

class _MatchPhotoGameState extends State<MatchPhotoGame> {
    final List<Student> _randomStudents = [];
    final List<Student> _notFemale = [];
    final List<Student> _notMale = [];
    List<String> _buttonNames = [];
    late Student _currStudent;
    late int _notFemaleSize;
    late int _notMaleSize;
    

    @override
    void initState() {
        super.initState();
        _currStudent = _selectStudent();
        _buildGenderLists();
        _buildButtonNames();
    }

    /* populates notMale & notFemale list (non-bi is put into both)*/
    void _buildGenderLists() {
        for(int i = 0; i < widget.students.length; i++){
            if (widget.students[i].gender == Gender.male) {
                _notFemale.add(widget.students[i]);
            } 
            else if (widget.students[i].gender == Gender.female) {
                _notMale.add(widget.students[i]);
            } 
            else {
                _notFemale.add(widget.students[i]);
                _notMale.add(widget.students[i]);
            }
        }
        _notFemaleSize = _notFemale.length;
        _notMaleSize = _notMale.length;
    }

    /* populates randomStudents list In random order */
    void _buildRandomStudents() {
        List<int> order = List.generate(widget.students.length,(i) => i);
        List<int> rand = [];
        while(order.isNotEmpty) {
            int i = Random().nextInt(order.length); //possible freeze location?
            rand.add(order[i]);
            order.removeAt(i);
        }
        for(int i in rand) {
            _randomStudents.add(widget.students[i]);
        }
    }

    /* returns student fromm randomStudents list */
    Student _selectStudent() {
        if(_randomStudents.isEmpty) {
            _buildRandomStudents();
        }
        Student s = _randomStudents.last;
        _randomStudents.removeLast();
        return s;
    }

    /* gets the list of buttons names */
    void _buildButtonNames() {
        _buttonNames.clear();
        _buttonNames.add(_currStudent.name);
        int range = 3;
        /* generates button names to match currstudents gender */
        if (_currStudent.gender == Gender.male){
            _notFemale.shuffle();
            for (int i = 0; i < range; i++) {
                if (_notFemale[i].name == _currStudent.name) {
                    range++;    // increases range of search to skip same name
                }
                else if (i <_notFemaleSize){
                    _buttonNames.add(_notFemale[i].name);
                }
            }         
        } else {
            _notMale.shuffle();
            for (int i = 0; i < range; i++) {
                if (_notMale[i].name == _currStudent.name) {
                    range++;    // increases range of search to skip same name
                }
                else if (i <_notMaleSize){
                    _buttonNames.add(_notMale[i].name);
                }
            }            
        }
        _buttonNames.shuffle();
    }

    /* sets states for next play */
    void _nextPlay(){
        setState(() {      
            _currStudent = _selectStudent();
            _buildButtonNames();
        });
    }

    @override
    Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.blueGrey.shade100,
            title:  Text("Match Photo Game", 
                    style: TextStyle(
                        fontFamily: GoogleFonts.calistoga().fontFamily 
                    )
                ),
        ),
        body: Container(
            /*_________backround image_________*/
            decoration: BoxDecoration(
                image: DecorationImage(
                image: AssetImage('images/background.jpg'),
                fit: BoxFit.cover,
                ),
            ),
            /*_________main structure_________*/
            child: Center(child: Column( children: [
                /*_______Description_______*/
                SizedBox(height: 30),
                Text("What is This Student's", 
                    style: TextStyle(
                    fontSize: 20, color: Colors.white,
                    fontFamily: GoogleFonts.calistoga().fontFamily 
                    )
                ),
                Text("Name ...", 
                    style: TextStyle(
                    fontSize: 20, color: Colors.white,
                    fontFamily: GoogleFonts.calistoga().fontFamily 
                    )
                ),
                SizedBox(height: 10),

                /*______image of random student______*/
                SizedBox(
                    width: 200, height: 200,
                    child: Image(
                    image: Image.network(_currStudent.photo.path).image, 
                    width: 100,height: 100,
                    ),
                ),
                SizedBox(height: 60),

                /*______4 button of student's name______*/
                ElevatedButton(
                onPressed: () {
                    bool isCorrect = _buttonNames.length > 0 && _buttonNames[0] == _currStudent.name;
                    print("Selected: ${_buttonNames.length > 0 ? _buttonNames[0] : "Not enough names"}, Correct: $isCorrect");
                },
                child: Text(_buttonNames.length > 0 ? _buttonNames[0] : "Not enough names", style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(340, 50),
                    primary: _buttonNames.length > 0 && _buttonNames[0] == _currStudent.name ? Colors.green : Colors.red,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: Colors.black, width: 2) 
                    )             
                )
                ),
                SizedBox(height: 15),
                ElevatedButton(
                    onPressed: () => print("Selected: ${_buttonNames.length > 1 ? _buttonNames[1] : "Not enough names"}"),
                    child: Text(_buttonNames.length > 1 ? _buttonNames[1] : "Not enough names", style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                    minimumSize: Size(340, 50),
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.black, width: 2) 
                    )             
                    )
                ),
                SizedBox(height: 15),
                ElevatedButton(
                    onPressed: () => print("Selected: ${_buttonNames.length > 2 ? _buttonNames[2] : "Not enough names"}"),
                    child: Text(_buttonNames.length > 2 ? _buttonNames[2] : "Not enough names", style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                    minimumSize: Size(340, 50),
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.black, width: 2) 
                    )             
                    )
                ),
                SizedBox(height: 15),
                ElevatedButton(
                    onPressed: () => print("Selected: ${_buttonNames.length > 3 ? _buttonNames[3] : "Not enough names"}"),
                    child: Text(_buttonNames.length > 1 ? _buttonNames[3] : "Not enough names", style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                    minimumSize: Size(340, 50),
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.black, width: 2) 
                    )             
                    )
                ),
                SizedBox(height: 35),

                /*_____button to switch to next student_____*/
                FloatingActionButton(
                    onPressed: _nextPlay,
                    tooltip: "Next Play",
                    backgroundColor: Colors.blueGrey.shade100,
                    child: const Icon(Icons.arrow_forward),
                ),

            ],),),
        ),
    );
    }
}
