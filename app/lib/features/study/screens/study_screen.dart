import 'package:flutter/material.dart';
import 'package:hand2voice/features/study/screens/quiz_loading_screen.dart';

import './quiz_summary_screen.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({Key? key}) : super(key: key);

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  double _numberOfQuestions = 10;
  double _timePerQuestion = 15;

  void _startQuiz() async {
    // Navigate to the LOADING screen and wait for a result from the QUIZ screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizLoadingScreen(
          numberOfQuestions: _numberOfQuestions.toInt(),
          timePerQuestion: _timePerQuestion.toInt(),
        ),
      ),
    );

    // This part remains the same. It will run after the quiz is finished.
    if (result != null && result is Map<String, int>) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizSummaryScreen(
            correctAnswers: result['correct'] ?? 0,
            wrongAnswers: result['wrong'] ?? 0,
            totalQuestions: _numberOfQuestions.toInt(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Page')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Quiz Settings',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            Text(
              'Number of Questions: ${_numberOfQuestions.toInt()}',
              style: const TextStyle(fontSize: 18),
            ),
            Slider(
              value: _numberOfQuestions,
              min: 5,
              max: 20,
              divisions: 3, // (20-5)/5 = 3
              label: _numberOfQuestions.toInt().toString(),
              onChanged: (double value) {
                setState(() {
                  _numberOfQuestions = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Slider for Time per Question
            Text(
              'Time per Question: ${_timePerQuestion.toInt()} seconds',
              style: const TextStyle(fontSize: 18),
            ),
            Slider(
              value: _timePerQuestion,
              min: 10,
              max: 30,
              divisions: 4, // (30-10)/5 = 4
              label: '${_timePerQuestion.toInt()} s',
              onChanged: (double value) {
                setState(() {
                  _timePerQuestion = value;
                });
              },
            ),
            const Spacer(),

            // Start Quiz Button
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Quiz'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                textStyle: const TextStyle(fontSize: 24),
              ),
              onPressed: _startQuiz,
            ),
          ],
        ),
      ),
    );
  }
}
