import 'package:flutter/material.dart';
import 'package:hand2voice/features/dictionary/widgets/video_player_widget.dart';
import '../models/dictionary_entry.dart';

class DictionaryDetailScreen extends StatelessWidget {
  final DictionaryEntry entry;

  const DictionaryDetailScreen({Key? key, required this.entry})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(entry.label)),
      // 1. Use SingleChildScrollView to prevent overflow on small screens
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: THE WORD ---
            Text(
              entry.label,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 24),

            // --- SECTION 2: THE VIDEO ---
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: VideoPlayerWidget(videoUrl: entry.videoUrl),
              ),
            ),

            const SizedBox(height: 32),

            // --- SECTION 3: THE DESCRIPTION ---
            _buildSectionHeader(context, "MEANING"),
            const SizedBox(height: 8),
            Text(
              entry.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // --- SECTION 4: THE SIGN STEP (New Action) ---
            _buildSectionHeader(context, "HOW TO SIGN"),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    Colors.blue.shade50, // Light blue background to make it pop
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Optional: An icon to indicate physical action
                  Icon(Icons.back_hand, size: 20, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.signAction, // Using the new field
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.blueGrey[900],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Extra space at bottom for scrolling
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // A small helper widget to keep the main code clean
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
        letterSpacing: 1.2,
      ),
    );
  }
}
