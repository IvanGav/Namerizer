import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "../main.dart";

//________________________ClassHome________________________

class CodePage extends StatefulWidget {
  const CodePage({super.key, required this.code, required this.title});

  final String code; //class code
  final String title;

  @override
  State<CodePage> createState() => _CodePageState();
}

//___________________ClassHomeState____________________

class _CodePageState extends State<CodePage> {
  //_____________fields_______________
  late final String header;
  late final String text;
  late final String buttonText;

  //_____________init_______________
  @override
  void initState() {
    super.initState();
    //SITE global variable is defined in main.dart
    header = "Class name: ${widget.title}\nClass code:   ${widget.code}";
    text = "To enroll in the class, go to $SITE and enter the class code, or go directly to\n$SITE/${widget.code}\n\nEnter your information and wait for confirmation. For questions, email <ivan.gavby@gmail.com>.";
    buttonText = "Press buttons below to copy the whole instructions or just the class code to clipboard.";
  }

  //_____________methods_______________
  Widget _getBody() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Text(header, style: const TextStyle(color: Colors.white, fontSize: 22)),
          const SizedBox(height: 50),
          Container(
            height: 340, width: 365,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 2, color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Text(text, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  Text(buttonText, style: const TextStyle(fontSize: 16))
                ]
            ))
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _copyCode(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.white, minimumSize: const Size(90, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: const BorderSide(color: Colors.black, width: 2)
                  )
                ),
                child: const Text("Code")
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => _copyAll(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.white, minimumSize: const Size(90, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: const BorderSide(color: Colors.black, width: 2)
                  )
                ),
                child: const Text("All")
              ),
            ]
          )
        ]
      )
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.code)).whenComplete(() {
      var snackBar = const SnackBar(
        content: Text("Copied to Clipboard"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  void _copyAll(BuildContext context) {
    Clipboard.setData(ClipboardData(text: "$header\n\n$text")).whenComplete(() {
      var snackBar = const SnackBar(
        content: Text("Copied to Clipboard"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  //_____________build_______________
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Class Code"),
        backgroundColor: Colors.grey.shade50,
      ),
      body: Container(
        /*_________background image_________*/
        decoration: const BoxDecoration(
            image: DecorationImage(
            image: AssetImage('images/background.jpg'),
            fit: BoxFit.cover,
            ),
        ),
        child: _getBody(),
      ),
    );
  }
}