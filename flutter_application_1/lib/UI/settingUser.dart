import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditUserScreen extends StatefulWidget {
  final Uint8List initialAvatarUrl;

  const EditUserScreen({super.key, required this.initialAvatarUrl});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  File? _avatar;
  late Uint8List _avatarUrl;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _avatarUrl = widget.initialAvatarUrl;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatar = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields!')),
      );
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://your-api-endpoint.com/update-user'),
    );

    if (_avatar != null) {
      request.files.add(
        await http.MultipartFile.fromPath('avatar', _avatar!.path),
      );
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update user.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: MemoryImage(_avatarUrl),
                child: _avatar == null && _avatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Change Avatar'),
              ),
            ),
            const SizedBox(height: 16),
            boxInfo('Username', 'nnduong'),
            const SizedBox(height: 16),
            boxInfo('Email', '-------'),
            const SizedBox(height: 16),
            boxInfo('Register on date', '09/01/2025'),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding boxInfo(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$key:',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
