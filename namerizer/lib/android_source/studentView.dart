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

  //_____________methods_______________
  void expand() {
    setState(() {
      _expanded = true;
    });
  }

  void minimize() {
    setState(() {
      _expanded = false;
    });
  }

  void toggle() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  //_____________build_______________
  @override
  Widget build(BuildContext context) {
    //image is too small
    return ListTile(
      leading: CircleAvatar( //too small?
        backgroundImage: Image.network(widget.student.photo.path).image,
        radius: _expanded ? 30 : 20,
      ),
      trailing: null, //here goes pronunciation when expanded, if we get to it
      title: Text(
        widget.student.name,
        maxLines: 1,
      ),
      subtitle: _expanded ? Text(
        "${widget.student.fullName}, ${widget.student.gender.name}",
        maxLines: 1,
      ) : null,
      dense: true,
      visualDensity: _expanded ? const VisualDensity(vertical: VisualDensity.maximumDensity) : const VisualDensity(vertical: 0),
      onTap: toggle,
    );
  }
}