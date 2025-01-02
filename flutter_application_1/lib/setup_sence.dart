import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/CaroGame.dart';
import 'package:flutter_application_1/model/model.dart';
import 'package:flutter_application_1/request/apiRoom.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'CaroGame.dart';
import 'package:rive/rive.dart';

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
        scaffoldBackgroundColor: const Color(0xFFF3F6FF), // Nền xanh nhạt
      ),
      home: const HomeScreen(),
    );
  }
}

// Màn hình chính (hiển thị hình ảnh và nút)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showImage = false; // Biến trạng thái để kiểm soát hiển thị hình ảnh

  @override
  void initState() {
    super.initState();
    _startTransition();
  }

  // Hàm đặt lại trạng thái và bắt đầu chuyển đổi
  void _startTransition() {
    setState(() {
      showImage = false; // Hiển thị lại hộp xanh
    });
    // Tự động thay đổi từ hộp xanh sang hình ảnh sau 2 giây
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        showImage = true; // Chuyển sang hiển thị hình ảnh
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startTransition(); // Đảm bảo hộp xanh xuất hiện khi quay lại màn hình
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Hộp trên cùng hiển thị hộp xanh hoặc hình ảnh
          AnimatedSwitcher(
            duration:
                const Duration(milliseconds: 500), // Hiệu ứng chuyển đổi mượt
            child: showImage
                ? Container(
                    key: const ValueKey("image"),
                    width: double.infinity,
                    height: 250,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/images/avatar_1.jpg'), // Đường dẫn hình ảnh
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                  )
                : Container(
                    key: const ValueKey("blueBox"),
                    width: double.infinity,
                    height: 250,
                    decoration: const BoxDecoration(
                      color: Colors.blue, // Hộp xanh
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 32),
          // Hai nút với màu khác nhau
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlayOnlineScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Nút màu đỏ
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Play Online",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(
                          title: "Play Offline",
                          subtitle: "This is the content for Play Offline",
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Nút màu xanh
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Play Offline",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Màn hình bên trong (SettingsScreen)
class SettingsScreen extends StatelessWidget {
  final String title;
  final String subtitle;

  const SettingsScreen(
      {super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Hộp tiêu đề với nút mũi tên
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: const BoxDecoration(
              color: Color(0xFFCCE5FF), // Màu xanh pastel
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context); // Quay lại màn hình trước
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
          if (title == "Play Offline")
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  buildDifficultyCard(
                    context,
                    title: "Dễ",
                    description: "Dành cho người mới bắt đầu",
                    color: const Color(0xFFE8F8E8), // Xanh lá nhạt
                    icon: Icons.emoji_emotions, // Biểu tượng mặt cười
                  ),
                  buildDifficultyCard(
                    context,
                    title: "Trung Bình",
                    description: "Cấp độ thử thách nhẹ nhàng",
                    color: const Color(0xFFFFF2CC), // Vàng nhạt
                    icon: Icons.insights, // Biểu tượng phân tích
                  ),
                  buildDifficultyCard(
                    context,
                    title: "Khó",
                    description: "Độ khó nâng cao",
                    color: const Color(0xFFCCE5FF), // Xanh dương nhạt
                    icon: Icons.trending_up, // Biểu tượng tăng trưởng
                  ),
                  buildDifficultyCard(
                    context,
                    title: "Cao Thủ",
                    description: "Đỉnh cao thử thách",
                    color: const Color(0xFFF4D7F8), // Tím nhạt
                    icon: Icons.star, // Biểu tượng ngôi sao
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Widget cho từng nút độ khó
  Widget buildDifficultyCard(BuildContext context,
      {required String title,
      required String description,
      required Color color,
      required IconData icon}) {
    return GestureDetector(
      onTap: () {
        // Xử lý sự kiện khi nhấn vào nút
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TicTacToeApp(),
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
                color: Colors.white, // Nền trắng cho biểu tượng
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

// Màn hình chơi game với độ khó được chọn
class GameScreen extends StatelessWidget {
  final String difficulty;

  const GameScreen({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Caro - Độ khó: $difficulty'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Đang chơi ở chế độ $difficulty',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// Thêm màn hình "Play Online"
class PlayOnlineScreen extends StatelessWidget {
  const PlayOnlineScreen({super.key});

  Future<List<Room>> callLoadRooms() async {
    final dataFetcher = DataRoom();
    return await dataFetcher.loadRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: callLoadRooms(),
        builder: (context, snapshot) {
          // Kiểm tra trạng thái kết nối
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // Hiển thị loading
          } else if (snapshot.data == null) {
            return const Text('data');
          } else {
            final rooms = snapshot.data!;
            return Scaffold(
              body: Stack(
                children: [
                  Column(
                    children: [
                      // Hộp tiêu đề "Play Online"
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 24),
                        decoration: const BoxDecoration(
                          color: Color(0xFFCCE5FF), // Màu xanh pastel
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomeScreen()),
                                  (Route<dynamic> route) =>
                                      false, // Loại bỏ tất cả các màn hình trước đó
                                );
                              },
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Play Online",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Nội dung cuộn với danh sách phòng
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: rooms.length, // Dựa trên số lượng phòng
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            print(room.roomId);
                            return buildPlayerCard(
                                context,
                                index,
                                room.roomType,
                                room.playerRight != 'null' ? 2 : 1,
                                2,
                                room.roomId);
                          },
                        ),
                      ),
                    ],
                  ),
                  // Thanh ngang cố định ở phía dưới
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          buildActionButton(
                            context,
                            icon: Icons.add_circle_outline,
                            label: "Tạo Phòng",
                            onTap: () {
                              _showCreateRoomDialog(context);
                            },
                          ),
                          buildActionButton(
                            context,
                            icon: Icons.key,
                            label: "Nhập Mã",
                            onTap: () {
                              // Xử lý logic tham gia bằng mã
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Tham Gia Bằng Mã"),
                                    content: const TextField(
                                      decoration: InputDecoration(
                                        labelText: "Nhập mã phòng",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Hủy"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Tham Gia"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          buildActionButton(
                            context,
                            icon: Icons.qr_code_scanner,
                            label: "Quét QR",
                            onTap: () {
                              // Xử lý logic quét QR
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Quét QR"),
                                    content: const Text(
                                        "Chức năng quét QR sẽ ở đây."),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Đóng"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

// Widget đại diện cho từng nút trên thanh ngang
Widget buildActionButton(BuildContext context,
    {required IconData icon,
    required String label,
    required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 28,
          color: Colors.black.withOpacity(0.7),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black.withOpacity(0.7),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

// Widget đại diện cho danh sách "thanh nhỏ"
Widget buildPlayerCard(BuildContext context, int index, String roomType,
    int currentPlayers, int maxPlayers, String roomId) {
  return GestureDetector(
    onTap: () {
      if (currentPlayers < maxPlayers) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Tham gia phòng"),
              content: Text("Bạn muốn tham gia Room ${index + 1}?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Hủy"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CaroGameScreen(roomId: roomId),
                      ),
                    ).then((result) async {
                      if (result != null) {
                        // Có dữ liệu trả về
                      }
                      // Không có dữ liệu trả về
                      final deleteResult = await DataRoom().deleteRoom(roomId);
                      print(deleteResult);
                    });
                  },
                  child: const Text("Tham gia"),
                ),
              ],
            );
          },
        );
      }
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFCCE5FF), // Nền xanh nhạt
            ),
            child: Center(
              child: Text(
                "${index + 1}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Room ${index + 1} (${roomType == 'public' ? 'Public' : 'Private'})",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Người chơi: $currentPlayers/$maxPlayers",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: currentPlayers < maxPlayers ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              currentPlayers < maxPlayers ? "Available" : "Full",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _showCreateRoomDialog(BuildContext context) {
  String roomName = ""; // Tên phòng
  String roomType = "Public"; // Loại phòng (mặc định Public)
  int turnTime = 30; // Thời gian mỗi lượt (mặc định 30 giây)
  String errorMessage = ""; // Thông báo lỗi

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Tạo Phòng Chơi",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Khoảng trống cố định cho thông báo lỗi
                  SizedBox(
                    height: 20,
                    child: errorMessage.isNotEmpty
                        ? Text(
                            errorMessage,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : null,
                  ),

                  // Nhập Tên Phòng
                  const Text(
                    "Tên Phòng:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Nhập tên phòng...",
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                        fontFamily: 'Roboto',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) => roomName = value,
                  ),
                  const SizedBox(height: 16),

                  // Loại Phòng
                  const Text(
                    "Loại Phòng:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Giữ không gian cố định cho các nút
                  SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        _buildFixedOptionButton(
                          label: "Public",
                          isSelected: roomType == "Public",
                          onTap: () {
                            setState(() => roomType = "Public");
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildFixedOptionButton(
                          label: "Private",
                          isSelected: roomType == "Private",
                          onTap: () {
                            setState(() => roomType = "Private");
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Kích Thước Bàn Chơi
                  const Text(
                    "Kích Thước Bàn Chơi:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Thời Gian Mỗi Lượt
                  const Text(
                    "Thời Gian Mỗi Lượt (giây):",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Nhập thời gian mỗi lượt...",
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                        fontFamily: 'Roboto',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      if (int.tryParse(value) != null) {
                        turnTime = int.parse(value);
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Nút Tạo Phòng và Hủy
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          "Hủy",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (roomName.isEmpty || turnTime <= 0) {
                            setState(() {
                              errorMessage = "Vui lòng nhập đầy đủ thông tin!";
                            });
                          } else {
                            try {
                              // Gọi API để tạo phòng và lấy roomId
                              final newRoomId = await DataRoom().createRoom(
                                roomName,
                                roomType,
                                "test11@gmail.com",
                                turnTime,
                              );

                              if (newRoomId.startsWith('Error:')) {
                                setState(() {
                                  errorMessage = "Không thể tạo phòng: $newRoomId";
                                });
                              } else {
                                print(newRoomId);
                                // Điều hướng đến màn hình CaroGameScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CaroGameScreen(roomId: newRoomId),
                                  ),
                                ).then((result) async {
                                  if (result != null) {
                                    // Có dữ liệu trả về
                                  }
                                  // Xóa phòng sau khi quay lại từ CaroGameScreen
                                  final deleteResult = await DataRoom().deleteRoom(newRoomId);
                                  print(deleteResult);
                                });
                              }
                            } catch (e) {
                              setState(() {
                                errorMessage = "Đã xảy ra lỗi: $e";
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: const Text(
                          "Tạo Phòng",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// Nút lựa chọn với kích thước cố định
Widget _buildFixedOptionButton({
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: 100, // Đặt chiều rộng cố định
      height: 40, // Đặt chiều cao cố định
      decoration: BoxDecoration(
        color: isSelected ? Colors.blueAccent : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey[50]!,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    ),
  );
}

// Widget tạo nút lựa chọn
Widget _buildOptionButton({
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blueAccent : Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : Colors.black,
          fontFamily: 'Roboto',
        ),
      ),
    ),
  );
}

class CaroGameScreen extends StatefulWidget {
  final String roomId;

  const CaroGameScreen({super.key, required this.roomId});

  @override
  _CaroGameScreenState createState() => _CaroGameScreenState();
}

class _CaroGameScreenState extends State<CaroGameScreen> {
  final int boardSize = 15;
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('wss://carogame.onrender.com'),
  );

  List<String> cells = [];
  String statusMessage = 'Waiting to join a room...';
  String? mySymbol;
  int currentPlayer = 1; // Người chơi hiện tại
  int timeLeft = 30; // Thời gian còn lại
  double timeProgress = 1.0; // Tiến độ thời gian

  @override
  void initState() {
    super.initState();
    cells = List.filled(boardSize * boardSize, '');
    joinRoom();
    channel.stream.listen((message) {
      final data = jsonDecode(message);
      setState(() {
        if (data['type'] == 'waiting' || data['type'] == 'game-ready') {
          statusMessage = data['message'];
        } else if (data['type'] == 'game-start') {
          statusMessage = 'Game started! Your symbol: ${data['symbol']}';
          mySymbol = data['symbol'];
        } else if (data['type'] == 'move') {
          final index = data['payload']['index'];
          final symbol = data['payload']['symbol'];
          cells[index] = symbol;
        } else if (data['type'] == 'game-over') {
          statusMessage = data['message'];
          channel.sink.close();
        }
      });
    });
  }

  void joinRoom() {
    if (widget.roomId.isNotEmpty) {
      channel.sink.add(jsonEncode({
        'type': 'join-room',
        'payload': {'roomId': widget.roomId},
      }));
    }
  }

  void makeMove(int index) {
    if (cells[index].isEmpty) {
      channel.sink.add(jsonEncode({
        'type': 'move',
        'payload': {'index': index},
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(widget.roomId),
          // Thanh hiển thị thông tin người chơi
          Container(
            height: 105,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildPlayerAvatar(1), // Avatar người chơi 1
                buildTimer(), // Thời gian đếm ngược
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
                    child: GestureDetector(
                      onTapDown: (details) {
                        // Xử lý sự kiện nhấn vào bàn cờ
                        final tapPosition = details.localPosition;
                        final cellSize =
                            MediaQuery.of(context).size.width / boardSize;
                        final row = (tapPosition.dy ~/ cellSize).toInt();
                        final col = (tapPosition.dx ~/ cellSize).toInt();
                        final index = row * boardSize + col;

                        makeMove(index);
                      },
                      child: const SizedBox.expand(),
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

  /// Widget hiển thị avatar người chơi
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
                value: isCurrentPlayer ? timeProgress : 0,
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

  /// Widget hiển thị thời gian
  Widget buildTimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          statusMessage == "Both players connected!"
              ? timeLeft.toString()
              : statusMessage,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        statusMessage == "Both players connected!"
            ? const Text(
                ' s',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              )
            : const SizedBox(),
        
      ],
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
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
