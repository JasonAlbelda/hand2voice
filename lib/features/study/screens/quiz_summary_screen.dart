import 'package:flutter/material.dart';

class QuizSummaryScreen extends StatelessWidget {
  final int correctAnswers;
  final int wrongAnswers;
  final int totalQuestions;

  const QuizSummaryScreen({
    Key? key,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Summary'),
        // Hides the back button
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Quiz Complete!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Correct Answers Tile
              _buildSummaryTile(
                icon: Icons.check_circle,
                color: Colors.green,
                label: 'Correct Answers',
                value: correctAnswers,
              ),
              const SizedBox(height: 20),

              // Wrong Answers Tile
              _buildSummaryTile(
                icon: Icons.cancel,
                color: Colors.red,
                label: 'Wrong Answers',
                value: wrongAnswers,
              ),
              const SizedBox(height: 20),

              // Total Questions Tile
              _buildSummaryTile(
                icon: Icons.format_list_numbered,
                color: Colors.blue,
                label: 'Total Questions',
                value: totalQuestions,
              ),
              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  // Pop back to the main study configuration screen
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Play Again', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryTile({
    required IconData icon,
    required Color color,
    required String label,
    required int value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(width: 20),
          Text(label, style: const TextStyle(fontSize: 20)),
          const Spacer(),
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
