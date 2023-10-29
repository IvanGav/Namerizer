import "package:flutter/material.dart";

class Student {
  Student({required this.firstName, required this.lastName, this.preferredName, required this.photo, required this.gender});

  String firstName;
  String lastName;
  String? preferredName;
  Image photo;
  Gender gender;
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