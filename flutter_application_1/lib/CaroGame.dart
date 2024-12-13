import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const TicTacToeApp());
}

bool isMuted = false;
int maxTime = 10;

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

class _GameScreenState extends State<GameScreen> {
  int currentPlayer = 1; // 1 là người chơi X, 2 là người chơi O
  int timeLeft = 10; // Thời gian còn lại cho mỗi lượt chơi
  Timer? timer;

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

  // Bắt đầu đếm ngược thời gian cho mỗi lượt chơi
  void startTimer() {
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

  // Chuyển lượt chơi khi hết thời gian
  void switchPlayer() {
    setState(() {
      currentPlayer = currentPlayer == 1 ? 2 : 1;
      timeLeft = 10; // Đặt lại thời gian cho lượt tiếp theo
    });
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
                  width: 380,
                  height: 380,
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    },
                    itemCount: 9,
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
    bool isCurrentPlayer = currentPlayer ==
        player; // Kiểm tra xem có phải lượt chơi hiện tại không
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
