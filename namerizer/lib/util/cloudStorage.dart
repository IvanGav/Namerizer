import "package:cloud_firestore/cloud_firestore.dart";
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
    QuerySnapshot<Map<String,dynamic>> students = await FirebaseFirestore.instance.collection("classes").doc(classCode).collection("students").get();
    print("--num students ${students.docs.length}");
    List<Student> studentsList = [];
    for(var d in students.docs) {
      Student s = Student(
        firstName: d["first_name"],
        lastName: d["last_name"],
        preferredName: d["preferred_name"],
        gender: GenderString.of(d["gender"]),
        photo: d["picture"],
      );
      studentsList.add(s);
    }
    return studentsList;
  }

  ///add a student to a class with a specified class code
  ///*return false if class doesn't exist*
  Future<bool> addStudent(String classCode, Student student) async {
    while(!_init) {
      await initializeDefault();
    }
    final fireRef = FirebaseStorage.instance.ref();
    final picRef = fireRef.child(student.fullName);
    try {
      picRef.putString(student.photo, format: PutStringFormat.dataUrl);
    } on FirebaseException catch (e) {
      return false;
    }
    await FirebaseFirestore.instance.collection("classes").doc(classCode).collection("students").add({
      "first_name": student.firstName,
      "last_name": student.lastName,
      "preferred_name": student.lastName,
      "gender": student.gender.name,
      "picture": await fireRef.child(student.fullName).getDownloadURL(),
    });
    return true;
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
    DocumentSnapshot<Map<String,dynamic>> prof = await FirebaseFirestore.instance.collection("profiles").doc(professor).get();
    List<String> classes = [];
    for(final c in prof["classes"]) {
      if(c is String) {
        classes.add(c);
      } else {
        print("--$c is not a string");
      }
    }
    return classes;
  }

  ///get a class name of a class, by class code
  ///*return null if class doesn't exist*
  Future<String?> getClassName(String classCode) async {
    while(!_init) {
      await initializeDefault();
    }
    DocumentSnapshot<Map<String,dynamic>> classData = await FirebaseFirestore.instance.collection("classes").doc(classCode).get();
    return classData["class_name"];
  }

  ///get a professor name from a class code
  ///*return null if class doesn't exist*
  Future<String?> getClassProfessor(String classCode) async {
    while(!_init) {
      await initializeDefault();
    }
    DocumentSnapshot<Map<String,dynamic>> classData = await FirebaseFirestore.instance.collection("classes").doc(classCode).get();
    return classData["prof_name"];
  }

  //get a map of class code to class name
  //only works if 'professor' uid is not null and is valid
  // Future<Map<String,String>> getClassNames() async {
  //   while(!_init) {
  //     await initializeDefault();
  //   }
  //   DocumentSnapshot<Map<String,dynamic>> classData = await FirebaseFirestore.instance.collection("classes").doc(classCode).get();
  //   return classData["prof_name"];
  // }

  ///create a class with a specified name and return a class code of that class
  ///*only works if 'professor' uid is not null and is valid*
  Future<String?> addClass(String className) async {
    while(!_init) {
      await initializeDefault();
    }
    if(professor == null || (await getUserName()) == null) {
      return null;
    }
    String profName = (await getUserName())!;
    //create and add a class to firebase
    final DocumentReference classDoc = await FirebaseFirestore.instance.collection("classes").add({
      "class_name": className,
      "prof_name": profName,
    });
    classDoc.collection("classes").get(); //attempt to create a new collection
    //add a class to professor
    final profReference = await FirebaseFirestore.instance.collection("profiles").doc(professor).get();
    List<String> classList = profReference["classes"];
    classList.add(classDoc.id);
    await FirebaseFirestore.instance.collection("profiles").doc(professor).update({
      "classes": classList,
    });
    return classDoc.id;
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
    //create and add a class to firebase
    await FirebaseFirestore.instance.collection("classes").doc(classCode).delete();
    //add a class to professor
    final profReference = await FirebaseFirestore.instance.collection("profiles").doc(professor).get();
    List<String> classList = profReference["classes"];
    classList.remove(classCode);
    await FirebaseFirestore.instance.collection("profiles").doc(professor).update({
      "classes": classList,
    });
    return true;
  }

  //_____________professor_______________
  //get info of a user by their uid; contains 'name','email','uid'
  //only works if 'professor' uid is not null and is valid
  Future<String?> getUserName() async {
    if(professor == null) {
      return null;
    }
    final name = await FirebaseFirestore.instance.collection("profiles").doc(professor).get();
    return name["name"];
  }

  //get info of a user by their uid; contains 'name','email','password','classes list'
  //only works if 'professor' uid is not null and is valid
  Future<Map<String,dynamic>?> getUser() async {
    if(professor == null) {
      return null;
    }
    final name = await FirebaseFirestore.instance.collection("profiles").doc(professor).get();
    return name.data();
  }

  //create a new user
  Future<bool> addUser(String uid, String name, String email, String password) async {
    await FirebaseFirestore.instance.collection("profiles").doc(uid).set({
      "name": name,
      "email": email,
      "password": password,
      "classes": [],
    });
    return true;
  }
}