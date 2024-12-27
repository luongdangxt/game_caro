import 'package:flutter/material.dart';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

void main() {
  runApp(const TicTacToeApp());
}

bool isMuted = false;
double maxTime = 10;

// web socket
late WebSocketChannel channel; // Kênh WebSocket
bool isOnlineMode = true; // Kích hoạt chế độ online
//

// ID player
Map<int, String> playerIds = {
  1: "player1", // Người chơi 1
  2: "player2", // Người chơi 2
};
String gameStatus = 'playing'; // Trạng thái ban đầu là 'playing'
String? winnerId; // Biến lưu ID của người chơi thắng

//

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

// Chuyển đổi cấu trúc bàn cờ sang danh sách hai chiều
List<List<int>> board = List.generate(5, (_) => List.filled(5, 0));
List<List<int>> winningCells = []; // Danh sách lưu các ô chiến thắng
String? currentPlayerId; // Lưu ID của người chơi hiện tại

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int currentPlayer = 1; // 1 là người chơi X, 2 là người chơi O
  double timeLeft = 10; // Thời gian còn lại cho mỗi lượt chơi
  Timer? timer;

  @override
  void initState() {
    super.initState();
    if (isOnlineMode) {
      channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8080'), // Thay bằng URL của server
      );

      // Lắng nghe thông điệp từ server
      channel.stream.listen((message) {
        handleServerMessage(message);
      });
    }
    startTimer();
  }

  void handleServerMessage(String message) {
    final data = jsonDecode(message);

    if (data['type'] == 'updateBoard') {
      setState(() {
        board =
            List<List<int>>.from(data['board']); // Cập nhật bàn cờ từ server
        currentPlayerId = data['currentPlayerId']; // Cập nhật lượt chơi
      });
    } else if (data['type'] == 'gameOver') {
      showWinnerDialog(data['winnerId']); // Hiển thị người thắng
    } else if (data['type'] == 'playerJoined') {
      // Xử lý khi có người chơi tham gia phòng
      print('Player joined: ${data['playerId']}');
    }
  }

  @override
  void dispose() {
    if (isOnlineMode) {
      channel.sink.close(); // Đóng WebSocket khi thoát
    }
    timer?.cancel();
    super.dispose();
  }

  // Bắt đầu đếm ngược thời gian cho mỗi lượt chơi
  // Hàm bắt đầu đếm ngược thời gian
  void startTimer() {
    timer?.cancel(); // Hủy Timer cũ nếu có
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--; // Giảm thời gian mỗi giây
        } else {
          // Nếu hết thời gian, tự động chuyển lượt
          switchPlayer();
        }
      });
    });
  }

  // Chuyển lượt chơi khi hết thời gian
  // Hàm chuyển lượt chơi
  void switchPlayer() {
    setState(() {
      currentPlayer = currentPlayer == 1 ? 2 : 1; // Đổi lượt
      timeLeft = maxTime; // Reset thời gian
      isPlayerTurn = true; // Mở lại lượt cho người chơi
      isActionLocked = false; // Mở khóa hành động
      startTimer(); // Bắt đầu lại đếm ngược
    });
  }

// Hàm mở rộng bàn cờ
  void expandBoard() {
    setState(() {
      int currentSize = board.length; // Kích thước hiện tại

      // Sao chép board cũ
      List<List<int>> newBoard = List.generate(
        currentSize + 4,
        (_) => List.filled(currentSize + 4, 0),
      );

      // Ghi lại dữ liệu cũ vào board mới
      for (int i = 0; i < currentSize; i++) {
        for (int j = 0; j < currentSize; j++) {
          newBoard[i + 2][j + 2] = board[i][j];
        }
      }

      board = newBoard; // Cập nhật lại board
    });
  }

