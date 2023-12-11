import "package:cross_file/cross_file.dart";

class Student {
  Student({required this.firstName, required this.lastName, this.preferredName, required this.photo, required this.gender, this.id});

  String firstName;
  String lastName;
  String? preferredName;
  XFile photo;
  Gender gender;
  String? id;

  String get name {
    if(preferredName == null || preferredName == "") {
      return fullName;
    }
    return preferredName!;
  }

  String get fullName {
    return "$firstName $lastName";
  }
}

enum Gender {
  male, female, nonbinary;
}

extension GenderString on Gender {
  String get name {
    switch (this) {
      case Gender.male:
        return "Male";
      case Gender.female:
        return "Female";
      case Gender.nonbinary:
        return "Non Binary";
    }
  }
  static Gender of(String str) {
    if(str == "Male") {
      return Gender.male;
    } else if(str == "Female") {
      return Gender.female;
    } else {
      return Gender.nonbinary;
    }
  }
}