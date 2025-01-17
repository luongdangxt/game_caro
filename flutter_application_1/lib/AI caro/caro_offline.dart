import 'package:flutter/material.dart';
import 'AI_hard.dart';
import 'package:flutter_application_1/setup_sence.dart';

void main() {
  runApp(const CaroGame());
}

class CaroGame extends StatelessWidget {
  const CaroGame({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameBoard(),
      ),
    );
  }
}

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  _GameBoardState createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  static const int boardSize = 15;
  static const String player = 'X';
  static const String ai = 'O';
  List<List<int>> winningCells = [];
  List<List<int>> revealedCells = [];

  List<List<String>> board = List.generate(
    boardSize,
    (_) => List.generate(boardSize, (_) => ''),
  );

  bool isPlayerTurn = true;
  bool gameEnded = false;
  String winner = '';

  late AI_hard aiHard;

  @override
  void initState() {
    super.initState();
    aiHard = AI_hard(board, boardSize, ai);
  }

  void handleTap(int row, int col) {
    if (gameEnded || board[row][col].isNotEmpty) return;

    setState(() {
      board[row][col] = player;
      isPlayerTurn = false;
      if (checkWinner(row, col, player)) {
        gameEnded = true;
        winner = 'Player';

        // Hiệu ứng hiện từng ô
        for (int i = 0; i < winningCells.length; i++) {
          Future.delayed(Duration(milliseconds: i * 300), () {
            setState(() {
              revealedCells.add(winningCells[i]);
            });
          });
        }
      } else if (isBoardFull()) {
        gameEnded = true;
        winner = 'Draw';
      } else {
        performAIMove();
      }
    });
  }

  bool isBoardFull() {
    for (var row in board) {
      for (var cell in row) {
        if (cell.isEmpty) return false;
      }
    }
    return true;
  }

  void performAIMove() {
    aiHard.aiMove(); // Logic AI di chuyển từ file AI_hard.dart
    setState(() {
      if (checkAIWin()) {
        gameEnded = true;
        winner = 'AI';
        // Hiệu ứng hiện từng ô
        for (int i = 0; i < winningCells.length; i++) {
          Future.delayed(Duration(milliseconds: i * 300), () {
            setState(() {
              revealedCells.add(winningCells[i]);
            });
          });
        }
      } else if (isBoardFull()) {
        gameEnded = true;
        winner = 'Draw';
      }
      isPlayerTurn = true;
    });
  }

  bool checkWinner(int row, int col, String symbol) {
    bool result = checkDirection(row, col, symbol, 0, 1) || // Horizontal
        checkDirection(row, col, symbol, 1, 0) || // Vertical
        checkDirection(row, col, symbol, 1, 1) || // Diagonal \
        checkDirection(row, col, symbol, 1, -1); // Diagonal /

    if (result) {
      // Xác định và lưu các ô chiến thắng
      winningCells = getWinningCells(row, col, symbol);
    }
    return result;
  }

  List<List<int>> getWinningCells(int row, int col, String symbol) {
    List<List<int>> cells = [];
    List<List<int>> directions = [
      [0, 1], // Horizontal
      [1, 0], // Vertical
      [1, 1], // Diagonal \
      [1, -1] // Diagonal /
    ];

    for (var direction in directions) {
      int dx = direction[0];
      int dy = direction[1];
      List<List<int>> tempCells = [
        [row, col]
      ];

      // Kiểm tra theo hướng dương
      for (int i = 1; i < 5; i++) {
        int newRow = row + dx * i;
        int newCol = col + dy * i;
        if (newRow >= 0 &&
            newRow < boardSize &&
            newCol >= 0 &&
            newCol < boardSize &&
            board[newRow][newCol] == symbol) {
          tempCells.add([newRow, newCol]);
        } else {
          break;
        }
      }

      // Kiểm tra theo hướng âm
      for (int i = 1; i < 5; i++) {
        int newRow = row - dx * i;
        int newCol = col - dy * i;
        if (newRow >= 0 &&
            newRow < boardSize &&
            newCol >= 0 &&
            newCol < boardSize &&
            board[newRow][newCol] == symbol) {
          tempCells.add([newRow, newCol]);
        } else {
          break;
        }
      }

      // Nếu đủ 5 ô liên tiếp, thêm vào danh sách kết quả
      if (tempCells.length >= 5) {
        cells.addAll(tempCells);
        break; // Ngừng kiểm tra sau khi tìm thấy một đường thắng
      }
    }
    return cells;
  }

  bool checkDirection(int row, int col, String symbol, int dx, int dy) {
    int count = 1;

    // Count in positive direction
    for (int i = 1; i < 5; i++) {
      int newRow = row + dx * i;
      int newCol = col + dy * i;
      if (newRow >= 0 &&
          newRow < boardSize &&
          newCol >= 0 &&
          newCol < boardSize &&
          board[newRow][newCol] == symbol) {
        count++;
      } else {
        break;
      }
    }

    // Count in negative direction
    for (int i = 1; i < 5; i++) {
      int newRow = row - dx * i;
      int newCol = col - dy * i;
      if (newRow >= 0 &&
          newRow < boardSize &&
          newCol >= 0 &&
          newCol < boardSize &&
          board[newRow][newCol] == symbol) {
        count++;
      } else {
        break;
      }
    }

    return count >= 5;
  }

  bool checkAIWin() {
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (board[row][col] == ai && checkWinner(row, col, ai)) {
          return true;
        }
      }
    }
    return false;
  }

  void resetGame() {
    setState(() {
      board = List.generate(
        boardSize,
        (_) => List.generate(boardSize, (_) => ''),
      );
      isPlayerTurn = true;
      gameEnded = false;
      winner = '';
      winningCells = [];
      revealedCells = [];

      aiHard = AI_hard(board, boardSize, ai);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/back_game.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          height: 405,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 144, 97, 80),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 35),
                  // hiển thị thời gian mỗi lượt
                ),
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              height: 100,
              width: 250,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/khung.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: gameEnded
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          winner == 'Draw' ? 'It\'s a Draw!' : '$winner Wins!',
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      "GOMOKU",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              children: [
                Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Lấy kích thước nhỏ nhất giữa chiều rộng và chiều cao
                      double size = constraints.maxWidth < constraints.maxHeight
                          ? constraints.maxWidth
                          : constraints.maxHeight;

                      double cellSize =
                          size / 15; // Kích thước mỗi ô trong lưới

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10.0), // Lùi 16px mỗi bên
                        width: size, // Đảm bảo container là hình vuông
                        height: size - 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(0), // Không bo góc
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26, // Màu đổ bóng
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Lớp vẽ lưới
                            CustomPaint(
                              size: Size(size, size - 20),
                              painter: GridPainter(
                                boardSize: 15,
                                cellSize: cellSize,
                              ),
                            ),
                            // Lớp hiển thị và tương tác với các ô
                            GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 15,
                                crossAxisSpacing: 1,
                                mainAxisSpacing: 1,
                                childAspectRatio: 1,
                              ),
                              itemCount: 15 * 15,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                int row = index ~/ 15;
                                int col = index % 15;
                                bool isRevealedWinningCell = revealedCells.any(
                                    (cell) => cell[0] == row && cell[1] == col);

                                return GestureDetector(
                                  onTap: () {
                                    if (isPlayerTurn) {
                                      handleTap(row, col);
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.all(1.0),
                                    color: isRevealedWinningCell
                                        ? Colors
                                            .green // Màu nền các ô chiến thắng sau khi hiện
                                        : Colors.transparent,
                                    alignment: Alignment.center,
                                    child: Text(
                                      board[row][col],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isRevealedWinningCell
                                            ? Colors
                                                .yellow // Màu ký hiệu sau khi hiện
                                            : (board[row][col] == player
                                                ? Colors.blue
                                                : Colors.red),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly, // Căn đều trong màn hình
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Circle background
                        Container(
                          width: 80, // Adjust the size to your needs
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Colors.white, // Outer circle color
                            shape: BoxShape.circle,
                          ),
                        ),

                        // Inner circle
                        Container(
                          width: 70, // Slightly smaller than outer circle
                          height: 70,
                          decoration: const BoxDecoration(
                            color: Colors.brown, // Inner circle color
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow, // Play icon
                            color: Colors.white,
                            size: 44, // Icon size
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 90,
                              width: 90,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    0, 255, 255, 255),
                                            content: Container(
                                              width: 400,
                                              height: 280,
                                              decoration: const BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/images/khung.png'),
                                                  fit: BoxFit.fitHeight,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const HomeScreen(),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      height: 90,
                                                      width: 145,
                                                      decoration:
                                                          const BoxDecoration(
                                                        image: DecorationImage(
                                                          image: AssetImage(
                                                              'assets/images/btn.png'),
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        "Continue",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 30,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const HomeScreen(),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      height: 90,
                                                      width: 145,
                                                      decoration:
                                                          const BoxDecoration(
                                                        image: DecorationImage(
                                                          image: AssetImage(
                                                              'assets/images/btn.png'),
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        "Exit",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: const Text(
                                      "",
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Circle background
                        Container(
                          width: 80, // Adjust the size to your needs
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Colors.white, // Outer circle color
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Inner circle
                        Container(
                          width: 70, // Slightly smaller than outer circle
                          height: 70,
                          decoration: const BoxDecoration(
                            color: Colors.brown, // Inner circle color
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.refresh, // Play icon
                            color: Colors.white,
                            size: 44, // Icon size
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 90,
                              width: 90,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CaroGame(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "",
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Circle background
                        Container(
                          width: 80, // Adjust the size to your needs
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Colors.white, // Outer circle color
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Inner circle
                        Container(
                          width: 70, // Slightly smaller than outer circle
                          height: 70,
                          decoration: const BoxDecoration(
                            color: Colors.brown, // Inner circle color
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.reply, // Play icon
                            color: Colors.white,
                            size: 44, // Icon size
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 90,
                              width: 90,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    0, 255, 255, 255),
                                            content: Container(
                                              width: 400,
                                              height: 280,
                                              decoration: const BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/images/khung.png'),
                                                  fit: BoxFit.fitHeight,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      height: 90,
                                                      width: 145,
                                                      decoration:
                                                          const BoxDecoration(
                                                        image: DecorationImage(
                                                          image: AssetImage(
                                                              'assets/images/btn.png'),
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        "NO",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 30,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const HomeScreen(),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      height: 90,
                                                      width: 145,
                                                      decoration:
                                                          const BoxDecoration(
                                                        image: DecorationImage(
                                                          image: AssetImage(
                                                              'assets/images/btn.png'),
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        "YES",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: const Text(
                                      "",
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 120,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  final int boardSize;
  final double cellSize;

  GridPainter({required this.boardSize, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color.fromARGB(255, 96, 96, 96)
      ..strokeWidth = 2 // Độ rộng của đường kẻ
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // Bo tròn đầu các đường kẻ

    // Tính toán chiều cao và chiều rộng của mỗi ô (dựa trên kích thước khung chứa)
    double cellHeight = size.height / boardSize; // Tính chiều cao của mỗi ô
    double cellWidth = size.width / boardSize; // Tính chiều rộng của mỗi ô

    // Vẽ các đường ngang (dựa trên chiều cao của khung)
    for (int i = 1; i < boardSize; i++) {
      double y = i * cellHeight; // Vị trí vẽ đường ngang
      // Dịch chuyển xuống một chút để đường kẻ không chồng lên các ô
      canvas.drawLine(
          Offset(0, y), Offset(size.width, y), paint); // Vẽ đường ngang
    }

    // Vẽ các đường dọc (dựa trên chiều rộng của khung)
    for (int i = 1; i < boardSize; i++) {
      double x = i * cellWidth; // Vị trí vẽ đường dọc
      // Dịch chuyển sang phải một chút để đường kẻ không chồng lên các ô
      canvas.drawLine(
          Offset(x, 0), Offset(x, size.height), paint); // Vẽ đường dọc
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
