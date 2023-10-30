import "dart:math";

import "package:flutter/material.dart";

import "../../util/student.dart";
import "flashCard.dart";

//_____________________________Home____________________________________

class FlashCardGame extends StatefulWidget {
  const FlashCardGame({super.key, required this.title, required this.students});

  final String title; //class name, class code is not required here
  final List<Student> students;

  @override
  State<FlashCardGame> createState() => _FlashCardGameState();
}

//_______________________________HomeState____________________________________

class _FlashCardGameState extends State<FlashCardGame> {
  //_____________fields_______________
  final List<Student> _randomOrder = [];
  late FlashCard _card;

  //_____________init_______________
  @override
  void initState() {
    super.initState();
    _nextCard();
  }

  //_____________get next card_______________
  void _nextCard() {
    setState(() {
      _card = FlashCard(student: _nextStudent(), key: ValueKey<int>(_randomOrder.length));
    });
  }

  Student _nextStudent() {
    if(_randomOrder.isEmpty) {
      _rebuildRandomOrder();
    }
    Student s = _randomOrder.last;
    _randomOrder.removeLast();
    return s;
  }

  //populate randomOrder with elements from widget.students, in random order
  void _rebuildRandomOrder() {
    List<int> order = List.generate(widget.students.length,(i) => i);
    List<int> rand = [];
    while(order.isNotEmpty) {
      int i = Random().nextInt(order.length); //possible freeze location?
      rand.add(order[i]);
      order.removeAt(i);
    }
    for(int i in rand) {
      _randomOrder.add(widget.students[i]);
    }
  }

  //_____________animate card_______________
  Widget _animateCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.ease,
      switchOutCurve: Curves.ease,
      child: _card,
    );
  }

  //_____________build_______________
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: _animateCard(),
      ),
      persistentFooterButtons: [
        FloatingActionButton(
          onPressed: () => _nextCard(),
          tooltip: "Next Card",
          child: const Icon(Icons.arrow_forward),
        ),
      ],
      persistentFooterAlignment: AlignmentDirectional.center,
    );
  }
}