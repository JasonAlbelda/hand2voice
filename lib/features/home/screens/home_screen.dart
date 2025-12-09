import 'package:flutter/material.dart';
import 'package:hand2voice/features/dictionary/screens/dictionary_screen.dart';
import 'package:hand2voice/features/scan/screens/result_screen.dart';
import 'package:hand2voice/features/scan/widgets/speech_screen.dart';
import 'package:hand2voice/features/settings/screens/settings_screen.dart';
import 'package:hand2voice/features/study/screens/study_screen.dart';
import 'package:intl/intl.dart';
// Import your widgets
import 'package:hand2voice/features/home/widgets/selection_dialog.dart';
import 'package:hand2voice/features/scan/screens/camera_screen.dart';
import 'package:hand2voice/features/scan/screens/processing_screen.dart'; // Import the new screen
import 'package:hand2voice/features/history/history_service.dart';
// Note: scan_screen.dart is no longer needed if using the dialog approach

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _useOnlineProcessing = true;
  List<TranslationRecord> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await HistoryService.getHistory();
    setState(() => _history = data);
  }

  // --- LOGIC: START TRANSLATION FLOW ---
  void _showTranslateOptions() {
    showDialog(
      context: context,
      builder: (context) => SelectionDialog(
        title: "Select Input Method",
        options: [
          SelectionOption(
            label: "Deaf to Non-Deaf",
            description:
                "Convert Actions to Text to Communicate with Deaf People.",
            icon: Icons.camera_alt_rounded,
            color: Colors.orange,
            onTap: _startCameraFlow,
          ),
          SelectionOption(
            label: "Non-Deaf to Deaf",
            description:
                "Convert Speech to Text to Communicate with Deaf People.",
            icon: Icons.mic,
            color: Colors.deepPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SpeechToTextScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _startCameraFlow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          onVideoRecorded: (path) {
            Navigator.pop(context); // Close Camera
            _goToProcessing(path);
          },
        ),
      ),
    );
  }

  Future<void> _goToProcessing(String path) async {
    // Navigate to Processing Screen
    // It will handle everything and return when done (or pushed replacement)
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessingScreen(
          videoPath: path,
          isOnlineMode: _useOnlineProcessing,
        ),
      ),
    );
    // Reload history when user comes back from ResultScreen
    _loadHistory();
  }

  void _showStudyOptions() {
    showDialog(
      context: context,
      builder: (context) => SelectionDialog(
        title: "Study Method",
        options: [
          SelectionOption(
            label: "Dictionary",
            description: "See Available Sign Description.",
            icon: Icons.camera_alt_rounded,
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DictionaryScreen()),
              );
            },
          ),
          SelectionOption(
            label: "Quiz",
            description: "Guess the Right Sign Language based on the Video.",
            icon: Icons.video_library_rounded,
            color: Colors.deepPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StudyScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Hand2Voice",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Action Cards
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      title: "Translate",
                      icon: Icons.cached,
                      color: Colors.orange,
                      onTap: _showTranslateOptions,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildActionCard(
                      title: "Study",
                      icon: Icons.book_outlined,
                      color: Colors.blue,
                      onTap: _showStudyOptions,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // History Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Translated",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadHistory,
                  ),
                ],
              ),

              // History List
              Expanded(
                child: _history.isEmpty
                    ? const Center(
                        child: Text(
                          "No history yet",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _history.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) =>
                            _buildHistoryItem(_history[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---
  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(icon, size: 50, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(TranslationRecord item) {
    // Helper to get count safely
    int actionCount = 0;
    if (item.rawEvents is List) {
      actionCount = (item.rawEvents as List).length; // Old format
    } else if (item.rawEvents is Map && item.rawEvents['events'] != null) {
      actionCount = (item.rawEvents['events'] as List).length; // New format
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.videocam_rounded, color: Colors.grey),
      ),
      title: Text(
        item.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$actionCount Actions Detected",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            DateFormat('MMM d, h:mm a').format(item.timestamp),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              videoPath: item.videoPath,
              extractedData: item.rawEvents,
            ),
          ),
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Settings"),
          content: StatefulBuilder(
            builder: (context, setStateInternal) {
              return SwitchListTile(
                title: const Text("Use Online Server"),
                subtitle: const Text("Process on Laptop"),
                value: _useOnlineProcessing,
                onChanged: (val) {
                  setStateInternal(() => _useOnlineProcessing = val);
                  setState(() => _useOnlineProcessing = val);
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
