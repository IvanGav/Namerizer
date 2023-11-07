import "dart:math";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:cross_file/cross_file.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:firebase_core/firebase_core.dart";

import "../firebase_options.dart";
import "student.dart";

class CloudStorage {
  CloudStorage({this.professor});

  //_____________fields_______________
  bool _init = false;
  String? professor;

  //_____________init_______________
  Future<void> initializeDefault() async {
    FirebaseApp app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // app.delete(); ???
    _init = true;
  }

  //_____________student_______________
  ///get a list of all students by class code
  ///*return null if class doesn't exist*
  Future<List<Student>?> getStudents(String classCode) async {
    while(!_init) {
      await initializeDefault();
    }
    if(professor == null) {
      return null;
    }
    try {
      QuerySnapshot<Map<String, dynamic>> students = await FirebaseFirestore
          .instance.collection("classes").doc(classCode)
          .collection("students")
          .get();
      print("--num students ${students.docs.length}");
      List<Student> studentsList = [];
      for (var d in students.docs) {
        Student s = Student(
          firstName: d["first_name"],
          lastName: d["last_name"],
          preferredName: d["preferred_name"],
          gender: GenderString.of(d["gender"]),
          photo: XFile(d["picture"]),
        );
        studentsList.add(s);
      }
      return studentsList;
    } catch (e) {
      print("--getStudents wasn't successful");
      return null;
    }
  }

  ///add a student to a class with a specified class code
  ///*return false if class doesn't exist*
  Future<bool> addStudent(String classCode, Student student) async {
    while(!_init) {
      await initializeDefault();
    }
    //I lost all hope. Nothing was working...
    //But after 3 days of work and failures...
    //At last, something worked... And I was so happy.
    //And I'm too afraid to touch it until it breaks for a known and established reason...
    //So I don't care if it's terrible code or not,
    //  I just hope it works and I never have to touch it again...
    try {
      final fireRef = FirebaseStorage.instance.ref();
      final picRef = fireRef.child(classCode).child(
          "${Random().nextDouble()}.png");
      try {
        await picRef.putData(
            await student.photo.readAsBytes(),
            SettableMetadata(contentType: "image/png")
        ).whenComplete(() => _putStudent(classCode, student, picRef));
      } on FirebaseException catch (e) {
        return false;
      } catch (e) {
        return false;
      }
      return true;
    } catch (e) {
      print("--addStudent wasn't successful");
      return false;
    }
  }

  //TODO
  Future<bool> deleteStudent(String classCode, Student student) async {
    return false;
  }

  Future<void> _putStudent(String classCode, Student student, Reference picRef) async {
    await FirebaseFirestore.instance.collection("classes").doc(classCode).collection("students").add({
      "first_name": student.firstName,
      "last_name": student.lastName,
      "preferred_name": student.preferredName,
      "gender": student.gender.name,
      "picture": await picRef.getDownloadURL(),
    });
  }

  //_____________class_______________
  ///get a list of all class codes for this professor
  ///*only works if 'professor' uid is not null and is valid*
  Future<List<String>?> getClasses() async {
    while(!_init) {
      await initializeDefault();
    }
    if(professor == null) {
      return null;
    }
    List<String> classes = [];
    try {
      DocumentSnapshot<Map<String, dynamic>> prof = await FirebaseFirestore
          .instance.collection("profiles").doc(professor).get();
      for (final c in prof["classes"]) {
        if (c is String) {
          classes.add(c);
        } else {
          print("--$c is not a string");
        }
      }
      return classes;
    } catch (e) {
      print("--getClasses wasn't successful");
      return null;
    }
  }

  ///get a class name of a class, by class code
  ///*return null if class doesn't exist*
  Future<String?> getClassName(String classCode) async {
    while(!_init) {
      await initializeDefault();
    }
    //Unhandled Exception: Bad state: cannot get a field on a DocumentSnapshotPlatform which does not exist
    try {
      DocumentSnapshot<Map<String, dynamic>> classData = await FirebaseFirestore
          .instance.collection("classes").doc(classCode).get();
      return classData["class_name"];
    } catch (e) {
      print("--getClassName wasn't successful");
      return null;
    }
  }

  ///get a professor name from a class code
  ///*return null if class doesn't exist*
  Future<String?> getClassProfessor(String classCode) async {
    while(!_init) {
      await initializeDefault();
    }
    try {
      DocumentSnapshot<Map<String, dynamic>> classData = await FirebaseFirestore
          .instance.collection("classes").doc(classCode).get();
      return classData["prof_name"];
    } catch (e) {
      print("--getClassProfessor wasn't successful");
      return null;
    }
  }

  ///create a class with a specified name and return a class code of that class
  ///*only works if 'professor' uid is not null and is valid*
  Future<String?> addClass(String className) async {
    while(!_init) {
      await initializeDefault();
    }
    try {
      if (professor == null || (await getUserName()) == null) {
        return null;
      }
      String profName = (await getUserName())!;
      //create and add a class to firebase
      final DocumentReference classDoc = await FirebaseFirestore.instance
          .collection("classes").add({
        "class_name": className,
        "prof_name": profName,
      });
      classDoc.collection("classes").get(); //attempt to create a new collection
      //add a class to professor
      final profReference = await FirebaseFirestore.instance.collection(
          "profiles").doc(professor).get();
      List<dynamic> classList = profReference["classes"];
      classList.add(classDoc.id);
      await FirebaseFirestore.instance.collection("profiles")
          .doc(professor)
          .update({
        "classes": classList,
      });
      return classDoc.id;
    } catch (e) {
      print("--addClass wasn't successful");
      return null;
    }
  }

  //remove a class by class code
  //*only works if 'professor' uid is not null and is valid*
  Future<bool> removeClass(String classCode) async {
    while(!_init) {
      await initializeDefault();
    }
    if(professor == null) {
      return false;
    }
    try {
      //remove a class from firebase
      await FirebaseFirestore.instance.collection("classes")
          .doc(classCode)
          .delete();
      //remove a class from a professor
      final profReference = await FirebaseFirestore.instance.collection(
          "profiles").doc(professor).get();
      List<dynamic> classList = profReference["classes"];
      classList.remove(classCode);
      await FirebaseFirestore.instance.collection("profiles")
          .doc(professor)
          .update({
        "classes": classList,
      });
      return true;
    } catch (e) {
      print("--removeClass wasn't successful");
      return false;
    }
  }

  //_____________professor_______________
  //get info of a user by their uid; contains 'name','email','uid'
  //only works if 'professor' uid is not null and is valid
  Future<String?> getUserName() async {
    if(professor == null) {
      return null;
    }
    try {
      final name = await FirebaseFirestore.instance.collection("profiles").doc(
          professor).get();
      return name["name"];
    } catch (e) {
      print("--getUserName wasn't successful");
      return null;
    }
  }

  //get info of a user by their uid; contains 'name','email','password','classes list'
  //only works if 'professor' uid is not null and is valid
  Future<Map<String,dynamic>?> getUser() async {
    if(professor == null) {
      return null;
    }
    try {
      final name = await FirebaseFirestore.instance.collection("profiles").doc(
          professor).get();
      return name.data();
    } catch (e) {
      print("--getUser wasn't successful");
      return null;
    }
  }

  //create a new user
  Future<bool> addUser(String uid, String name, String email, String password) async {
    try {
      await FirebaseFirestore.instance.collection("profiles").doc(uid).set({
        "name": name,
        "email": email,
        "password": password,
        "classes": [],
      });
      return true;
    } catch (e) {
      print("--addUser wasn't successful");
      return false;
    }
  }
}