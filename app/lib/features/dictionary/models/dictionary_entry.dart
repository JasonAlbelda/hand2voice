class DictionaryEntry {
  final int id;
  final String label;
  final String description; // The meaning
  final String signAction; // How to perform the sign physically
  final String videoUrl;

  DictionaryEntry({
    required this.id,
    required this.label,
    required this.description,
    required this.signAction,
    required this.videoUrl,
  });
}
