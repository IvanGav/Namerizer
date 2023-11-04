import 'dart:io';

class Student {
  Student({required this.firstName, required this.lastName, this.preferredName, required this.photo, required this.gender});

  String firstName;
  String lastName;
  String? preferredName;
  String photo; //path to an image
  Gender gender;

  String get name {
    if(preferredName != null) {
      return preferredName!;
    }
    return fullName;
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