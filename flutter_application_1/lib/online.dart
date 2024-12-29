import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF3F6FF),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int currentPlayer = 1;
  double timeLeft = 10;
  Timer? timer;
  List<List<int>> board = List.generate(5, (_) => List.filled(5, 0));
  List<List<int>> winningCells = [];

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          switchPlayer();
        }
      });
    });
  }

  void switchPlayer() {
    setState(() {
      currentPlayer = currentPlayer == 1 ? 2 : 1;
      timeLeft = 10;
    });
  }

  void onCellTap(int row, int col) {
    if (board[row][col] != 0) return;

    setState(() {
      board[row][col] = currentPlayer;
      if (!checkWin(currentPlayer)) {
        switchPlayer();
      } else {
        timer?.cancel();
      }
    });
  }

  bool checkWin(int player) {
    winningCells.clear();
    int size = board.length;
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (col <= size - 4 &&
            List.generate(4, (j) => board[row][col + j] == player)
                .every((e) => e)) {
          winningCells = List.generate(4, (j) => [row, col + j]);
          return true;
        }
        if (row <= size - 4 &&
            List.generate(4, (j) => board[row + j][col] == player)
                .every((e) => e)) {
          winningCells = List.generate(4, (j) => [row + j, col]);
          return true;
        }
        if (row <= size - 4 &&
            col <= size - 4 &&
            List.generate(4, (j) => board[row + j][col + j] == player)
                .every((e) => e)) {
          winningCells = List.generate(4, (j) => [row + j, col + j]);
          return true;
        }
        if (row <= size - 4 &&
            col >= 3 &&
            List.generate(4, (j) => board[row + j][col - j] == player)
                .every((e) => e)) {
          winningCells = List.generate(4, (j) => [row + j, col - j]);
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/back.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: const Icon(Icons.volume_up),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: const Icon(Icons.settings),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: board.length,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: board.length * board.length,
                    itemBuilder: (context, index) {
                      int row = index ~/ board.length;
                      int col = index % board.length;
                      return GestureDetector(
                        onTap: () => onCellTap(row, col),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: winningCells.any(
                                    (cell) => cell[0] == row && cell[1] == col)
                                ? Colors.yellow.withOpacity(0.8)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              board[row][col] == 1
                                  ? 'X'
                                  : board[row][col] == 2
                                      ? 'O'
                                      : '',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: board[row][col] == 1
                                    ? Colors.red
                                    : board[row][col] == 2
                                        ? Colors.blue
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
