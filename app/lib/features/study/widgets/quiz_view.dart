import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hand2voice/features/study/models/quiz_question.dart';
import 'package:hand2voice/features/study/screens/quiz_summary_screen.dart';
import 'package:video_player/video_player.dart';
import '../../dictionary/models/dictionary_entry.dart';
import '../../dictionary/services/dictionary_service.dart';

class QuizView extends StatefulWidget {
  final List<QuizQuestion> numberOfQuestions;
  final int timePerQuestion;

  const QuizView({
    Key? key,
    required this.numberOfQuestions,
    required this.timePerQuestion,
  }) : super(key: key);

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  final DictionaryService _dictionaryService = DictionaryService();
  late List<DictionaryEntry> _allEntries;
  int _currentQuestionIndex = 0;

  late DictionaryEntry _currentQuestion;
  late List<String> _choices;
  int _questionNumber = 1;

  Timer? _timer;
  double _progressValue = 1.0;

  int _correctAnswers = 0;
  int _wrongAnswers = 0;

  Color? _buttonColor1, _buttonColor2, _buttonColor3, _buttonColor4;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _allEntries = _dictionaryService.getAllEntries();
    _allEntries.shuffle(); // Shuffle once at the beginning
    //_generateQuestion();
    _playCurrentVideo();
    _startTimer();
  }

  void _playCurrentVideo() {
    final controller =
        widget.numberOfQuestions[_currentQuestionIndex].videoController;
    controller.seekTo(Duration.zero);
    controller.setLooping(true);
    controller.play();
  }

  void _generateQuestion() {
    setState(() {
      _isAnswered = false;
      _resetButtonColors();

      // Get the next question from the shuffled list
      _currentQuestion = _allEntries[_questionNumber - 1];

      List<DictionaryEntry> otherEntries = List.from(_allEntries)
        ..removeWhere((entry) => entry.id == _currentQuestion.id);
      otherEntries.shuffle();

      _choices = [
        _currentQuestion.label,
        otherEntries[0].label,
        otherEntries[1].label,
        otherEntries[2].label,
      ];
      _choices.shuffle();

      _startTimer();
    });
  }

  void _startTimer() {
    _progressValue = 1.0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (_progressValue > 0) {
          _progressValue -= (100 / (widget.timePerQuestion * 1000));
        } else {
          timer.cancel();
          _handleAnswer(''); // Pass an empty answer for timeout
        }
      });
    });
  }

  void _handleAnswer(String selectedAnswer) {
    if (_isAnswered) return;

    _timer?.cancel();
    _isAnswered = true;
    final isCorrect =
        selectedAnswer ==
        widget.numberOfQuestions[_currentQuestionIndex].entry.label;

    setState(() {
      if (isCorrect)
        _correctAnswers++;
      else
        _wrongAnswers++;

      final choices = widget.numberOfQuestions[_currentQuestionIndex].choices;
      for (int i = 0; i < choices.length; i++) {
        if (choices[i] ==
            widget.numberOfQuestions[_currentQuestionIndex].entry.label) {
          _setButtonColor(i, Colors.green);
        } else if (choices[i] == selectedAnswer && !isCorrect) {
          _setButtonColor(i, Colors.red);
        }
      }
    });

    Future.delayed(const Duration(seconds: 2), _nextQuestion);
  }

  void _nextQuestion() {
    widget.numberOfQuestions[_currentQuestionIndex].videoController.pause();

    if (_currentQuestionIndex < widget.numberOfQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _resetButtonColors();
        _playCurrentVideo();
        _startTimer();
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizSummaryScreen(
            correctAnswers: _correctAnswers,
            wrongAnswers: _wrongAnswers,
            totalQuestions: widget.numberOfQuestions.length,
          ),
        ),
      );
    }
  }

  // ... (_resetButtonColors, _setButtonColor, dispose from before)
  void _resetButtonColors() {
    _buttonColor1 = _buttonColor2 = _buttonColor3 = _buttonColor4 = null;
  }

  void _setButtonColor(int index, Color color) {
    if (index == 0) _buttonColor1 = color;
    if (index == 1) _buttonColor2 = color;
    if (index == 2) _buttonColor3 = color;
    if (index == 3) _buttonColor4 = color;
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var question in widget.numberOfQuestions) {
      question.videoController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.numberOfQuestions[_currentQuestionIndex];
    final choices = currentQuestion.choices;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${_currentQuestionIndex + 1}/${widget.numberOfQuestions.length}',
        ),
      ),
      body: Padding(
        // ... The rest of the UI from the previous step remains the same ...
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: _progressValue,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Sign ${_currentQuestionIndex + 1}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 200,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: VideoPlayer(currentQuestion.videoController),
              ),
            ),
            const SizedBox(height: 24),
            _buildAnswerButton(0, choices[0], _buttonColor1),
            const SizedBox(height: 12),
            _buildAnswerButton(1, choices[1], _buttonColor2),
            const SizedBox(height: 12),
            _buildAnswerButton(2, choices[2], _buttonColor3),
            const SizedBox(height: 12),
            _buildAnswerButton(3, choices[3], _buttonColor4),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButton(int index, String text, Color? color) {
    return ElevatedButton(
      onPressed: () => _handleAnswer(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.grey[300],
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: Text(text),
    );
  }
}
