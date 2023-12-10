import 'package:google_fonts/google_fonts.dart';
import "package:flutter/material.dart";
import "dart:math";

import "../../util/student.dart";

/*_______________Home_______________*/

class MatchNameGame extends StatefulWidget {
    const MatchNameGame({super.key, required this.title, required this.students});
    final List<Student> students;
    final String title; //class name, class code is not required here

    @override
    State<MatchNameGame> createState() => _MatchNameGameState();
}

class _MatchNameGameState extends State<MatchNameGame> {
    final List<Student> _randomStudents = [];
    final List<Student> _notFemale = [];
    final List<Student> _notMale = [];
    List<Student> _buttonStudents = [];
    List<bool> _buttonState = List.filled(4, false);
    late Student _currStudent;
    late int _notFemaleSize;
    late int _notMaleSize;

    @override
    void initState() {
        super.initState();
        _currStudent = _selectStudent();
        _buildGenderLists();
        _buildButtonStudents();
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
    void _buildButtonStudents() {
        _buttonStudents.clear();
        _buttonStudents.add(_currStudent);
        int range = 3;
        /* generates button names to match currstudents gender */
        if (_currStudent.gender == Gender.male){
            _notFemale.shuffle();
            for (int i = 0; i < range; i++) {
                if (i < _notFemaleSize){
                    if (_notFemale[i].name == _currStudent.name) {
                        range++;    // increases range of search to skip same name 
                    }
                    else {_buttonStudents.add(_notFemale[i]);}
                }
            }         
        } else {
            _notMale.shuffle();
            for (int i = 0; i < range; i++) {
                if (i < _notMaleSize){
                    if (_notMale[i].name == _currStudent.name) {
                        range++;    // increases range of search to skip same name 
                    }
                    else {_buttonStudents.add(_notMale[i]);}
                }
            }            
        }
        _buttonStudents.shuffle();
    }

    Color getBorderColor(int i) {
        if (_buttonState[i] && _buttonStudents.length > i) {
            if (_buttonStudents[i].name == _currStudent.name) {return Colors.green;}
            else {return Colors.red;}
        } 
        else {return Colors.black;}
    }


    /* sets states for next play */
    void _nextPlay(){
        setState(() {      
            _currStudent = _selectStudent();    
            _buildButtonStudents();
            _buttonState = List.filled(4, false);               
        });
    }

    @override
    Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.grey.shade50,
            title:  Text("Match Name Game"),
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
                SizedBox(height: 40),
                Text("How does this Student", 
                    style: TextStyle(fontSize: 20, color: Colors.white,)
                ),
                Text("Look Like?", 
                    style: TextStyle(fontSize: 20, color: Colors.white,)
                ),
                SizedBox(height: 40),

                /*______image of random student______*/
                Container(
                    height: 40, width: 300,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 2, color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: Text( _currStudent.name, style: TextStyle(
                            fontSize: 20, color: Colors.black,
                        )),
                    ),
                ),
                SizedBox(height: 90),

                /*______4 buttons with students portraits______*/
                Row( 
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        ElevatedButton(
                            onPressed: () {setState(() {_buttonState[0] = true;});},
                            child: SizedBox(
                                width: 130, height: 140,
                                child: _buttonStudents.length > 0 ? 
                                    Image(
                                        image: Image.network(_buttonStudents[0].photo.path).image,
                                    )
                                    : null,        
                            ),
                            style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(color: getBorderColor(0), width: 4), 
                                ),
                            ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                            onPressed: () {setState(() {_buttonState[1] = true;});},
                            child: SizedBox(
                                width: 130, height: 140,
                                child: _buttonStudents.length > 1 ? 
                                    Image(
                                        image: Image.network(_buttonStudents[1].photo.path).image,
                                    )
                                    : null,                
                            ),
                            style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(color: getBorderColor(1), width: 4), 
                                ),
                            ),
                        ),
                    ]
                ),
                SizedBox(height: 15),
                Row( 
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        ElevatedButton(
                            onPressed: () {setState(() {_buttonState[2] = true;});},
                            child: SizedBox(
                                width: 130, height: 140,
                                child: _buttonStudents.length > 2 ? 
                                    Image(
                                        image: Image.network(_buttonStudents[2].photo.path).image,
                                    )
                                    : null,               
                            ),
                            style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(color: getBorderColor(2), width: 4), 
                                ),
                            ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                            onPressed: () {setState(() {_buttonState[3] = true;});},
                            child: SizedBox(
                                width: 130, height: 140,
                                child: _buttonStudents.length > 3 ? 
                                    Image(
                                        image: Image.network(_buttonStudents[3].photo.path).image,
                                    )
                                    : null,               
                            ),
                            style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(color: getBorderColor(3), width: 4), 
                                ),
                            ),
                        ),
                    ]
                ),
                SizedBox(height: 50),

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
