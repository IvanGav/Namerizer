import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_core/firebase_core.dart";
import "../firebase_options.dart";

class CloudStorage {
  //_____________fields_______________
  bool _init = false;

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

  //_____________other..._______________
}