import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';
import 'models/food_preferences.dart';
import 'screens/home/scan_and_recipes.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'ui/design_system.dart';

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
      theme: AppTheme.light(),
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  StreamSubscription<User?>? _authSubscription;
  User? _currentUser;
  FoodPreferences? _cachedPreferences;
  bool? _hasCompletedOnboarding;

  bool _showEmailForm = false;
  bool _isLoginMode = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  String? _errorMessage;
  String? _firstName;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen(_handleAuthStateChange);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthStateChange(User? user) async {
    if (!mounted) return;

    setState(() {
      _currentUser = user;
      if (user == null) {
        _hasCompletedOnboarding = false;
        _cachedPreferences = null;
      } else {
        _hasCompletedOnboarding = null;
      }
    });

    if (user == null) return;

    final prefs = await FoodPreferences.loadForUser(user.uid);
    if (!mounted) return;

    setState(() {
      _cachedPreferences = prefs;
      _hasCompletedOnboarding = prefs != null;
    });
  }

  void _handleOnboardingCompleted() {
    final user = _currentUser;
    if (user == null) return;

    setState(() {
      _hasCompletedOnboarding = true;
    });

    FoodPreferences.loadForUser(user.uid).then((prefs) {
      if (!mounted) return;
      setState(() {
        _cachedPreferences = prefs;
      });
    });
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider()..addScope('email');
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          return;
        }
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e, st) {
      debugPrint(
          'FirebaseAuthException in _signInWithGoogle: ${e.code} ${e.message}');
      debugPrint('$st');
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } catch (e, st) {
      debugPrint('Unexpected error in _signInWithGoogle: $e');
      debugPrint('$st');
      setState(() {
        _errorMessage = 'Erreur Google Sign-In: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
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
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur est survenue: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  bool get _hasFirstName =>
      _firstName != null && _firstName!.trim().isNotEmpty;

  String _formatFirstName(String input) {
    final segments = input.trim().split(RegExp(r'\s+'));
    return segments
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ')
        .trim();
  }

  Future<void> _promptForFirstName() async {
    final controller = TextEditingController(text: _firstName ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Ton prénom',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Paul, Marie…',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        _firstName = _formatFirstName(result);
      });
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isAppleLoading = true;
      _errorMessage = null;
    });

    try {
      setState(() {
        _errorMessage = 'Apple Sign-In coming soon';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur Apple Sign-In: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAppleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

    if (user == null) {
      return _buildAuthScreen();
    }

    if (_hasCompletedOnboarding == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasCompletedOnboarding!) {
      return FrigoPage(user: user);
    }

    return OnboardingFlow(
      userId: user.uid,
      existingPreferences: _cachedPreferences,
      onComplete: _handleOnboardingCompleted,
    );
  }

  Widget _buildAuthScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: !_hasFirstName
                  ? _buildWelcomeIntro()
                  : (_showEmailForm ? _buildEmailForm() : _buildMainButtons()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeIntro() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        const Text(
          'Bienvenue,',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Comment dois-je t’appeler ?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        LiquidGlassButton(
          onPressed: _promptForFirstName,
          height: 54,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.edit_outlined, size: 18, color: Colors.black87),
              SizedBox(width: 10),
              Text(
                'Ajouter prénom',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tu pourras le modifier plus tard.',
          style: TextStyle(color: Colors.black54, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMainButtons() {
    final greeting = _hasFirstName ? 'Bonjour ${_firstName!}' : 'Bonjour,';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Text(
          greeting,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        if (_hasFirstName)
          TextButton(
            onPressed: _promptForFirstName,
            child: const Text(
              'Modifier mon prénom',
              style: TextStyle(fontSize: 13),
            ),
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
        LiquidGlassButton(
          onPressed: _isGoogleLoading ? null : _signInWithGoogle,
          isLoading: _isGoogleLoading,
          height: 56,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Image.asset(
                    'assets/logo/google_icon.png',
                    height: 20,
                    width: 20,
                  ),
                ),
              ),
              Center(
                child: const Text(
                  'Continuer avec Google',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LiquidGlassButton(
          onPressed: _isAppleLoading ? null : _signInWithApple,
          isLoading: _isAppleLoading,
          height: 56,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg',
                    height: 20,
                    width: 20,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.apple, size: 20),
                  ),
                ),
              ),
              Center(
                child: const Text(
                  'Continuer avec Apple',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LiquidGlassButton(
          onPressed: () {
            setState(() {
              _showEmailForm = true;
              _errorMessage = null;
            });
          },
          height: 56,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Image.network(
                    'https://upload.wikimedia.org/wikipedia/fr/a/a7/Mail_%28Apple%29_logo.png',
                    height: 20,
                    width: 20,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(
                          Icons.mail_outline,
                          size: 20,
                          color: Colors.black87,
                        ),
                  ),
                ),
              ),
              Center(
                child: const Text(
                  'Continuer avec Email',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
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
          LiquidGlassButton(
            onPressed: _isLoading ? null : _submit,
            isLoading: _isLoading,
            height: 50,
            width: double.infinity,
            child: Text(
              _isLoginMode ? 'Se connecter' : 'Créer un compte',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
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

enum _MenuAction { preferences, logout }

class _FrigoPageState extends State<FrigoPage> {
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;
  List<String> _items = [];
  final TextEditingController _manualItemController = TextEditingController();
  final Set<String> _allItems = {}; // All items: detected + manually added
  final LayerLink _menuLayerLink = LayerLink();
  OverlayEntry? _menuOverlayEntry;

  // Backend URL: change to your deployed backend for production
  static const String backendUrl = 'http://localhost:8080/api/fridge';

  Future<void> _pickAndUpload() async {
    try {
      setState(() {
        _loading = true;
        _items = [];
      });

      // Show scan progress overlay
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const ScanInProgressPage(),
        );
      }

      // On web, use gallery. On mobile, offer choice or use camera.
      final ImageSource source = kIsWeb ? ImageSource.gallery : ImageSource.gallery;
      final XFile? picked = await _picker.pickImage(source: source);
      if (picked == null) {
        setState(() => _loading = false);
        if (mounted) Navigator.of(context).pop(); // close dialog
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
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // close dialog
      }
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
  void dispose() {
    _manualItemController.dispose();
    _hideMenu();
    super.dispose();
  }

  void _toggleMenu() {
    if (_menuOverlayEntry != null) {
      _hideMenu();
    } else {
      _showMenu();
    }
  }

  void _showMenu() {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _menuOverlayEntry = OverlayEntry(
      builder: (_) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _hideMenu,
                  child: const SizedBox.expand(),
                ),
              ),
              CompositedTransformFollower(
                link: _menuLayerLink,
                offset: const Offset(-190, 48),
                showWhenUnlinked: false,
                child: Material(
                  color: Colors.transparent,
                  child: SizedBox(
                    width: 230,
                    child: _buildGlassMenu(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlay.insert(_menuOverlayEntry!);
  }

  void _hideMenu() {
    _menuOverlayEntry?.remove();
    _menuOverlayEntry = null;
  }

  Future<void> _handleMenuAction(_MenuAction action) async {
    _hideMenu();

    if (action == _MenuAction.logout) {
      await _signOut();
      return;
    }

    final existingPrefs = await FoodPreferences.loadForUser(widget.user.uid);
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OnboardingFlow(
          userId: widget.user.uid,
          existingPreferences: existingPrefs,
          onComplete: () {
            if (mounted) Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Widget _buildGlassMenu() {
    final theme = Theme.of(context);
    final email = widget.user.email ?? 'Utilisateur';

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      borderRadius: 32,
      backgroundOpacity: 0.5,
      strokeOpacity: 0.22,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFDEE5),
                      Color(0xFFFFF5F7),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFF4D4D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.4),
          ),
          const SizedBox(height: 10),
          _MenuEntry(
            icon: Icons.restaurant_menu_outlined,
            label: 'Mes préférences alimentaires',
            onTap: () => _handleMenuAction(_MenuAction.preferences),
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          _MenuEntry(
            icon: Icons.logout,
            label: 'Déconnexion',
            iconColor: Colors.redAccent,
            textColor: Colors.redAccent,
            onTap: () => _handleMenuAction(_MenuAction.logout),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cahier de cuisine'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CompositedTransformTarget(
              link: _menuLayerLink,
              child: GestureDetector(
                onTap: _toggleMenu,
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  borderRadius: 18,
                  backgroundOpacity: 0.35,
                  strokeOpacity: 0.25,
                  child: const Icon(
                    Icons.menu_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Salut $_userName 👋",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Prêt à scanner ton frigo et cuisiner ?",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 18),

              // Scan card
              GlassContainer(
                padding: const EdgeInsets.all(18),
                borderRadius: 22,
                backgroundOpacity: 0.38,
                strokeOpacity: 0.22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GlassContainer(
                          padding: const EdgeInsets.all(14),
                          borderRadius: 16,
                          backgroundOpacity: 0.32,
                          strokeOpacity: 0.22,
                          child: Icon(
                            _loading ? Icons.hourglass_top : Icons.qr_code_scanner,
                            color: AppColors.primaryBlue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _loading ? 'Analyse en cours…' : 'Scanner mon frigo',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: _loading ? null : _pickAndUpload,
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: Text(
                        _loading ? 'Analyse…' : 'Lancer un scan',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (_allItems.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Aliments détectés',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RecipeSuggestionsPage(
                              items: _allItems.toList(),
                            ),
                          ),
                        );
                      },
                      child: const Text('Voir les recettes'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allItems.map((item) => _chip(
                    label: item,
                    onRemove: () => setState(() => _allItems.remove(item)),
                    selected: true,
                  )).toList(),
                ),
                const SizedBox(height: 20),
              ],

              Text(
                'Ajouter manuellement',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ['Viande', 'Poissons', 'Légumes', 'Fruits', 'Œufs', 'Produits laitiers', 'Pain', 'Pâtes']
                    .map((category) => _chip(
                          label: category,
                          onTap: () => setState(() => _allItems.add(category)),
                          selected: _allItems.contains(category),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 14),
              GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                borderRadius: 16,
                child: Row(
                  children: [
                    const Icon(Icons.add, color: AppColors.primaryBlue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _manualItemController,
                        decoration: const InputDecoration(
                          hintText: 'Ajouter un aliment…',
                          border: InputBorder.none,
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
                    IconButton(
                      icon: const Icon(Icons.send, color: AppColors.primaryBlue),
                      onPressed: () {
                        if (_manualItemController.text.trim().isNotEmpty) {
                          setState(() {
                            _allItems.add(_manualItemController.text.trim());
                            _manualItemController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_allItems.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RecipeSuggestionsPage(
                          items: _allItems.toList(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Proposer des recettes',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              const SizedBox(height: 8),
              if (_allItems.isEmpty)
                Text(
                  'Ajoute des aliments ou scanne ton frigo\npour générer des idées.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    VoidCallback? onTap,
    VoidCallback? onRemove,
    bool selected = false,
  }) {
    final blur = selected ? 26.0 : 16.0;
    final borderColor =
        selected ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.3);
    final gradient = selected
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F7CF6),
              Color(0xFF0088FF),
            ],
          )
        : const RadialGradient(
            center: Alignment(-0.6, -1),
            radius: 2.6,
            colors: [
              Color(0xFFF8FAFF),
              Color(0xFFF2F4F8),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 0.55, 1.0],
          );
    final textColor = selected ? Colors.white : AppColors.textPrimary;
    final boxShadow = selected
        ? [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.32),
              blurRadius: 18,
              spreadRadius: -8,
              offset: const Offset(0, 10),
            ),
          ]
        : AppShadows.liquidGlass;

    return GestureDetector(
      onTap: onTap ?? onRemove,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: boxShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  if (onRemove != null) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white.withOpacity(0.9),
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
}

class _MenuEntry extends StatelessWidget {
  const _MenuEntry({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = AppColors.textPrimary,
    this.textColor = AppColors.textPrimary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      splashColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
