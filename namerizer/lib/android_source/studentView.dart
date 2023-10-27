import "package:flutter/material.dart";

import "../util/student.dart";

//_____________________________Home____________________________________

class StudentView extends StatefulWidget {
  const StudentView({super.key, required this.student});

  final Student student;

  @override
  State<StudentView> createState() => _StudentViewState();
}

//_______________________________HomeState____________________________________

class _StudentViewState extends State<StudentView> {
  //_____________fields_______________
  bool _expanded = false;

  //_____________init_______________
  // @override
  // void initState() {
  //   super.initState();
  // }

  //_____________build_______________
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(widget.student.preferredName == null ? (widget.student.firstName + widget.student.lastName) : widget.student.preferredName!),
        subtitle: _expanded ? const Text("I have EXPANDED") : null,
        onTap: () => {
          setState(() {
            _expanded = !_expanded;
          })
        }
    );
  }
}