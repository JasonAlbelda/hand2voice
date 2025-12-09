import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
    // Set the initial text in the controller
    _textEditingController.text = _lastWords == 'Tap Here to Type Something'
        ? ''
        : _lastWords;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Type your message'),
          content: TextField(
            controller: _textEditingController,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Enter text here..."),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Speech to Text',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              avatar: const Icon(
                Icons.volume_up_outlined,
                size: 20,
                weight: 12,
              ),
              label: const Text(
                'TTS',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: _speak, // Trigger TTS
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _showTextInputDialog, // Open text input dialog
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _speechToText.isListening ? 'Listening...' : _lastWords,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 120,
        width: double.infinity,
        color: Colors.grey[300],
        child: Center(
          child: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: _speechToText.isNotListening
                  ? Colors.white
                  : Colors.red,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
            ),
            icon: Icon(
              _speechToText.isNotListening ? Icons.mic_none : Icons.mic_off,
              color: Colors.grey[800],
            ),
            iconSize: 40.0,
            onPressed: _speechToText.isNotListening
                ? _startListening
                : _stopListening,
          ),
        ),
      ),
    );
  }
}
