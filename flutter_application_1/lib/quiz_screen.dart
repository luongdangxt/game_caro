import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  QuizScreenState createState() =>
      QuizScreenState(); // Đổi từ _QuizScreenState thành QuizScreenState
}

class QuizScreenState extends State<QuizScreen> {
  // Đổi từ _QuizScreenState thành QuizScreenState
  final String question = "What is the capital of France?";
  final List<String> answers = ["Paris", "Berlin", "Madrid", "Rome"];
  final int correctAnswerIndex = 0;

  String feedback = "";

  void checkAnswer(int selectedIndex) {
    setState(() {
      if (selectedIndex == correctAnswerIndex) {
        feedback = "Correct! 🎉";
      } else {
        feedback = "Wrong! 😢";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Quiz Game',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Row(
            children: [
              IconButton(
                icon:
                    const Icon(Icons.local_fire_department, color: Colors.grey),
                onPressed: () {},
              ),
              const Text(
                '0',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.black),
                    onPressed: () {},
                  ),
                  const Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              question,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Column(
              children: answers.asMap().entries.map((entry) {
                int index = entry.key;
                String answer = entry.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () => checkAnswer(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                      answer,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            Text(
              feedback,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: feedback.contains("Correct") ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        fixedColor: const Color.fromARGB(255, 32, 164, 36),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.calendarCheck),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.gamepad),
            label: 'Trò chơi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_mark),
            label: 'câu đố',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.clipboardList),
            label: 'Bài kiểm tra',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}
