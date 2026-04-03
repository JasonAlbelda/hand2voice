// Example of how to integrate the new authentication features into your app
// This file shows the changes needed in your main.dart or app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import the new auth provider
import 'package:hand2voice/core/providers/auth_provider.dart';

// Import the unified lock screen
import 'package:hand2voice/features/auth/screens/unified_lock_screen.dart';

// Import your existing providers
import 'package:hand2voice/core/providers/biometric_provider.dart';
// ... other imports

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // NEW: Add AuthProvider (replaces BiometricProvider for lock screen)
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initialize(),
        ),
        
        // Keep BiometricProvider if you use it elsewhere
        // Or you can migrate everything to AuthProvider
        ChangeNotifierProvider(
          create: (_) => BiometricProvider()..initialize(),
        ),
        
        // ... your other providers
      ],
      child: MaterialApp(
        title: 'Hand2Voice',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        // CHANGE: Wrap your home screen with UnifiedLockScreen
        // instead of BiometricLockScreen
        home: UnifiedLockScreen(
          child: YourHomeScreen(), // Your main home screen
        ),
      ),
    );
  }
}

// Example: Your home screen
class YourHomeScreen extends StatelessWidget {
  const YourHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hand2Voice'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Hand2Voice'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to settings
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              child: const Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

// Example: Settings screen with auth settings
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // NEW: Add the auth settings tile
          const AuthSettingsTile(),
          
          // ... your other settings tiles
          
          // Example: Manual lock button
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Lock App Now'),
              subtitle: const Text('Manually lock the app'),
              onTap: () {
                // Lock the app immediately
                final authProvider = context.read<AuthProvider>();
                authProvider.logout();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Example: How to reset activity timer on user interaction
class InteractiveScreen extends StatelessWidget {
  const InteractiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Reset auto-lock timer on any tap
      onTap: () {
        final authProvider = context.read<AuthProvider>();
        authProvider.resetActivity();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Interactive Screen'),
        ),
        body: const Center(
          child: Text('Tap anywhere to reset auto-lock timer'),
        ),
      ),
    );
  }
}

// Example: Check auth status before sensitive operations
class SensitiveOperationScreen extends StatelessWidget {
  const SensitiveOperationScreen({super.key});

  Future<void> _performSensitiveOperation(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    
    // Check if user is authenticated
    if (!authProvider.isAuthenticated) {
      // Require authentication
      final success = await authProvider.authenticate(
        reason: 'Authenticate to perform this operation',
      );
      
      if (!success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication required'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }
    
    // Perform the sensitive operation
    // ...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensitive Operation'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _performSensitiveOperation(context),
          child: const Text('Perform Sensitive Operation'),
        ),
      ),
    );
  }
}
