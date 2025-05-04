import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const CropCounterApp());
}

class CropCounterApp extends StatelessWidget {
  const CropCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Counter',
      home: CropCounterScreen(),
    );
  }
}

class CropCounterScreen extends StatefulWidget {
  @override
  _CropCounterScreenState createState() => _CropCounterScreenState();
}

class _CropCounterScreenState extends State<CropCounterScreen> {
  File? _imageFile;
  int? _cropCount;
  bool _loading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _cropCount = null;
      });
      await _sendImage(File(picked.path));
    }
  }

  Future<void> _sendImage(File image) async {
    setState(() => _loading = true);

    var uri = Uri.parse('http://192.168.1.5:8000/count-crops/');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    try {
      var response = await request.send();
      var responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        var json = jsonDecode(responseBody.body);
        setState(() => _cropCount = json['crop_count']);
      } else {
        throw Exception('Failed to get crop count');
      }
    } catch (e) {
      print('Error: $e');
      setState(() => _cropCount = null);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crop Counter')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_imageFile != null) Image.file(_imageFile!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const CircularProgressIndicator()
            else if (_cropCount != null)
              Text('🌱 Crops Detected: $_cropCount',
                  style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
