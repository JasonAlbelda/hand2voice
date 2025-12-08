import 'package:flutter/material.dart';

class GreetPanel extends StatelessWidget {
  const GreetPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Welcome 👋',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Juan', style: TextStyle(fontSize: 24, color: Colors.black87)),
        ],
      ),
    );
  }
}
