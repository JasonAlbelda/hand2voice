import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hand2voice/core/providers/auth_provider.dart';
import 'package:hand2voice/features/auth/widgets/pin_input_widget.dart';
import 'package:hand2voice/features/auth/widgets/pattern_input_widget.dart';

class UnifiedLockScreen extends StatefulWidget {
  final Widget child;

  const UnifiedLockScreen({
    super.key,
    required this.child,
  });

  @override
  State<UnifiedLockScreen> createState() => _UnifiedLockScreenState();
}

class _UnifiedLockScreenState extends State<UnifiedLockScreen>
    with WidgetsBindingObserver {
  bool _showPinInput = false;
  bool _showPatternInput = false;
  String _errorMessage = '';
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authenticate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final authProvider = context.read<AuthProvider>();
    
    // Record when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pausedTime = DateTime.now();
    }
    // Check if we should lock when app comes back to foreground
    else if (state == AppLifecycleState.resumed) {
      if (authProvider.isAnyAuthEnabled) {
        // Only lock if app was in background for more than 2 seconds
        // This prevents locking during quick transitions like file picker
        if (_pausedTime != null) {
          final duration = DateTime.now().difference(_pausedTime!);
          if (duration.inSeconds > 2) {
            authProvider.logout();
          }
        }
        
        if (!authProvider.isAuthenticated) {
          _authenticate();
        }
      }
      _pausedTime = null;
    }
  }

  Future<void> _authenticate() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.authenticate();
  }

  void _onPinCompleted(String pin) async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyPin(pin);
    
    if (success) {
      setState(() {
        _errorMessage = '';
        _showPinInput = false;
      });
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN';
      });
    }
  }

  void _onPatternCompleted(List<int> pattern) async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyPattern(pattern);
    
    if (success) {
      setState(() {
        _errorMessage = '';
        _showPatternInput = false;
      });
    } else {
      setState(() {
        _errorMessage = 'Incorrect Pattern';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show lock screen if any auth is enabled and user is not authenticated
        if (authProvider.isAnyAuthEnabled && !authProvider.isAuthenticated) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade700,
                  ],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_showPinInput && !_showPatternInput) ...[
                          Icon(
                            Icons.lock_outline,
                            size: 100,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Hand2Voice',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'App is locked',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 48),
                          if (authProvider.isLoading)
                            CircularProgressIndicator(
                              color: Colors.white,
                            )
                          else ...[
                            // Biometric button
                            if (authProvider.isBiometricEnabled &&
                                authProvider.isBiometricAvailable)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: ElevatedButton.icon(
                                  onPressed: _authenticate,
                                  icon: Icon(Icons.fingerprint),
                                  label: Text(
                                    'Unlock with ${authProvider.getBiometricDescription()}',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                            // PIN button
                            if (authProvider.isPinEnabled)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _showPinInput = true;
                                      _errorMessage = '';
                                    });
                                  },
                                  icon: Icon(Icons.dialpad),
                                  label: Text('Unlock with PIN'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                            // Pattern button
                            if (authProvider.isPatternEnabled)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _showPatternInput = true;
                                      _errorMessage = '';
                                    });
                                  },
                                  icon: Icon(Icons.pattern),
                                  label: Text('Unlock with Pattern'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ],
                        // PIN Input
                        if (_showPinInput) ...[
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _showPinInput = false;
                                _errorMessage = '';
                              });
                            },
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Enter PIN',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (_errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red.shade200,
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),
                          PinInputWidget(
                            onCompleted: _onPinCompleted,
                            onChanged: () {
                              setState(() {
                                _errorMessage = '';
                              });
                            },
                          ),
                        ],
                        // Pattern Input
                        if (_showPatternInput) ...[
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _showPatternInput = false;
                                _errorMessage = '';
                              });
                            },
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Draw Pattern',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (_errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red.shade200,
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),
                          PatternInputWidget(
                            onCompleted: _onPatternCompleted,
                            onChanged: () {
                              setState(() {
                                _errorMessage = '';
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // Show the actual app if authenticated or auth is disabled
        return widget.child;
      },
    );
  }
}