// Hàm kiểm tra xem bàn cờ có đầy không
  bool isBoardFull() {
    return board.every((row) => row.every((cell) => cell != 0));
  }

  // Biến kiểm soát trạng thái lượt chơi
  bool isPlayerTurn = true;

  bool isActionLocked = false; // Biến toàn cục để khóa hành động

  // Sửa đổi hàm onCellTap
  void onCellTap(int row, int col) {
    if (isActionLocked || gameStatus != 'playing' || board[row][col] != 0) {
      return; // Khóa hành động hoặc ô đã đánh
    }

    if (isOnlineMode) {
      // Kiểm tra lượt chơi online
      String currentPlayerId = playerIds[currentPlayer]!;
      if (currentPlayerId != playerIds[1]) {
        // Không phải lượt của người chơi, không làm gì cả
        return;
      }

      // Xử lý lượt của người chơi
      setState(() {
        board[row][col] = currentPlayer;
        timeLeft = 0; // Đặt lại thời gian
        isActionLocked = true; // Khóa hành động chờ phản hồi từ server
      });

      // Gửi thông điệp lên server
      channel.sink.add(jsonEncode({
        'type': 'makeMove',
        'row': row,
        'col': col,
        'playerId': currentPlayerId,
      }));
    } else {
      // Chơi offline: Người chơi đánh, sau đó AI đánh
      setState(() {
        board[row][col] = currentPlayer;
        timeLeft = 0; // Đặt lại thời gian
      });

      if (checkWin(currentPlayer)) {
        timer?.cancel();
        _startBrushEffect();
      } else if (isBoardFull()) {
        expandBoard();
      } else {
        // Đến lượt AI đánh
        switchPlayer(); // Chuyển sang AI
        Future.delayed(const Duration(milliseconds: 500), () {
          playAIMove(); // Gọi hàm xử lý nước đi của AI
        });
      }
    }
  }

// Hàm xử lý nước đi của AI
  void playAIMove() {
    if (gameStatus != 'playing') return;

    // Logic đơn giản: AI đánh ô trống đầu tiên tìm được
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[i].length; j++) {
        if (board[i][j] == 0) {
          setState(() {
            board[i][j] = currentPlayer; // AI đánh ô
          });

          if (checkWin(currentPlayer)) {
            timer?.cancel();
            _startBrushEffect();
          } else if (isBoardFull()) {
            expandBoard();
          } else {
            switchPlayer(); // Chuyển lại lượt cho người chơi
          }
          return;
        }
      }
    }
  }

  void _startBrushEffect() async {
    for (int i = 0; i < winningCells.length; i++) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          // Tô màu cho từng ô thắng
          final cell = winningCells[i];
          board[cell[0]][cell[1]] =
              3; // Tạm gán giá trị 3 để biểu thị ô đang được vẽ
        });
      });
    }

    // Sau khi hoàn tất hiệu ứng tô màu, hiển thị thông báo chiến thắng
    Future.delayed(const Duration(seconds: 1), () {
      showWinnerDialog(currentPlayer);
    });
  }

// Hàm kiểm tra chiến thắng
  // Sửa đổi hàm checkWin để hoạt động với danh sách hai chiều
  bool checkWin(int player) {
    winningCells.clear();
    int size = board.length;
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        // Kiểm tra ngang
        // Kiểm tra ngang
        if (col <= size - 4 &&
            List.generate(4, (j) => board[row][col + j] == player)
                .every((e) => e)) {
          winningCells = List.generate(4, (j) => [row, col + j]);
          setState(() {
            gameStatus = 'win'; // Cập nhật trạng thái khi có người thắng
          });
          return true;
        }

// Kiểm tra dọc
        if (row <= size - 4 &&
            List.generate(4, (j) => board[row + j][col] == player)
                .every((e) => e)) {
          winningCells = List.generate(4, (j) => [row + j, col]);
          setState(() {
            gameStatus = 'win'; // Cập nhật trạng thái khi có người thắng
          });
          return true;
        }

// Kiểm tra chéo phải
        if (row <= size - 4 &&
            col <= size - 4 &&
            List.generate(4, (j) => board[row + j][col + j] == player)
                .every((e) => e)) {
          winningCells = List.generate(4, (j) => [row + j, col + j]);
          setState(() {
            gameStatus = 'win'; // Cập nhật trạng thái khi có người thắng
          });
          return true;
        }

// Kiểm tra chéo trái
        if (row <= size - 4 &&
            col >= 3 &&
            List.generate(4, (j) => board[row + j][col - j] == player)
                .every((e) => e)) {
          winningCells = List.generate(4, (j) => [row + j, col - j]);
          setState(() {
            gameStatus = 'win'; // Cập nhật trạng thái khi có người thắng
          });
          return true;
        }
      }
    }
    return false;
  }

