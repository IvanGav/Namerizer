import "package:flutter/material.dart";

class Student {
  Student({required this.firstName, required this.lastName, this.preferredName, required this.photo, required this.gender});

  String firstName;
  String lastName;
  String? preferredName;
  Image photo;
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

extension Gndr on Gender {
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
}