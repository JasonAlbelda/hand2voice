import 'package:flutter/material.dart';
import 'package:hand2voice/core/theme/app_theme.dart';
import 'package:hand2voice/features/dictionary/screens/dictionary_screen.dart';
import 'package:hand2voice/features/scan/screens/result_screen.dart';
import 'package:hand2voice/features/scan/widgets/speech_screen.dart';
import 'package:hand2voice/features/settings/providers/settings_provider.dart';
import 'package:hand2voice/features/settings/screens/settings_screen.dart';
import 'package:hand2voice/features/study/screens/study_screen.dart';
import 'package:intl/intl.dart';
import 'package:hand2voice/features/home/widgets/selection_dialog.dart';
import 'package:hand2voice/features/scan/screens/camera_screen.dart';
import 'package:hand2voice/features/scan/screens/processing_screen.dart';
import 'package:hand2voice/features/history/history_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _useOnlineProcessing = true;
  List<TranslationRecord> _history = [];
  int _selectedIndex = 0;

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
    final isOnline = Provider.of<SettingsProvider>(
      context,
      listen: false,
    ).isOnlineMode;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          onVideoRecorded: (path) {
            Navigator.pop(context); // Close Camera
            _goToProcessing(path, isOnline);
          },
        ),
      ),
    );
  }

  Future<void> _goToProcessing(String path, bool isOnline) async {
    // Navigate to Processing Screen
    // It will handle everything and return when done (or pushed replacement)
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProcessingScreen(videoPath: path, isOnlineMode: isOnline),
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
      backgroundColor: AppTheme.appBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Hand2Voice",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMain,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Action Cards
                    _buildActionCard(
                      title: "Translate Sign",
                      subtitle: "Real-time FSL detection",
                      icon: Icons.upload_rounded,
                      color: AppTheme.accentPurple,
                      onTap: _showTranslateOptions,
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      title: "Study Mode",
                      subtitle: "Practice and take quizzes",
                      icon: Icons.book_outlined,
                      color: AppTheme.accentTeal,
                      onTap: _showStudyOptions,
                    ),

                    const SizedBox(height: 30),

                    // History Header
                    const Text(
                      "RECENT HISTORY",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSub,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // History List
                    Expanded(
                      child: _history.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 28,
                                    color: AppTheme.textSub.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "No recent translations.",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSub,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: _history.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) =>
                                  _buildHistoryItem(_history[index]),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home, 0),
                  _buildNavItem(Icons.access_time, 1),
                  _buildNavItem(Icons.settings, 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---
  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 0,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: 2),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentPurple.withOpacity(0.15)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? AppTheme.accentPurple : AppTheme.textSub,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildHistoryItem(TranslationRecord item) {
    int actionCount = 0;
    if (item.rawEvents is List) {
      actionCount = (item.rawEvents as List).length;
    } else if (item.rawEvents is Map && item.rawEvents['events'] != null) {
      actionCount = (item.rawEvents['events'] as List).length;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.videocam_rounded,
            color: AppTheme.accentTeal,
            size: 20,
          ),
        ),
        title: Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textMain,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "$actionCount Actions • ${DateFormat('MMM d, h:mm a').format(item.timestamp)}",
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSub,
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.borderColor,
          size: 20,
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
      ),
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
