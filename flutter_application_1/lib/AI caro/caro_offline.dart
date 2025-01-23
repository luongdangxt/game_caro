import 'package:flutter/material.dart';
import 'AI_hard.dart';
import 'package:flutter_application_1/setup_sence.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';

class CaroGame extends StatelessWidget {
  final String selectedIndex;
  const CaroGame({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Kích thước thiết kế của iPhone X
      minTextAdapt: true, // Tự động điều chỉnh kích thước chữ
      splitScreenMode: true, // Hỗ trợ chế độ chia đôi màn hình
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: GameBoard(
              avatar:
                  selectedIndex, // Truyền tham số selectedIndex vào GameBoard
            ),
          ),
        );
      },
    );
  }
}

class GameBoard extends StatefulWidget {
  final String avatar;

  const GameBoard({super.key, required this.avatar});

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
  //String avatar = selectedIndex;

  late AI_hard aiHard;

  @override
  void initState() {
    super.initState();
    aiHard = AI_hard(board, boardSize, ai);
  }

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose(); // Giải phóng tài nguyên
    super.dispose();
  }

  void _playerMove() async {
    // Phát file WAV từ assets
    await _audioPlayer.play(AssetSource('assets/audio/pop.wav'));
  }

  void _aiMove() async {
    // Phát file WAV từ assets
    await _audioPlayer.play(AssetSource('assets/audio/tik.wav'));
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

        // Hiển thị container thông báo chiến thắng
        Future.delayed(Duration(milliseconds: winningCells.length * 500), () {
          showVictoryDialog();
        });
      } else if (isBoardFull()) {
        gameEnded = true;
        winner = 'Draw';
        showVictoryDialog();
      } else {
        performAIMove();
      }
    });
  }

  void showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho phép đóng khi nhấn ngoài dialog
      builder: (BuildContext context) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0), // Bo góc nếu cần
            ),
            padding: const EdgeInsets.all(16.0),
            child: Material(
              color: Colors.transparent, // Loại bỏ màu nền của AlertDialog
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Container 1: Hình ảnh và nội dung
                  Container(
                    height: 550.h,
                    width: 350.w,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/khung.png'),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Image.asset(
                          winner == 'Player'
                              ? 'assets/images/win.png'
                              : 'assets/images/lose.png',
                          height: 270.h,
                          width: 270.w,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Nút Thoát
                            Container(
                              height: 80.h,
                              width: 120.w,
                              padding: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/btn.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Đóng dialog
                                  Navigator.of(context)
                                      .pop(); // Quay về màn hình chính
                                },
                                child: const Text(
                                  'EXIT',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 255, 0, 0),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                            // Nút Reset
                            Container(
                              height: 80.h,
                              width: 120.w,
                              padding: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/btn.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Đóng dialog
                                  resetGame(); // Gọi hàm reset game
                                },
                                child: Text(
                                  'Reset',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        const Color.fromARGB(255, 0, 110, 255),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 170.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
    _aiMove();
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

        Future.delayed(Duration(milliseconds: winningCells.length * 500), () {
          showVictoryDialog();
        });
      } else if (isBoardFull()) {
        gameEnded = true;
        winner = 'Draw';
        showVictoryDialog();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
        child: Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/back_game.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.065,
            ),
            Container(
              alignment: Alignment.topCenter,
              //width: MediaQuery.of(context).size.width.w,
              height: MediaQuery.of(context).size.height * 0.28,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/18.png'),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ],
        ),
        Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.048,
            ),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                ),
                Container(
                  alignment: Alignment.topCenter,
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/19.png'),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.48,
            ),
            Row(
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/20.png'),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                ),
              ],
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Circle background
                    Container(
                      width: 45.w, // Adjust the size to your needs
                      height: 40.h,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/btn_back.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    // Inner circle

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 90.h,
                          width: 90.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: const Color.fromARGB(
                                            0, 255, 255, 255),
                                        content: Container(
                                            padding: const EdgeInsets.all(15),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.4,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.28,
                                            decoration: const BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    'assets/images/khung.png'),
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Do you want to exit?",
                                                  style: TextStyle(
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color.fromARGB(
                                                        255, 255, 255, 255),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20.h,
                                                ),
                                                Row(
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
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.06,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.1,
                                                        decoration:
                                                            const BoxDecoration(
                                                          image:
                                                              DecorationImage(
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
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.02,
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
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.06,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.1,
                                                        decoration:
                                                            const BoxDecoration(
                                                          image:
                                                              DecorationImage(
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
                                                            color:
                                                                Color.fromARGB(
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
                                              ],
                                            )),
                                      );
                                    },
                                  );
                                },
                                child: SizedBox(
                                  height: 200.h,
                                  width: 63.w,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.center,
                  height: 90.h,
                  width: 200.w,
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
                              winner == 'Draw'
                                  ? 'It\'s a Draw!'
                                  : '$winner Wins!',
                              style: TextStyle(
                                fontSize: 30.h,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          "GOMOKU",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.1,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/btn_audio.png'),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.01,
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Column(
              children: [
                Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Lấy kích thước nhỏ nhất giữa chiều rộng và chiều cao
                      // double size = constraints.maxWidth < constraints.maxHeight
                      //     ? constraints.maxWidth
                      //     : constraints.maxHeight;

                      // Xác định xem đây có phải là tablet hay không
                      final isTablet = screenWidth >
                          600; // Điều kiện màn hình rộng > 600 là tablet

                      // Lấy kích thước bàn cờ
                      double size = (screenWidth < screenHeight
                              ? screenWidth
                              : screenHeight) *
                          0.9;

                      // Nếu là tablet, tăng kích thước bàn cờ lên 10% nữa
                      if (isTablet) {
                        size *= 0.85; // Tăng thêm 10% kích thước
                      }

                      double cellSize =
                          size / 15; // Kích thước mỗi ô trong lưới

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: size + 10,
                            height: size - 10,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 253, 213, 80),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10.0), // Lùi 16px mỗi bên
                            width: size, // Đảm bảo container là hình vuông
                            height: size,
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
                                  size: Size(size, size),
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
                                    crossAxisSpacing: 0,
                                    mainAxisSpacing: 0,
                                  ),
                                  itemCount: 15 * 15,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    int row = index ~/ 15;
                                    int col = index % 15;
                                    bool isRevealedWinningCell =
                                        revealedCells.any((cell) =>
                                            cell[0] == row && cell[1] == col);

                                    return GestureDetector(
                                      onTap: () {
                                        if (isPlayerTurn) {
                                          handleTap(row, col);
                                          _playerMove();
                                        }
                                      },
                                      child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          margin: const EdgeInsets.all(1.0),
                                          color: isRevealedWinningCell
                                              ? Colors
                                                  .green // Màu nền các ô chiến thắng sau khi hiện
                                              : Colors.transparent,
                                          alignment: Alignment.center,
                                          child: Center(
                                            child: Text(
                                              board[row][col],
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.bold,
                                                color: isRevealedWinningCell
                                                    ? Colors.yellow
                                                    : (board[row][col] == player
                                                        ? Colors.blue
                                                        : Colors.red),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          )),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.05, // Chiều cao là 10% chiều cao màn hình
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width *
                              0.45, // Chiều rộng chiếm 80% màn hình
                          height: MediaQuery.of(context).size.height *
                              0.15, // Chiều cao chiếm 30% màn hình
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 80.w,
                                height: 80.h,
                                decoration: BoxDecoration(
                                  shape:
                                      BoxShape.circle, // Avatar luôn hình tròn
                                  image: DecorationImage(
                                    image: AssetImage(widget.avatar),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.04,
                            ),
                            Text(
                              'X',
                              style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.03,
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width *
                              0.45, // Chiều rộng chiếm 80% màn hình
                          height: MediaQuery.of(context).size.height *
                              0.15, // Chiều cao chiếm 30% màn hình
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'O',
                              style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.04,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 80.w,
                                height: 80.h,
                                decoration: const BoxDecoration(
                                  shape:
                                      BoxShape.circle, // Avatar luôn hình tròn
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/avAI.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.05, // Chiều cao là 10% chiều cao màn hình
                ),
              ],
            ),
          ],
        ),
      ],
    ));
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
