import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 242, 60, 121),
        appBar: AppBar(
          title: Text("I am Septiana"),
          backgroundColor: const Color.fromARGB(255, 255, 148, 184),
        ),
        body: Center(
          child: Image(
            image: AssetImage('images/Foto Project.jpeg'),
            )
            ),
      ),
    ),
  );
}
