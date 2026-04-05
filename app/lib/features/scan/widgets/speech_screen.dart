import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hand2voice/core/theme/app_theme.dart';

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({super.key});

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _speechEnabled = false;
  String _lastWords = 'Tap Here to Type Something';
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  // Initialize the speech recognition
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  // Start listening for speech
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  // Stop listening for speech
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  // Callback for speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  // Function to speak the text
  Future<void> _speak() async {
    if (_lastWords.isNotEmpty && _lastWords != 'Tap Here to Type Something') {
      await _flutterTts.speak(_lastWords);
    } else if (_lastWords == 'Tap Here to Type Something') {
      await _flutterTts.speak('Tap the middle of the screen to type something');
    }
  }

  // Function to show a dialog for text input
  Future<void> _showTextInputDialog() async {
    _textEditingController.text = _lastWords == 'Tap Here to Type Something'
        ? ''
        : _lastWords;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppTheme.borderColor),
          ),
          title: const Text(
            'Type your message',
            style: TextStyle(color: AppTheme.textMain),
          ),
          content: TextField(
            controller: _textEditingController,
            autofocus: true,
            style: const TextStyle(color: AppTheme.textMain),
            decoration: const InputDecoration(
              hintText: "Enter text here...",
              hintStyle: TextStyle(color: AppTheme.textSub),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  _lastWords = _textEditingController.text;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

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
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppTheme.textMain,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Speech to Text',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMain,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPurple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accentPurple),
                    ),
                    child: GestureDetector(
                      onTap: _speak,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.volume_up,
                            size: 18,
                            color: AppTheme.accentPurple,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'TTS',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accentPurple,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: GestureDetector(
                onTap: _showTextInputDialog,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Center(
                    child: Text(
                      _speechToText.isListening ? 'Listening...' : _lastWords,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: _speechToText.isListening 
                            ? AppTheme.accentTeal 
                            : AppTheme.textMain,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom mic button
            Container(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: _speechToText.isListening 
                      ? Colors.red.withOpacity(0.15)
                      : AppTheme.cardBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _speechToText.isListening 
                        ? Colors.red 
                        : AppTheme.borderColor,
                    width: 2,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    _speechToText.isNotListening ? Icons.mic : Icons.mic_off,
                    color: _speechToText.isListening 
                        ? Colors.red 
                        : AppTheme.textMain,
                    size: 32,
                  ),
                  onPressed: _speechToText.isNotListening
                      ? _startListening
                      : _stopListening,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
