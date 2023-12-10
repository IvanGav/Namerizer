import "dart:math";

import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';


import "../../util/student.dart";

//_____________________________Home____________________________________

class FlashCard extends StatefulWidget {
  const FlashCard({required super.key, required this.student});

  final Student student;

  @override
  State<FlashCard> createState() => _FlashCardState();
}

//_______________________________HomeState____________________________________

class _FlashCardState extends State<FlashCard> {
  //_____________fields_______________
  bool _turned = false; //turned = false -> looking at the photo; turned = true -> looking at the name
  bool _animationActive = false;

  //_____________init_______________
  @override
  void initState() {
    super.initState();
    _turned = false; //needed?
  }

  //_____________animation_______________
  //https://medium.com/flutter-community/flutter-flip-card-animation-eb25c403f371
  Widget _buildFlipAnimation() {
    return GestureDetector(
      onTap: () {
        setState(() {
          if(!_animationActive) {
            _animationActive = true;
            _turned = !_turned;
          }
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: _transitionBuilder,
        layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
        switchInCurve: Curves.linear,
        switchOutCurve: Curves.linear.flipped,
        child: _turned ? _buildBack() : _buildFront(),
      ),
    );
  }

  Widget _transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation)..addListener(() {
      if (animation.status == AnimationStatus.completed) {
        _animationActive = false;
      }
    });
    return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final isUnder = (ValueKey(_turned) != widget!.key);
        final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
        return Transform(
          transform: Matrix4.rotationY(value),
          alignment: Alignment.center,
          child: widget,
        );
      },
    );
  }

  //return the photo
  Widget _buildFront() {
    return Card(
      clipBehavior: Clip.hardEdge,
      key: const ValueKey<bool>(false),
      child: SizedBox(
        width: 200,
        height: 200,
        child: Image(
          image: Image.network(widget.student.photo.path).image,
          width: 100,
          height: 100,
        ),
      ),
    );
  }

  //return the name
  Widget _buildBack() {
    return Card(
      key: const ValueKey<bool>(true),
      child: SizedBox(
        width: 200,
        height: 200,
        child: Center(
          child: Text(widget.student.name, style: TextStyle(
                      fontSize: 20, color: Colors.black,
                      fontFamily: GoogleFonts.calistoga().fontFamily 
                      )),
        ),
      ),
    );
  }

  //_____________build_______________
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.tight(const Size.square(200)),
      child: _buildFlipAnimation(),
    );
  }
}