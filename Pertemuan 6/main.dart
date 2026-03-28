import 'package:flutter/material.dart';
import 'package:quiz/question.dart';
import 'package:quiz/quiz_brain.dart';

QuizBrain quizBrain = QuizBrain();

void main() {
  runApp(MaterialApp(
    home:Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Quiz(),
          ),
        ),
      ),
  ));
}

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  List<Widget> scoreKeeper = [];

  void checkAnswer(bool userPickedAnswer) {
    print(userPickedAnswer);
    bool correctAnswer = quizBrain.getCorrectAnswer();
        if (userPickedAnswer == correctAnswer) {
          scoreKeeper.add(Icon(
            Icons.check,
            color: Colors.green,
          ));
        } else {
          scoreKeeper.add(Icon(
            Icons.close,
            color: Colors.red,
          ));
        }
    setState(() {
      quizBrain.nextQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Center(
              child: Text(
                quizBrain.getQuestionText(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
                textAlign: TextAlign.center,
              ),
            ), 
          ),
        ),
        GestureDetector(
          onTap: () {
            checkAnswer(true);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.lightGreen,
            ),
            height: 100,
            width: double.infinity,
            margin: EdgeInsets.all(15),
            child: Center(
              child: Text(
                "True", 
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            checkAnswer(false);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.redAccent,
            ),
            height: 100,
            width: double.infinity,
            margin: EdgeInsets.all(15),
            child: Center(
              child: Text(
                "False", 
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
        Row(
          children: scoreKeeper,
        )
      ],
    );
  }
}

