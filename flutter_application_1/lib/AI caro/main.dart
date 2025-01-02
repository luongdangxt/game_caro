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
      home: const DifficultySelectionScreen(),
    );
  }
}

String currentPlayer = 'X';

class DifficultySelectionScreen extends StatelessWidget {
  const DifficultySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Độ Khó'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Hãy chọn độ khó:',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GameScreen(difficulty: 'easy'),
                  ),
                );
              },
              child: const Text('Dễ'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const GameScreen(difficulty: 'medium'),
                  ),
                );
              },
              child: const Text('Trung Bình'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GameScreen(difficulty: 'hard'),
                  ),
                );
              },
              child: const Text('Khó'),
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
        aiPlayer = AI_hard(board, gridSize, "X"); // Cần truyền đúng tham số
        break;
    }
  }

  bool playerTurn = true; // Cờ để xác định lượt của người chơi

  void handleCellTap(int row, int col) {
    if (playerTurn && board[row][col] == "") {
      setState(() {
        // Người chơi đi trước
        board[row][col] = 'X';
        print("Player moved at: [$row, $col]");
        print("Board state after player move: $board");

        if (checkWin(board, gridSize, row, col, 'X')) {
          showEndDialog('Bạn thắng!');
          return;
        }

        // Đổi lượt để AI đánh
        playerTurn = false;
      });

      // Tạo một độ trễ ngắn trước khi AI đi

      aiPlayer.aiMove();
      print("Board state after AI move: $board");

      if (checkWinAfterAIMove()) return;

      // Sau khi AI đánh xong, đổi lượt lại cho người chơi
      setState(() {
        playerTurn = true;
      });
    } else {
      print("Ô này đã được đánh hoặc không phải lượt của bạn.");
    }
  }

// Hàm kiểm tra thắng sau khi AI đánh
  bool checkWinAfterAIMove() {
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (board[r][c] == 'O' && checkWin(board, gridSize, r, c, 'O')) {
          showEndDialog('AI thắng!');
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Độ Khó: ${widget.difficulty.toUpperCase()}'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Bàn cờ 7x7',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
              ),
              itemCount: gridSize * gridSize,
              itemBuilder: (context, index) {
                int row = index ~/ gridSize;
                int col = index % gridSize;
                return GestureDetector(
                  onTap: () => handleCellTap(row, col),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    color: Colors.blue[100],
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
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  bool checkWin(
      List<List<String>> board, int gridSize, int row, int col, String player) {
    // Kiểm tra theo hàng ngang
    int count = 0;
    for (int c = 0; c < gridSize; c++) {
      count = (board[row][c] == player) ? count + 1 : 0;
      if (count >= 5) return true;
    }

    // Kiểm tra theo cột dọc
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
                Navigator.of(context).pop(); // Đóng dialog
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
}