// Hiển thị dialog người chiến thắng
  void showWinnerDialog(int player) {
    winnerId = playerIds[player]; // Lưu ID người thắng vào biến
    sendWinnerToServer(); // Gửi dữ liệu lên server

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: AnimationController(
                duration: const Duration(milliseconds: 500),
                vsync: this,
              )..forward(),
              curve: Curves.elasticOut,
            ),
            child: AlertDialog(
              title: const Text('🎉 Chúc mừng!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Người chơi ${player == 1 ? "X" : "O"} đã thắng!'),
                  const SizedBox(height: 20),
                  const Icon(Icons.star, size: 50, color: Colors.amber),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    resetGame();
                    Navigator.pop(context);
                  },
                  child: const Text('Chơi lại'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Hiển thị dialog hòa
  void showDrawDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: const Text('Trò chơi hòa!'),
          actions: [
            TextButton(
              onPressed: () {
                resetGame();
                Navigator.pop(context);
              },
              child: const Text('Chơi lại'),
            ),
          ],
        );
      },
    );
  }

// Hàm reset bàn cờ
  void resetGame() {
    setState(() {
      board = List.generate(
        5, // Số hàng
        (_) => List.filled(5, 0), // Số cột và giá trị mặc định
      );
      currentPlayer = 1; // Người chơi bắt đầu là 1
      timeLeft = 10; // Reset thời gian
    });
    startTimer(); // Khởi động lại Timer
    winningCells.clear();
    isActionLocked = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Nền giao diện
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/back.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              // Đảm bảo hiệu ứng không cản trở người chơi
              ignoring: true,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500), // Hiệu ứng mờ dần
                opacity: winningCells.isNotEmpty
                    ? 1.0
                    : 0.0, // Hiển thị khi có ô thắng
                child: CustomPaint(
                  painter: FireworksPainter(), // Vẽ pháo hoa trên toàn màn hình
                ),
              ),
            ),
          ),

          // Giao diện trò chơi
          Column(
            mainAxisAlignment: MainAxisAlignment
                .start, // Căn đầu cho Column, tránh khoảng cách thừa
            children: [
              // Thanh điều khiển
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 10.0), // Giảm padding vertical
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isMuted =
                              !isMuted; // Chuyển trạng thái tắt/bật âm thanh
                        });
                        // Logic tắt/mở âm thanh
                        if (isMuted) {
                          // Ví dụ: Tắt âm thanh
                          // AudioService.pause();
                        } else {
                          // Ví dụ: Bật âm thanh
                          // AudioService.play();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible:
                              false, // Không cho phép tắt khi bấm ngoài
                          builder: (context) {
                            return Scaffold(
                              body: Container(
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/back.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(
                                              context); // Quay lại giao diện chính
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 87, 174, 246),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 55, vertical: 15),
                                        ),
                                        child: const Text(
                                          'Continue',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Hiển thị hướng dẫn cách chơi
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('How to play'),
                                              content: const Text(
                                                  'Hướng dẫn cách chơi game caro.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Đóng'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 143, 255, 147),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 43, vertical: 15),
                                        ),
                                        child: const Text(
                                          'How to play',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(
                                              context); // Thoát khỏi màn hình
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              237, 255, 93, 81),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 75, vertical: 15),
                                        ),
                                        child: const Text(
                                          'Exit',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: const Icon(Icons.settings),
                    ),
                  ],
                ),
              ),

              // Thông tin người chơi
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 10.0), // Giảm padding vertical
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    XOWidget(1),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    XOWidget(2),
                  ],
                ),
              ),

              // Bàn cờ
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0), // Giảm padding vertical
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
                      int row = index ~/ board.length; // Hàng của ô
                      int col = index % board.length; // Cột của ô

                      // Kiểm tra nếu đây là ô chiến thắng
                      bool isWinningCell = winningCells.any(
                        (cell) => cell[0] == row && cell[1] == col,
                      );

                      return GestureDetector(
                        onTap: () => onCellTap(row, col),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: board[row][col] == 3
                                ? Colors.orange // Hiệu ứng tô màu "bút lông"
                                : isWinningCell
                                    ? Colors.yellow.withOpacity(
                                        0.8) // Màu vàng nếu là ô thắng
                                    : Colors.grey.shade100, // Màu mặc định
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
                                    ? Colors.red // Màu đỏ cho X
                                    : board[row][col] == 2
                                        ? Colors.blue // Màu xanh cho O
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

              // Thông tin người chơi dưới bàn cờ
              Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, left: 20.0, right: 20.0), // Padding tổng thể
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Căn giữa toàn bộ Column
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Điều chỉnh vị trí các cột trong Row
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Căn giữa các phần tử trong Column 1
                          children: [
                            // Avatar của người chơi 1
                            // avatarWidget(1),
                            const SizedBox(height: 10),
                            playerWidget(1), // Hiển thị X hoặc thời gian
                          ],
                        ),
                        const SizedBox(width: 30), // Khoảng cách giữa 2 cột
                        Column(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Căn giữa các phần tử trong Column 2
                          children: [
                            // Avatar của người chơi 2
                            // avatarWidget(2),
                            const SizedBox(height: 10),
                            playerWidget(2), // Hiển thị O hoặc thời gian
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                        height: 20), // Khoảng cách giữa Row và phần tử dưới
                    // Các thành phần khác nếu cần thêm
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  // Widget hiển thị thông tin từng người chơi
  Widget playerWidget(int player) {
    bool isCurrentPlayer =
        currentPlayer == player; // Kiểm tra người chơi hiện tại
    bool isLeftSide = player == 1; // Xác định vị trí avatar (trái hoặc phải)

    return SizedBox(
      width: 200, // Chiều rộng cố định để đảm bảo bố cục không thay đổi
      height: 90, // Chiều cao cố định
      child: Stack(
        children: [
          // Vùng màu xám với bo tròn
          Align(
            alignment:
                isLeftSide ? Alignment.centerLeft : Alignment.centerRight,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 450), // Hiệu ứng mượt mà
              width: isCurrentPlayer ? 180 : 90, // Thu phóng về avatar
              height: isCurrentPlayer ? 70 : 40, // Cao hơn khi đến lượt
              decoration: BoxDecoration(
                color: isCurrentPlayer
                    ? Colors.grey.shade300
                    : Colors.transparent, // Màu xám khi đến lượt
                borderRadius: BorderRadius.circular(45), // Bo tròn cả hai bên
              ),
            ),
          ),
          // Avatar
          Align(
            alignment:
                isLeftSide ? Alignment.centerLeft : Alignment.centerRight,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 450), // Hiệu ứng thu phóng
              width: isCurrentPlayer ? 70 : 40, // Avatar lớn hơn khi đến lượt
              height: isCurrentPlayer ? 70 : 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle, // Avatar luôn hình tròn
                image: DecorationImage(
                  image: AssetImage(
                    player == 1
                        ? 'assets/images/avatar_1.jpg'
                        : 'assets/images/avatar_2.jpg', // Avatar người chơi
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Thời gian
          Align(
            alignment:
                isLeftSide ? Alignment.centerRight : Alignment.centerLeft,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 450), // Hiệu ứng mờ dần
              opacity: isCurrentPlayer ? 1.0 : 0.0, // Chỉ hiển thị khi đến lượt
              child: SizedBox(
                width: 150, // Kích thước cố định cho vùng thời gian
                child: Center(
                  child: Text(
                    '$timeLeft s', // Hiển thị thời gian còn lại
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget XOWidget(int player) {
// Kiểm tra xem có phải lượt chơi hiện tại không
    return SizedBox(
      width: 50, // Kích thước cố định
      height: 50,
      child: Center(
        child: Text(
          player == 1 ? 'X' : 'O', // Hiển thị X hoặc O
          style: TextStyle(
            fontSize: 40, // Kích thước chữ
            color: player == 1
                ? const Color.fromARGB(237, 255, 93, 81)
                : const Color.fromARGB(
                    255, 87, 174, 246), // Màu chữ đỏ cho X, xanh cho O
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

void sendWinnerToServer() {
  if (isOnlineMode && winnerId != null) {
    final message = jsonEncode({
      'type': 'gameOver',
      'winnerId': winnerId,
    });

    channel.sink.add(message); // Gửi thông điệp qua WebSocket
  }
}

class FireworksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 10; i++) {
      double x = size.width * (0.1 + 0.8 * i / 10);
      double y = size.height * (0.1 + 0.8 * i / 10);
      canvas.drawCircle(Offset(x, y), 20 + i * 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
