import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";

import "../firebase_options.dart";
import "student.dart";

class CloudStorage {
  CloudStorage(this.professor);

  //_____________fields_______________
  bool _init = false;
  String professor;

  //_____________init_______________
  Future<void> initializeDefault() async {
    FirebaseApp app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // app.delete(); ???
    _init = true;
  }

  //_____________int (example)_______________
  //this is not a useful code, but an example of how to do a getter and setter, roughly
  //maybe, functions like "create", "exists", "getAll" or "update" would be useful, not sure
  //my intention is, these functions will take a student and a class as parameters,
  //    and using credentials of the professor, stored somewhere globally, would
  //    update the whole student's profile - if talking about a student
  //    Or "createClass" function could be purely for creating a new class,
  //    or "removeClass", you get the idea
  //Also, making methods that mimic the signature of real methods can be used with just constant
  //    predefined output, to simulate you getting stuff from firebase, without it being set up
  //Make sure to communicate any changes to this class so we both have updated version
  Future<int> getInt(String name) async {
    while(!_init) {
      await initializeDefault();
    }
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot num = await firestore.collection("assignmentproject").doc(name).get(); //get "form" field for String and "count" for int
    return num["count"] ?? 0;
  }

  Future<bool> setInt(String name, int count) async {
    while(!_init) {
      await initializeDefault();
    }
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection("assignmentproject").doc(name).set({
      "count": count,
    }).catchError((error) {
      return Future(false as FutureOr Function()); //i hate this language
    });
    return true;
  }

  //_____________student_______________
  //get a list of all students for this professor
  Future<List<Student>> getStudents(String classCode) async {
    return [
      Student(firstName: "John", lastName: "Smith", preferredName: "Ainz Ooal Gown", gender: Gender.nonbinary, photo: Image.network("https://static.wikia.nocookie.net/the-muse-list/images/4/46/Ainz.jpg/revision/latest?cb=20200607025936")),
      Student(firstName: "Hitori", lastName: "Gotoh", preferredName: "Bocchi", gender: Gender.female, photo: Image.network("https://ih0.redbubble.net/image.4908319264.0145/raf,360x360,075,t,fafafa:ca443f4786.jpg")),
      Student(firstName: "Cid", lastName: "Kageno", gender: Gender.male, photo: Image.network("https://i.pinimg.com/originals/48/78/9e/48789e1ee588a2d305c2a12a0ac6a443.jpg")),
    ];
  }

  //add a student to a class with a specified class code
  Future<bool> addStudent(String classCode, Student student) async {
    return true;
  }

  //_____________class_______________
  //get a list of all classes for this professor
  Future<List<String>> getClasses() async {
    return [
      "CINS 467 TTh",
      "CSCI 411 MTWTh",
      "UWUS 069 SuSa"
    ];
  }

  //create a class with a specified name and return a class code of that class
  Future<String> addClass(String className) async {
    return "new_class_code";
  }

  //remove a class by class code
  Future<bool> removeClass(String classCode) async {
    return true;
  }
}