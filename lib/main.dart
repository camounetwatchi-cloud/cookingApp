import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'models/food_preferences.dart';
import 'screens/onboarding/onboarding_flow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cahier de cuisine',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        // Make page background white across the app
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AuthWrapper(),
    );
  }
}

// Widget that checks authentication state and shows appropriate screen
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? _hasCompletedOnboarding; // null = loading, true/false = loaded
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _checkOnboardingStatus(User user) async {
    // Only check if user changed or we haven't loaded yet
    if (_currentUserId == user.uid && _hasCompletedOnboarding != null) {
      return;
    }
    
    _currentUserId = user.uid;
    
    // Check SharedPreferences for this user
    final prefs = await SharedPreferences.getInstance();
    final key = 'onboarding_completed_${user.uid}';
    final completed = prefs.getBool(key) ?? false;
    
    if (mounted) {
      setState(() {
        _hasCompletedOnboarding = completed;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    if (_currentUserId == null) return;
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final key = 'onboarding_completed_$_currentUserId';
    await prefs.setBool(key, true);
    
    if (mounted) {
      setState(() {
        _hasCompletedOnboarding = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // User is logged in
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          
          // Check onboarding status (async)
          _checkOnboardingStatus(user);
          
          // Still loading onboarding status
          if (_hasCompletedOnboarding == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // Show onboarding if not completed
          if (!_hasCompletedOnboarding!) {
            return OnboardingFlow(
              onComplete: _completeOnboarding,
              userId: user.uid,
            );
          }
          
          return FrigoPage(user: user);
        }
        
        // User is not logged in - reset state
        _currentUserId = null;
        _hasCompletedOnboarding = null;
        return const LoginPage();
      },
    );
  }
}

// ==================== LOGIN PAGE ====================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _showEmailForm = false; // true = show email form, false = show 3 main buttons
  bool _isLoginMode = true; // true = login, false = register
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Google Sign-In
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      if (kIsWeb) {
        // Web: use popup when possible, but fallback to redirect when popup is blocked
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        try {
          await FirebaseAuth.instance.signInWithPopup(googleProvider);
        } on FirebaseAuthException catch (e) {
          // Popup blocked or not supported — attempt redirect flow as fallback
          debugPrint('signInWithPopup failed (${e.code}) - trying redirect: ${e.message}');
          if (e.code == 'popup-blocked' || e.code == 'operation-not-supported-in-this-environment' || e.code == 'auth/operation-not-supported-in-this-environment') {
            try {
              await FirebaseAuth.instance.signInWithRedirect(googleProvider);
              // After redirect the app will restart; nothing else to do here.
              return;
            } catch (redirectErr) {
              debugPrint('signInWithRedirect also failed: $redirectErr');
              rethrow;
            }
          }
          rethrow; // other firebase errors -> handled by outer catch
        }
      } else {
        // Mobile: Use GoogleSignIn package
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        
        if (googleUser == null) {
          // User cancelled
          setState(() {
            _isGoogleLoading = false;
          });
          return;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e, st) {
      debugPrint('FirebaseAuthException in _signInWithGoogle: ${e.code} ${e.message}');
      debugPrint('$st');
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } catch (e, st) {
      // Unexpected error — log and show readable message
      debugPrint('Unexpected error in _signInWithGoogle: $e');
      debugPrint('$st');
      setState(() {
        _errorMessage = 'Erreur Google Sign-In: $e';
      });
    } finally {
      setState(() {
        _isGoogleLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLoginMode) {
        // Login
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        // Register
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      // AuthWrapper will automatically redirect to FrigoPage
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur est survenue: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email';
      case 'weak-password':
        return 'Le mot de passe doit contenir au moins 6 caractères';
      case 'invalid-email':
        return 'Adresse email invalide';
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect';
      default:
        return 'Erreur: $code';
    }
  }

  // Apple Sign-In (stub for now - would need AppleSignIn package)
  Future<void> _signInWithApple() async {
    setState(() {
      _isAppleLoading = true;
      _errorMessage = null;
    });

    try {
      // Apple Sign-In not fully implemented on web
      // This is a placeholder for future implementation
      setState(() {
        _errorMessage = 'Apple Sign-In coming soon';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur Apple Sign-In: $e';
      });
    } finally {
      setState(() {
        _isAppleLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _showEmailForm ? _buildEmailForm() : _buildMainButtons(),
            ),
          ),
        ),
      ),
    );
  }

  /// Main login screen with 3 buttons: Google, Apple, Email
  Widget _buildMainButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        
        // Greeting
        const Text(
          'Bonjour,',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Connecte-toi pour sauvegarder tes préférences et tes recettes.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),

        // Error message
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red[700], fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Button 1: Google
        SizedBox(
          height: 56,
          child: OutlinedButton(
            onPressed: _isGoogleLoading ? null : _signInWithGoogle,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
            ),
            child: _isGoogleLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://www.google.com/favicon.ico',
                        height: 20,
                        width: 20,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.g_mobiledata, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Continuer avec Google',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),

        // Button 2: Apple
        SizedBox(
          height: 56,
          child: OutlinedButton(
            onPressed: _isAppleLoading ? null : _signInWithApple,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
            ),
            child: _isAppleLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.apple, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Continuer avec Apple',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),

        // Button 3: Email
        SizedBox(
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _showEmailForm = true;
                _errorMessage = null;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail_outline, size: 20),
                SizedBox(width: 12),
                Text(
                  'Continuer avec Email',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Email login/register form
  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          
          // Back button + Title
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showEmailForm = false;
                    _errorMessage = null;
                    _emailController.clear();
                    _passwordController.clear();
                    _isLoginMode = true;
                  });
                },
                child: const Icon(Icons.arrow_back, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _isLoginMode ? 'Se connecter' : 'Créer un compte',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Error message
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red[700], fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              if (!value.contains('@')) {
                return 'Veuillez entrer un email valide';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: const Icon(Icons.lock_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre mot de passe';
              }
              if (!_isLoginMode && value.length < 6) {
                return 'Le mot de passe doit contenir au moins 6 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A9FFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      _isLoginMode ? 'Se connecter' : 'Créer un compte',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Toggle login/register
          TextButton(
            onPressed: () {
              setState(() {
                _isLoginMode = !_isLoginMode;
                _errorMessage = null;
              });
            },
            child: Text(
              _isLoginMode
                  ? 'Pas encore de compte ? Créer un compte'
                  : 'Déjà un compte ? Se connecter',
              style: const TextStyle(color: Color(0xFF4A9FFF), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== FRIGO PAGE ====================
class FrigoPage extends StatefulWidget {
  final User user;
  
  const FrigoPage({super.key, required this.user});

  @override
  State<FrigoPage> createState() => _FrigoPageState();
}

class _FrigoPageState extends State<FrigoPage> {
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;
  List<String> _items = [];
  final TextEditingController _manualItemController = TextEditingController();
  final Set<String> _allItems = {}; // All items: detected + manually added

  // Backend URL: change to your deployed backend for production
  static const String backendUrl = 'http://localhost:8080/api/fridge';

  Future<void> _pickAndUpload() async {
    try {
      setState(() {
        _loading = true;
        _items = [];
      });

      // On web, use gallery. On mobile, offer choice or use camera.
      final ImageSource source = kIsWeb ? ImageSource.gallery : ImageSource.gallery;
      final XFile? picked = await _picker.pickImage(source: source);
      if (picked == null) {
        setState(() => _loading = false);
        return;
      }

      // Read bytes (works for web and mobile)
      final bytes = await picked.readAsBytes();
      print('Image size: ${bytes.length} bytes');

      // Build multipart request
      final uri = Uri.parse(backendUrl);
      final request = http.MultipartRequest('POST', uri);

      // Add file with proper content type
      request.files.add(http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename: 'fridge.jpg',
      ));

      print('Sending request to $backendUrl...');
      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);
      print('Response status: ${resp.statusCode}');
      print('Response body: ${resp.body}');
      
      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body);
        final List<String> items = [];
        if (json is Map && json['items'] is List) {
          for (final it in json['items']) {
            if (it is String) {
              items.add(it);
            } else if (it is Map && it['name'] != null) items.add(it['name'].toString());
          }
        }
        setState(() {
          _items = items;
          _allItems.addAll(items);
        });
        if (items.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucun aliment détecté dans l\'image')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur ${resp.statusCode}: ${resp.body}')),
        );
      }
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  String get _userName {
    final email = widget.user.email ?? '';
    if (email.isEmpty) return 'Chef';
    return email.split('@').first;
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cahier de cuisine'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) async {
              if (value == 'logout') {
                _signOut();
              } else if (value == 'preferences') {
                // Load existing preferences and launch onboarding flow
                final existingPrefs = await FoodPreferences.loadForUser(widget.user.uid);
                
                if (mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OnboardingFlow(
                        userId: widget.user.uid,
                        existingPreferences: existingPrefs,
                        onComplete: () {
                          // pop onboarding and return to FrigoPage
                          if (mounted) Navigator.of(context).pop();
                        },
                      ),
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  widget.user.email ?? 'Utilisateur',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'preferences',
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_menu, color: Colors.teal),
                    const SizedBox(width: 8),
                    const Text('Mes préférences alimentaires'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Déconnexion', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                "On cuisine quoi aujourd'hui ?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1E90FF)),
              ),
              const SizedBox(height: 18),

              // Scan card
              Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _loading ? null : _pickAndUpload,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 360, minHeight: 110),
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: Colors.white.withOpacity(0.6)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: _loading
                                  ? const CircularProgressIndicator(strokeWidth: 2)
                                  : Icon(Icons.qr_code_scanner, size: 34, color: Colors.black54),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _loading ? 'Analyse...' : 'Scanner mon frigo',
                            style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Detected items section
              if (_allItems.isNotEmpty) ...[
                const Text(
                  'Aliments dans mon frigo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allItems.map((item) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() => _allItems.remove(item));
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue[400]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.close, size: 16, color: Colors.blue[700]),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              // Manual add section
              const Text(
                'Ajouter manuellement',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(height: 12),

              // Quick category buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Viande', 'Poissons', 'Légumes', 'Fruits', 'Œufs', 'Produits laitiers', 'Pain', 'Pâtes']
                    .map((category) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() => _allItems.add(category));
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Manual input field
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _manualItemController,
                        decoration: InputDecoration(
                          hintText: 'Ajouter un aliment...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          isDense: true,
                        ),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            setState(() {
                              _allItems.add(value.trim());
                              _manualItemController.clear();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[400],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (_manualItemController.text.trim().isNotEmpty) {
                            setState(() {
                              _allItems.add(_manualItemController.text.trim());
                              _manualItemController.clear();
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
