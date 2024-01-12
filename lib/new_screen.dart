import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewPage extends StatefulWidget {
  final String info;
  const NewPage({super.key, required this.info});

  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("Firebase Messaging"),
         centerTitle: true,
      ),
      body: Center(

        child: Text(widget.info),
      ),
    );
  }
}
