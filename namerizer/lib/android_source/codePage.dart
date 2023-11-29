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
  late final String text;

  //_____________init_______________
  @override
  void initState() {
    super.initState();
    //SITE global variable is defined in main.dart
    text = "Class Name: ${widget.title}\nClass code: ${widget.code}\nTo enroll in the class, go to $SITE and enter the class code, or go directly to $SITE/${widget.code}\nEnter your information and wait for confirmation. For questions, email <ivan.gavby@gmail.com>.";
  }

  //_____________methods_______________
  Widget _getBody() {
    return Column(
      children: [
        Text(text),
        const SizedBox(height: 50),
        const Text("Press buttons below to copy the whole instructions or just the class code to clipboard.")
      ]
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
    Clipboard.setData(ClipboardData(text: text)).whenComplete(() {
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Get Class Code"),
      ),
      body: _getBody(),
      persistentFooterButtons: [
        FloatingActionButton(
          heroTag: "copy_code",
          onPressed: () => _copyCode(context),
          tooltip: "Copy Class Code",
          child: const Text("Code"),
        ),
        FloatingActionButton(
          heroTag: "copy_instructions",
          onPressed: () => _copyAll(context),
          tooltip: "Copy Instructions",
          child: const Text("All"),
        ),
      ],
      persistentFooterAlignment: AlignmentDirectional.center,
    );
  }
}