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
    List<bool> _buttonState = List.filled(4, false);
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
                if (i < _notFemaleSize){
                    if (_notFemale[i].name == _currStudent.name) {
                        range++;    // increases range of search to skip same name 
                    }
                    else {_buttonNames.add(_notFemale[i].name);}
                }
            }         
        } else {
            _notMale.shuffle();
            for (int i = 0; i < range; i++) {
                if (i < _notMaleSize){
                    if (_notMale[i].name == _currStudent.name) {
                        range++;    // increases range of search to skip same name 
                    }
                    else {_buttonNames.add(_notMale[i].name);}
                }
            }            
        }
        _buttonNames.shuffle();
    }

    String getButtonName(int i) {
        if (_buttonNames.length > i){return _buttonNames[i];}
        else {return "";}
    }

    Color getButtonColor(int i) {
        if (_buttonState[i] && _buttonNames.length > i) {
            if (_buttonNames[i] == _currStudent.name) {return Colors.green;}
            else {return Colors.red;}
        } 
        else {return Colors.white;}
    }


    /* sets states for next play */
    void _nextPlay(){
        setState(() {      
            _currStudent = _selectStudent();    
            _buildButtonNames();
            _buttonState = List.filled(4, false);               
        });
    }

    @override
    Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.grey.shade50,
            title:  Text("Match Photo Game"),
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
                    style: TextStyle(fontSize: 20, color: Colors.white,)
                ),
                Text("Name?", 
                    style: TextStyle(fontSize: 20, color: Colors.white,)
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
                    onPressed: () {setState(() {_buttonState[0] = true;});},
                    child: Text(getButtonName(0),style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(340, 50),
                        primary: getButtonColor(0),
                        onPrimary: Colors.black,
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.black, width: 2),
                        ),
                    ),
                    ),
                SizedBox(height: 15),
                ElevatedButton(
                    onPressed: () {setState(() {_buttonState[1] = true;});},
                    child: Text(getButtonName(1),style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                    minimumSize: Size(340, 50),
                    primary: getButtonColor(1),
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.black, width: 2) 
                    )             
                    )
                ),
                SizedBox(height: 15),
                ElevatedButton(
                    onPressed: () {setState(() {_buttonState[2] = true;});},
                    child: Text(getButtonName(2),style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                    minimumSize: Size(340, 50),
                    primary: getButtonColor(2),
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.black, width: 2) 
                    )             
                    )
                ),
                SizedBox(height: 15),
                ElevatedButton(
                    onPressed: () {setState(() {_buttonState[3] = true;});},
                    child: Text(getButtonName(3),style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                    minimumSize: Size(340, 50),
                    primary: getButtonColor(3),
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
                    backgroundColor: Colors.grey.shade50,
                    child: const Icon(Icons.arrow_forward),
                ),

            ],),),
        ),
    );
    }
}
