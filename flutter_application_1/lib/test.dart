import 'package:flutter/material.dart';
import 'package:flutter_application_1/UI/AudioService.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MusicPlayerScreen(),
    );
  }
}

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phát nhạc nền với just_audio'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await AudioManager().load('assets/audio/str1.mp3');
            await AudioManager().play();
          },
          child: const Text('Phát nhạc'),
        ),
      ),
    );
  }
}
