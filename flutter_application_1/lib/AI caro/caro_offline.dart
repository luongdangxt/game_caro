import 'package:flutter/material.dart';
import 'AI_easy.dart';
import 'AI_medium.dart';
import 'AI_hard.dart';

void main() {
  runApp(const CaroGame());
}

class CaroGame extends StatelessWidget {
  const CaroGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Tic-Tac-Toe',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SettingsScreen(
        title: "Play Offline",
        subtitle: "Chọn độ khó để bắt đầu",
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final String title;
  final String subtitle;

  const SettingsScreen({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: const BoxDecoration(
              color: Color(0xFFCCE5FF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                buildDifficultyCard(
                  context,
                  title: "Dễ",
                  description: "Dành cho người mới bắt đầu",
                  color: const Color(0xFFE8F8E8),
                  icon: Icons.emoji_emotions,
                  difficulty: 'easy',
                ),
                buildDifficultyCard(
                  context,
                  title: "Trung Bình",
                  description: "Cấp độ thử thách nhẹ nhàng",
                  color: const Color(0xFFFFF2CC),
                  icon: Icons.insights,
                  difficulty: 'medium',
                ),
                buildDifficultyCard(
                  context,
                  title: "Khó",
                  description: "Độ khó nâng cao",
                  color: const Color(0xFFCCE5FF),
                  icon: Icons.trending_up,
                  difficulty: 'hard',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDifficultyCard(
    BuildContext context, {
    required String title,
    required String description,
    required Color color,
    required IconData icon,
    required String difficulty,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(difficulty: difficulty),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(40),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final String difficulty;

  const GameScreen({super.key, required this.difficulty});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<List<String>> board;
  late int gridSize;
  late dynamic aiPlayer;
  bool playerTurn = true;

  @override
  void initState() {
    super.initState();
    gridSize = 15;
    board = List.generate(gridSize, (_) => List.filled(gridSize, ""));
    switch (widget.difficulty) {
      case 'easy':
        aiPlayer = AI_easy(board: board, gridSize: gridSize);
        break;
      case 'medium':
        aiPlayer = AI_medium(board, gridSize, 'X');
        break;
      case 'hard':
        aiPlayer = AI_hard(board, gridSize, 'X');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Caro - ${widget.difficulty.toUpperCase()}'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        itemCount: gridSize * gridSize,
        itemBuilder: (context, index) {
          final row = index ~/ gridSize;
          final col = index % gridSize;
          return GestureDetector(
            onTap: () => handleCellTap(row, col),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: board[row][col] == 'X'
                    ? Colors.blue
                    : board[row][col] == 'O'
                        ? Colors.red
                        : Colors.white,
              ),
              child: Center(
                child: Text(
                  board[row][col],
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void handleCellTap(int row, int col) {
    if (playerTurn && board[row][col] == "") {
      setState(() {
        board[row][col] = 'X';
        if (checkWin(row, col, 'X')) {
          showEndDialog('Bạn thắng!');
          return;
        }
        playerTurn = false;
      });

      aiPlayer.aiMove();
      if (checkWinAfterAIMove()) return;

      setState(() {
        playerTurn = true;
      });
    }
  }

  bool checkWin(int row, int col, String player) {
    int count = 0;

    // Kiểm tra hàng ngang
    for (int c = 0; c < gridSize; c++) {
      count = (board[row][c] == player) ? count + 1 : 0;
      if (count >= 5) return true;
    }

    // Kiểm tra cột dọc
    count = 0;
    for (int r = 0; r < gridSize; r++) {
      count = (board[r][col] == player) ? count + 1 : 0;
      if (count >= 5) return true;
    }

    // Kiểm tra đường chéo chính
    count = 0;
    for (int d = -gridSize; d < gridSize; d++) {
      int r = row + d, c = col + d;
      if (r >= 0 && r < gridSize && c >= 0 && c < gridSize) {
        count = (board[r][c] == player) ? count + 1 : 0;
        if (count >= 5) return true;
      }
    }

    // Kiểm tra đường chéo phụ
    count = 0;
    for (int d = -gridSize; d < gridSize; d++) {
      int r = row + d, c = col - d;
      if (r >= 0 && r < gridSize && c >= 0 && c < gridSize) {
        count = (board[r][c] == player) ? count + 1 : 0;
        if (count >= 5) return true;
      }
    }

    return false;
  }

  void showEndDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kết thúc trò chơi'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  board =
                      List.generate(gridSize, (_) => List.filled(gridSize, ""));
                });
              },
              child: const Text('Chơi lại'),
            ),
          ],
        );
      },
    );
  }

  bool checkWinAfterAIMove() {
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (board[r][c] == 'O' && checkWin(r, c, 'O')) {
          showEndDialog('AI thắng!');
          return true;
        }
      }
    }
    return false;
  }
}
