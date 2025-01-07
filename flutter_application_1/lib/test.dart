import 'package:flutter/material.dart';

class OverlayLoadingExample extends StatefulWidget {
  const OverlayLoadingExample({super.key});

  @override
  _OverlayLoadingExampleState createState() => _OverlayLoadingExampleState();
}

class _OverlayLoadingExampleState extends State<OverlayLoadingExample> {
  bool _isLoading = false;

  void _showLoading() async {
    setState(() {
      _isLoading = true;
    });

    // Giả lập tác vụ mất thời gian
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overlay Loading Example'),
      ),
      body: Stack(
        children: [
          // Nội dung chính
          Center(
            child: ElevatedButton(
              onPressed: _showLoading,
              child: const Text('Hiển thị Loading'),
            ),
          ),

          // Lớp phủ
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.8), // Lớp phủ trắng mờ
                child: const Center(
                  child: CircularProgressIndicator(), // Vòng tròn tải
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: OverlayLoadingExample(),
  ));
}
