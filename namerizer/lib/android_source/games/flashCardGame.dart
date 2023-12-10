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
  bool _animationActive = false;

  //_____________init_______________
  @override
  void initState() {
    super.initState();
    _nextCard();
  }

  //_____________get next card_______________
  void _nextCard() {
    if(!_animationActive) {
      setState(() {
        _animationActive = true;
        _card = FlashCard(student: _nextStudent(),
            key: ValueKey<int>(
                _randomOrder.length)); //should be unique for each 2 cards
      });
    }
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
      duration: const Duration(milliseconds: 400),
      transitionBuilder: _transitionBuilder,
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: _card,
    );
  }

  Widget _transitionBuilder(Widget widget, Animation<double> animation) {
    final anim = Tween(begin: 300.0, end: 0.0).animate(animation)..addListener(() {
      if (animation.status == AnimationStatus.completed) {
        _animationActive = false;
      }
    });
    return AnimatedBuilder(
      animation: anim,
      child: widget,
      builder: (context, widget) {
        return Transform(
          transform: Matrix4.translationValues(anim.value,0,0),
          alignment: Alignment.center,
          child: widget,
        );
      },
    );
  }

  //_____________build_______________
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        title:  Text("Flash Card Game"),
      ),
      body: Container(
        /*_________backround image_________*/
        decoration: BoxDecoration(
            image: DecorationImage(
            image: AssetImage('images/background.jpg'),
            fit: BoxFit.cover,
            ),
        ),
        /*_________main structure_________*/
        child: Center(child: Column( children: [

          /*_______description_______*/
          SizedBox(height: 50),
          Text("Click The Card", 
            style: TextStyle(fontSize: 20, color: Colors.white)
          ),
          Text("To Reveal The Name", 
            style: TextStyle(fontSize: 20, color: Colors.white)
          ),
          SizedBox(height: 10),
          Container(width: 300, height: 2, color: Colors.white),

          /*_______flash card_______*/
          SizedBox(height: 100),
          _animateCard(),
          SizedBox(height: 100),

          /*_______next card button_______*/
          FloatingActionButton(
            onPressed: () => _nextCard(),
            tooltip: "Next Card",
            backgroundColor: Colors.grey.shade50,
            child: const Icon(Icons.arrow_forward),
          ),
        ]))
      ),
    );
  }
}