import 'package:flutter/material.dart';
import 'package:hand2voice/features/dictionary/models/dictionary_entry.dart';
import 'package:hand2voice/features/dictionary/services/dictionary_service.dart';
import 'package:hand2voice/features/study/models/quiz_question.dart';
import 'package:hand2voice/features/study/widgets/quiz_view.dart';
import 'package:video_player/video_player.dart';

class QuizLoadingScreen extends StatefulWidget {
  final int numberOfQuestions;
  final int timePerQuestion;

  const QuizLoadingScreen({
    Key? key,
    required this.numberOfQuestions,
    required this.timePerQuestion,
  }) : super(key: key);

  @override
  State<QuizLoadingScreen> createState() => _QuizLoadingScreenState();
}

class _QuizLoadingScreenState extends State<QuizLoadingScreen> {
  @override
  void initState() {
    super.initState();
    _prepareQuiz();
  }

  Future<void> _prepareQuiz() async {
    final dictionaryService = DictionaryService();
    // In a real app, you would load this if using the JSON method
    // await dictionaryService.loadEntries();
    final allEntries = dictionaryService.getAllEntries();
    allEntries.shuffle();

    final selectedEntries = allEntries.take(widget.numberOfQuestions).toList();
    final List<QuizQuestion> preparedQuestions = [];

    for (var entry in selectedEntries) {
      try {
        // Initialize the video controller
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(entry.videoUrl),
        );
        await controller.initialize();

        // Generate choices for this question
        List<DictionaryEntry> otherEntries = List.from(allEntries)
          ..removeWhere((e) => e.id == entry.id);
        otherEntries.shuffle();

        final choices = [
          entry.label,
          otherEntries[0].label,
          otherEntries[1].label,
          otherEntries[2].label,
        ];
        choices.shuffle();

        // Add the prepared question to our list
        preparedQuestions.add(
          QuizQuestion(
            entry: entry,
            videoController: controller,
            choices: choices,
          ),
        );
      } catch (e) {
        print("Error loading video for ${entry.label}: $e");
        // You could decide to skip this question or handle the error
      }
    }

    // When loading is done, replace this screen with the QuizView
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizView(
            numberOfQuestions: preparedQuestions,
            timePerQuestion: widget.timePerQuestion,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Preparing your quiz...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
