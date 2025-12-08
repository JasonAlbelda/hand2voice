import 'package:hand2voice/features/dictionary/models/dictionary_entry.dart';
import 'package:video_player/video_player.dart';

class QuizQuestion {
  final DictionaryEntry entry;
  final VideoPlayerController videoController;
  final List<String> choices;

  QuizQuestion({
    required this.entry,
    required this.videoController,
    required this.choices,
  });
}
