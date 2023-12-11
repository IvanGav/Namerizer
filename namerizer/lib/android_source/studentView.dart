import "package:flutter/material.dart";

import "../util/student.dart";

//_____________________________Home____________________________________

class StudentView extends StatefulWidget {
  const StudentView({super.key, required this.student, required this.deleteFun});

  final Student student;
  final Function(BuildContext,Student) deleteFun;

  @override
  State<StudentView> createState() => _StudentViewState();
}

//_______________________________HomeState____________________________________

class _StudentViewState extends State<StudentView> {
  //_____________fields_______________
  bool _expanded = false;

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
      trailing: _expanded ? IconButton( //here would have gone pronunciation if I didn't put delete
        icon: const Icon(Icons.delete_forever),
        onPressed: () => widget.deleteFun(context,widget.student)
      ) : null,
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