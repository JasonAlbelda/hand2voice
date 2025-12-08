import 'package:flutter/material.dart';

class MainPanel extends StatelessWidget {
  const MainPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Learn',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildClickableCard(
          onTap: () {
            print('Learn Card');
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Study',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildClickableCard(
          onTap: () {
            print('Study Card');
          },
        ),
      ],
    );
  }

  Widget _buildClickableCard({required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 150,
          width: double.infinity,
          child: const Stack(
            children: [
              Positioned(
                bottom: 16,
                right: 16,
                child: Icon(Icons.double_arrow, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
