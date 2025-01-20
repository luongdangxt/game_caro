import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/CaroGame.dart';
import 'package:flutter_application_1/request/saveLogin.dart';
import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CaroGameScreen extends StatefulWidget {
  final String roomId;
  final String avatar;
  const CaroGameScreen({super.key, required this.roomId, required this.avatar});

  @override
  _CaroGameScreenState createState() => _CaroGameScreenState();
}

class _CaroGameScreenState extends State<CaroGameScreen> {
  String? nameUser; // Khởi tạo giá trị mặc định

  final int boardSize = 15;
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('wss://carogame.onrender.com'),
  );

  List<String> dataPlayers = []; // [username1, avatar1, username2, avatar2]
  List<String> cells = [];
  String statusMessage = 'ROOM ID ';
  String? mySymbol;
  String currentPlayerNow = "X";
  List<int> indexWin = [];

  final TextEditingController roomIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    statusMessage = 'ROOM ID: ${widget.roomId}';
    getInfoLogin().then((_) {
      joinRoom(); // Chỉ gọi joinRoom sau khi getInfoLogin hoàn tất
    });
    cells = List.filled(boardSize * boardSize, '');
    channel.stream.listen((message) {
      final data = jsonDecode(message);
      setState(() {
        if (data['type'] == 'waiting') {
          print('waiting');
          statusMessage = 'ROOM ID: ${widget.roomId}';
        } else if (data['type'] == 'game-ready') {
          print('game-ready');
          statusMessage = data['message'];
          data['players'].forEach((player) {
            if (nameUser == player['username']) {
              mySymbol = player['symbol'];
            }
            dataPlayers.add(player['username']);
            dataPlayers.add(player['avatar']);
          });
        } else if (data['type'] == 'move') {
          print('move');
          final index = data['payload']['index'];
          final symbol = data['payload']['symbol'];
          cells[index] = symbol;
        } else if (data['type'] == 'game-over') {
          print('game-over');
          if (data['message'] == 'X wins!') {
            statusMessage = data['message'];
            indexWin = List<int>.from(data['payload']); // Lưu các ô thắng
            if (mySymbol == 'X') {
              Future.delayed(Duration(milliseconds: winningCells.length * 5000),
                  () {
                showVictoryDialog();
              });
            } else {
              Future.delayed(Duration(milliseconds: winningCells.length * 5000),
                  () {
                showLoseDialog();
              });
            }
          } else if (data['message'] == 'O wins!') {
            statusMessage = data['message'];
            indexWin = List<int>.from(data['payload']); // Lưu các ô thắng
            if (mySymbol == 'O') {
              Future.delayed(Duration(milliseconds: winningCells.length * 5000),
                  () {
                showVictoryDialog();
              });
            } else {
              Future.delayed(Duration(milliseconds: winningCells.length * 5000),
                  () {
                showLoseDialog();
              });
            }
          } else if (data['message'] == "Opponent disconnected!") {
            statusMessage = data['message'];
            if (mySymbol == data['symbol']) {
              Future.delayed(
                  Duration(milliseconds: winningCells.length * 33000), () {
                showVictoryDialog();
              });
            } else {
              Future.delayed(Duration(milliseconds: winningCells.length * 3000),
                  () {
                showLoseDialog();
              });
            }
          }
          channel.sink.close();
        } else if (data['type'] == 'time-update') {
          print('time-update');
          statusMessage = data['payload']['timeLeft'];
          currentPlayerNow = data['payload']['currentPlayer'];
        } else if (data['type'] == 'timeout') {
          print('timeout');
          statusMessage = data['message'];
        }
      });
    });
  }

  void joinRoom() {
    if (widget.roomId.isNotEmpty) {
      channel.sink.add(jsonEncode({
        'type': 'join-room',
        'payload': {
          'roomId': widget.roomId,
          'username': nameUser,
          'avatar': widget.avatar
        },
      }));
    }
  }

  Future<void> getInfoLogin() async {
    final dataUser = await saveLogin().getUserData();
    setState(() {
      nameUser = dataUser['username'];
    });
  }

  bool isAnimating = false;

  void makeMove(int index) {
    if (cells[index].isEmpty && !isAnimating) {
      setState(() {
        isAnimating = true;
      });
      // Gửi nước đi qua WebSocket
      channel.sink.add(jsonEncode({
        'type': 'move',
        'payload': {'index': index},
      }));

      // Đặt lại trạng thái sau khi animation kết thúc
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          isAnimating = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // Kích thước thiết kế ban đầu
      builder: (context, child) {
        return Scaffold(
          appBar: null, // Xóa AppBar
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Chiều cao tổng cộng của màn hình
                final screenHeight = constraints.maxHeight;
                final avatarHeight = screenHeight *
                    0.23; // Chiều cao tối đa cho phần avatar và dòng trạng thái
                final boardHeight =
                    screenHeight * 0.7; // Chiều cao tối đa cho bảng caro

                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Nền giao diện
                    Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/back_game.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Column(
                      children: [
                        const SizedBox(height: 35),
                        Text(
                          statusMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 3.0,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.6), // Thêm khoảng cách hai bên
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double availableWidth = constraints.maxWidth -
                                    30; // Trừ khoảng padding hai bên
                                double size =
                                    availableWidth < constraints.maxHeight
                                        ? availableWidth
                                        : constraints.maxHeight;
                                double cellSize = size / 15;

                                return Center(
                                  child: Container(
                                    width: size,
                                    height: size,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      borderRadius: BorderRadius.circular(0),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color.fromARGB(0, 0, 0, 0),
                                          blurRadius: 5,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        CustomPaint(
                                          size: Size(size, size),
                                          painter: GridPainter(
                                            boardSize: 15,
                                            cellSize: cellSize,
                                          ),
                                        ),
                                        GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 15,
                                            crossAxisSpacing: 0,
                                            mainAxisSpacing: 0,
                                            childAspectRatio: 1,
                                          ),
                                          itemCount: 15 * 15,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            // Kiểm tra ô hiện tại có nằm trong danh sách ô chiến thắng không
                                            bool isWinningCell =
                                                indexWin.contains(index);

                                            return GestureDetector(
                                              onTap: () => makeMove(index),
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                decoration: BoxDecoration(
                                                  color: isWinningCell
                                                      ? Colors.yellow
                                                          .withOpacity(0.8)
                                                      : const Color.fromARGB(
                                                          0, 251, 168, 162),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  boxShadow: [
                                                    if (isWinningCell)
                                                      const BoxShadow(
                                                        color: Colors.orange,
                                                        blurRadius: 10,
                                                        offset: Offset(0, 0),
                                                      ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: AnimatedSwitcher(
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                    transitionBuilder:
                                                        (child, animation) {
                                                      return FadeTransition(
                                                        opacity: animation,
                                                        child: ScaleTransition(
                                                          scale: animation,
                                                          child: child,
                                                        ),
                                                      );
                                                    },
                                                    child: cells[index]
                                                            .isNotEmpty
                                                        ? Text(
                                                            cells[index],
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  cells[index] ==
                                                                          'X'
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .blue,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          )
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Khoảng trống nhỏ bên dưới
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (dataPlayers.isNotEmpty)
                                playerWidget(1, dataPlayers[0], dataPlayers[1]),
                              if (dataPlayers.isNotEmpty)
                                playerWidget(2, dataPlayers[2], dataPlayers[3]),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceEvenly, // Căn đều trong màn hình
                          children: [
                            _buildCircleIcon(Icons.play_arrow),
                            _buildCircleIcon(Icons.pause),
                            _buildCircleIcon(Icons.reply),
                          ],
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircleIcon(IconData icon) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            color: Colors.brown,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 44,
          ),
        ),
      ],
    );
  }

  int currentPlayer = 1;
  double timeLeft = 10; // Thời gian còn lại cho mỗi lượt chơi
  Timer? timer;

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

  void switchPlayer() {
    setState(() {
      currentPlayer = currentPlayer == 1 ? 2 : 1; // Đổi lượt
      timeLeft = maxTime; // Reset thời gian
      startTimer(); // Bắt đầu lại đếm ngược
    });
  }

  // Widget hiển thị thông tin từng người chơi
  Widget playerWidget(int player, String username, String stringAvatar) {
    // currentPlayerNow
    Color right = const Color.fromARGB(255, 153, 190, 189);
    Color rightSelect = const Color.fromARGB(255, 13, 199, 190);
    Color left = const Color.fromARGB(255, 197, 156, 156);
    Color leftSelect = const Color.fromARGB(255, 202, 19, 19);

    bool isCurrentPlayer =
        currentPlayer == player; // Kiểm tra người chơi hiện tại
    bool isLeftSide = player == 1; // Xác định vị trí avatar (trái hoặc phải)
    return SizedBox(
      width: 150, // Chiều rộng cố định để đảm bảo bố cục không thay đổi
      height: 130, // Chiều cao cố định

      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              // image: const DecorationImage(
              //   image: AssetImage('assets/images/back_game.png'),
              //   fit: BoxFit.cover,
              // ),

              color: isLeftSide
                  ? currentPlayerNow == "X"
                      ? leftSelect
                      : left
                  : currentPlayerNow == "O"
                      ? rightSelect
                      : right,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          // Vùng màu xám với bo tròn
          // Align(
          //   alignment:
          //       isLeftSide ? Alignment.centerLeft : Alignment.centerRight,
          //   child: AnimatedContainer(
          //     duration: const Duration(milliseconds: 450), // Hiệu ứng mượt mà
          //     width: isCurrentPlayer ? 120 : 90, // Thu phóng về avatar
          //     height: isCurrentPlayer ? 50 : 40, // Cao hơn khi đến lượt
          //     decoration: BoxDecoration(
          //       color: isCurrentPlayer
          //           ? Colors.grey.shade300
          //           : Colors.transparent, // Màu xám khi đến lượt
          //       borderRadius: BorderRadius.circular(45), // Bo tròn cả hai bên
          //     ),
          //   ),
          // ),
          // Avatar
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  player == 1
                      ? const SizedBox(
                          width: 20,
                        )
                      : Container(),
                  player == 2
                      ? const Text(
                          'O',
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )
                      : Container(),
                  player == 2
                      ? const SizedBox(
                          width: 10,
                        )
                      : Container(),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // Avatar luôn hình tròn
                        image: DecorationImage(
                          image: AssetImage(stringAvatar),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  player == 2
                      ? const SizedBox(
                          width: 20,
                        )
                      : Container(),
                  player == 1
                      ? const SizedBox(
                          width: 10,
                        )
                      : Container(),
                  player == 1
                      ? const Text(
                          'X',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )
                      : Container()
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                username,
                style: const TextStyle(
                  fontSize: 20,
                ),
              )
            ],
          )
          // Thời gian
          // Align(
          //   alignment:
          //       isLeftSide ? Alignment.centerRight : Alignment.centerLeft,
          //   child: AnimatedOpacity(
          //     duration: const Duration(milliseconds: 450), // Hiệu ứng mờ dần
          //     opacity: isCurrentPlayer ? 1.0 : 0.0, // Chỉ hiển thị khi đến lượt
          //     child: SizedBox(
          //       width: 120, // Kích thước cố định cho vùng thời gian
          //       child: Center(
          //         child: Text(
          //           '$timeLeft s', // Hiển thị thời gian còn lại
          //           style: const TextStyle(
          //             fontSize: 22,
          //             color: Colors.black54,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
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
                    height: 550,
                    width: 350,
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
                          'assets/images/win.png',
                          height: 270,
                          width: 270,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Nút Thoát
                            Container(
                              height: 100,
                              width: 250,
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
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'EXIT',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 255, 0, 0),
                                  ),
                                ),
                              ),
                            ),
                            // Nút Reset
                          ],
                        ),
                        const SizedBox(height: 170),
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

  void showLoseDialog() {
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
                    height: 550,
                    width: 350,
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
                          'assets/images/lose.png',
                          height: 270,
                          width: 270,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Nút Thoát
                            Container(
                              height: 100,
                              width: 250,
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
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'EXIT',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 255, 0, 0),
                                  ),
                                ),
                              ),
                            ),
                            // Nút Reset
                          ],
                        ),
                        const SizedBox(height: 160),
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
