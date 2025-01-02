import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const CaroGameApp());
}

class CaroGameApp extends StatelessWidget {
  const CaroGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const CaroGame(),
    );
  }
}

class CaroGame extends StatefulWidget {
  const CaroGame({super.key});

  @override
  _CaroGameState createState() => _CaroGameState();
}

class _CaroGameState extends State<CaroGame> {
  static const int boardSize = 7;

  int currentPlayer = 1; // Người chơi hiện tại
  int timeLeft = 30; // Thời gian đếm ngược
  double timeProgress = 1.0; // Tỷ lệ thời gian (1.0 là đầy)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Thanh hiển thị thông tin người chơi
          Container(
            height: 105,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildPlayerAvatar(1), // Avatar người chơi 1
                buildTimer(), // Thời gian đếm ngược ở giữa
                buildPlayerAvatar(2), // Avatar người chơi 2
              ],
            ),
          ),
          Expanded(
            // Bàn cờ
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: CustomPaint(
                    painter: CaroBoardPainter(boardSize: boardSize),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Vòng tròn avatar người chơi
  Widget buildPlayerAvatar(int player) {
    bool isCurrentPlayer = currentPlayer == player;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: isCurrentPlayer ? timeProgress : 0, // Tiến độ thời gian
                color: isCurrentPlayer
                    ? const Color.fromARGB(255, 0, 214, 147)
                    : Colors.grey,
                strokeWidth: 4,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(
                player == 1
                    ? 'assets/images/avatar_1.jpg'
                    : 'assets/images/avatar_2.jpg',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Player $player',
          style: TextStyle(
            fontSize: 16,
            fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
            color: isCurrentPlayer
                ? const Color.fromARGB(255, 0, 214, 147)
                : Colors.black54,
          ),
        ),
      ],
    );
  }

  /// Hiển thị thời gian ở giữa
  Widget buildTimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$timeLeft',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Text(
          ' s',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ],
    );
  }
}

class CaroBoardPainter extends CustomPainter {
  final int boardSize;

  CaroBoardPainter({required this.boardSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cellSize = size.width / boardSize;

    for (int i = 1; i < boardSize; i++) {
      final offset = i * cellSize;

      canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), paint);
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
