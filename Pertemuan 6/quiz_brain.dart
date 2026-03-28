// ignore_for_file: prefer_final_fields

import 'question.dart';

class QuizBrain {
  int _questionNumber = 0;

  List<Question> _questionBank = [
    Question(
      q: "Jika kita bersalah,  maka kita harus minta maaf", 
      a: true),
    Question(
      q: "Apakah ayam itu tidak bertelur?", 
      a: false),
    Question(
      q: "Banyak mahasiswa yang telat masuk kelas pagi, karena mereka bangun kesiangan", 
      a: true),
  ];

  void nextQuestion() {
    if (_questionNumber < _questionBank.length - 1) {
      _questionNumber++;
    }
    print(_questionNumber);
    print(_questionBank.length);
  }

  String getQuestionText() {
    return _questionBank[_questionNumber].questionText;
  }

  bool getCorrectAnswer() {
    return _questionBank[_questionNumber ].questionAnswer;
  }
}



