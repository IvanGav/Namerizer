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
    //image is too small
    return ListTile(
      leading: CircleAvatar( //too small
        backgroundImage: widget.student.photo.image,
        radius: _expanded ? 30 : 20,
      ),
      trailing: null, //here goes pronunciation when expanded, if we get to it
      title: Text(widget.student.preferredName == null ? ("${widget.student.firstName} ${widget.student.lastName}") : widget.student.preferredName!),
      subtitle: _expanded ? Text("${widget.student.firstName} ${widget.student.lastName}, ${widget.student.gender.name}") : null,
      isThreeLine: _expanded ? true : false,
      onTap: () => {
        setState(() {
          _expanded = !_expanded;
        })
      }
    );
  }
}