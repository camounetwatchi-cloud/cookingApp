import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
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
      ),
      home: const FrigoPage(),
    );
  }
}

class FrigoPage extends StatefulWidget {
  const FrigoPage({super.key});

  @override
  State<FrigoPage> createState() => _FrigoPageState();
}

class _FrigoPageState extends State<FrigoPage> {
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;
  List<String> _items = [];

  // Backend URL: change to your deployed backend for production
  static const String backendUrl = 'http://localhost:8080/api/fridge';

  Future<void> _pickAndUpload() async {
    try {
      setState(() {
        _loading = true;
        _items = [];
      });

      final XFile? picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked == null) {
        setState(() => _loading = false);
        return;
      }

      // Read bytes (works for web and mobile)
      final bytes = await picked.readAsBytes();

      // Build multipart request
      final uri = Uri.parse(backendUrl);
      final request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        // For web, use bytes as field
        request.files.add(http.MultipartFile.fromBytes('photo', bytes, filename: 'fridge.jpg'));
      } else {
        // For mobile/desktop, we can use path if available
        if (picked.path.isNotEmpty && File(picked.path).existsSync()) {
          request.files.add(await http.MultipartFile.fromPath('photo', picked.path));
        } else {
          request.files.add(http.MultipartFile.fromBytes('photo', bytes, filename: 'fridge.jpg'));
        }
      }

      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);
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
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: ${resp.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cahier de cuisine'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              const Text(
                "Hello Francky, on mange quoi aujourd'hui ?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _pickAndUpload,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.teal,
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                        : const Text(
                            'Frigo',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _items.isEmpty
                    ? Center(
                        child: Text(
                          'Bienvenue dans votre frigo',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) => ListTile(
                          leading: const Icon(Icons.fastfood),
                          title: Text(_items[index]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
