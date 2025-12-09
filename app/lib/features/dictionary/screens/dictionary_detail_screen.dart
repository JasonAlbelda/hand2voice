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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Text(
              entry.label,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Description
            Text(
              entry.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: VideoPlayerWidget(videoUrl: entry.videoUrl),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
