import "package:flutter/material.dart";

class Student {
  Student({required this.firstName, required this.lastName, this.preferredName, required this.photo});

  String firstName;
  String lastName;
  String? preferredName;
  Image photo;
}