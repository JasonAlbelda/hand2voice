import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import '../models/dictionary_entry.dart';
import '../services/dictionary_service.dart';
import './dictionary_detail_screen.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({Key? key}) : super(key: key);

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final DictionaryService _dictionaryService = DictionaryService();
  late List<DictionaryEntry> _allEntries;
  List<DictionaryEntry> _filteredEntries = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allEntries = _dictionaryService.getAllEntries();
    _filteredEntries = _allEntries;
    _preCacheVideos();

    _searchController.addListener(() {
      _filterEntries();
    });
  }

  void _preCacheVideos() {
    for (var entry in _allEntries) {
      CachedVideoPlayerPlus.networkUrl(Uri.parse(entry.videoUrl));
    }
  }

  void _filterEntries() {
    final query = _searchController.text;
    setState(() {
      _filteredEntries = _dictionaryService.searchEntries(query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dictionary')),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a word...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),
            // List of Dictionary Entries
            Expanded(
              child: ListView.builder(
                itemCount: _filteredEntries.length,
                itemBuilder: (context, index) {
                  final entry = _filteredEntries[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text(entry.label),
                      onTap: () {
                        // Navigate to the detail screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DictionaryDetailScreen(entry: entry),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
