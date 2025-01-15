import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/CaroGame.dart';
import 'package:flutter_application_1/model/model.dart';
import 'package:flutter_application_1/request/apiRoom.dart';
import 'package:flutter_application_1/request/saveLogin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'CaroGame.dart';
import 'package:rive/rive.dart';
import 'AI caro/caro_offline.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:rive/rive.dart' as rive;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
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
    Future.delayed(const Duration(seconds: 0), () {
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/back_setup.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Hộp trên cùng hiển thị hộp xanh hoặc hình ảnh
          // AnimatedSwitcher(
          //   duration:
          //       const Duration(milliseconds: 500), // Hiệu ứng chuyển đổi mượt
          //   child: showImage
          //       ? Container(
          //           key: const ValueKey("image"),
          //           width: double.infinity,
          //           height: 250,
          //           decoration: const BoxDecoration(
          //             // image: DecorationImage(
          //             //   image: AssetImage(''), // Đường dẫn hình ảnh
          //             //   fit: BoxFit.cover,
          //             // ),
          //             borderRadius: BorderRadius.only(
          //               bottomLeft: Radius.circular(24),
          //               bottomRight: Radius.circular(24),
          //             ),
          //           ),
          //         )
          //       : Container(
          //           key: const ValueKey("blueBox"),
          //           width: double.infinity,
          //           height: 250,
          //           decoration: const BoxDecoration(
          //             color: Colors.blue, // Hộp xanh
          //             borderRadius: BorderRadius.only(
          //               bottomLeft: Radius.circular(24),
          //               bottomRight: Radius.circular(24),
          //             ),
          //           ),
          //         ),
          // ),
          // const SizedBox(height: 32),
          // Hai nút với màu khác nhau
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 100),
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 132,
                        width: 350,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/btn.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.transparent, // Để nền nút trong suốt
                            shadowColor: Colors.transparent, // Bỏ hiệu ứng bóng
                          ),
                          onPressed: () {
                            Navigator.pop(
                                context); // Quay lại màn hình trước đó
                          },
                          child: const Text(
                            'MENU GAME',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 100,
                        width: 300,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/btn.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.transparent, // Để nền nút trong suốt
                            shadowColor: Colors.transparent, // Bỏ hiệu ứng bóng
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayOnlineScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Play Online',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 100,
                        width: 300,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/btn.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.transparent, // Để nền nút trong suốt
                            shadowColor: Colors.transparent, // Bỏ hiệu ứng bóng
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CaroGame(),
                              ),
                            );
                          },
                          child: const Text(
                            'Play Offline',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceEvenly, // Các phần tử cách đều nhau
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/btn_how.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/btn_home.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/btn_audio.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Thêm màn hình "Play Online"
class PlayOnlineScreen extends StatelessWidget {
  PlayOnlineScreen({super.key});

  Future<List<Room>> callLoadRooms() async {
    final dataFetcher = DataRoom();
    return await dataFetcher.loadRooms();
  }

  final TextEditingController idRoom = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final TextEditingController idRoom = TextEditingController();
    return Scaffold(
      body: FutureBuilder(
        future: callLoadRooms(),
        builder: (context, snapshot) {
          // Kiểm tra trạng thái kết nối
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AnimatedBackgroundLoader();
          } else if (snapshot.data == null) {
            return const Text('data');
          } else {
            final rooms = snapshot.data!;
            return Scaffold(
              body: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/back_room.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Đặt khoảng cách đều
                        children: [
                          SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // Hành động khi nhấn vào Container
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const HomeScreen()),
                                      (Route<dynamic> route) =>
                                          false, // Loại bỏ tất cả các màn hình trước đó
                                    );
                                    // Hoặc điều hướng, logic khác ở đây
                                  },
                                  child: Container(
                                    height: 35,
                                    width: 70,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/btn_back.png'),
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 80,
                                width: 200,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image:
                                        AssetImage('assets/images/khung.png'),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              const Text(
                                "Play Online",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 70),
                        ],
                      ),

                      // Hộp tiêu đề "Play Online"
                      const SizedBox(height: 15),
                      Container(
                        alignment: Alignment.center,
                        height: 2, // Độ dày của đường kẻ
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16), // Thu hẹp chiều dài ở hai đầu
                        decoration: BoxDecoration(
                          color: Colors.grey, // Màu sắc của đường kẻ
                          borderRadius:
                              BorderRadius.circular(4), // Bo tròn hai đầu
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Nội dung cuộn với danh sách phòng

                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Số container mỗi hàng
                            crossAxisSpacing:
                                16, // Khoảng cách ngang giữa các container
                            mainAxisSpacing:
                                16, // Khoảng cách dọc giữa các container
                            childAspectRatio:
                                1, // Tỉ lệ width : height của mỗi container (1 là vuông)
                          ),
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
                              room.roomId,
                            );
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
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: 2, // Độ dày của đường kẻ
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16), // Thu hẹp chiều dài ở hai đầu
                          decoration: BoxDecoration(
                            color: Colors.grey, // Màu sắc của đường kẻ
                            borderRadius:
                                BorderRadius.circular(4), // Bo tròn hai đầu
                          ),
                        ),
                        SizedBox(
                          height: 100,
                          width: 400,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 148, 74,
                                        21), // Màu nền nâu nhạt (tan)
                                    borderRadius: BorderRadius.circular(
                                        20), // Bo góc khung
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 136, 68, 19), // Màu viền nâu đậm
                                      width: 2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8), // Thêm padding bên trong
                                  child: TextField(
                                    controller: idRoom,
                                    decoration: const InputDecoration(
                                      labelText: "ID Room",
                                      labelStyle: TextStyle(
                                        color: Color.fromARGB(255, 255, 255,
                                            255), // Màu chữ của label
                                      ),
                                      border: InputBorder
                                          .none, // Loại bỏ viền mặc định của TextField
                                    ),
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 255, 255,
                                          255), // Màu chữ của nội dung nhập
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                height: 65,
                                width: 110,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/btn.png'),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: const Text(
                                  "ENTER",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 120,
                          width: 300,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/btn.png'),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: const Text(
                            "CREATE ROOM",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Column(
                    children: [
                      //   Container(
                      //     padding: const EdgeInsets.symmetric(vertical: 8),
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.circular(100),
                      //       boxShadow: [
                      //         BoxShadow(
                      //           color: Colors.black.withOpacity(0.1),
                      //           blurRadius: 8,
                      //           offset: const Offset(0, 4),
                      //         ),
                      //       ],
                      //     ),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //       children: [
                      //         buildActionButton(
                      //           context,
                      //           icon: Icons.add_circle_outline,
                      //           label: "Tạo Phòng",
                      //           onTap: () {
                      //             _showCreateRoomDialog(context);
                      //           },
                      //         ),
                      //         buildActionButton(
                      //           context,
                      //           icon: Icons.key,
                      //           label: "Nhập Mã",
                      //           onTap: () {
                      //             // Xử lý logic tham gia bằng mã
                      //             showDialog(
                      //               context: context,
                      //               builder: (context) {
                      //                 return AlertDialog(
                      //                   title: const Text("Tham Gia Bằng Mã"),
                      //                   content: TextField(
                      //                     controller: idRoom,
                      //                     decoration: const InputDecoration(
                      //                       labelText: "Nhập mã phòng",
                      //                       border: OutlineInputBorder(),
                      //                     ),
                      //                   ),
                      //                   actions: [
                      //                     TextButton(
                      //                       onPressed: () =>
                      //                           Navigator.pop(context),
                      //                       child: const Text("Hủy"),
                      //                     ),
                      //                     TextButton(
                      //                       onPressed: () {
                      //                         final joinRoomId = idRoom.text;
                      //                         Navigator.push(
                      //                           context,
                      //                           MaterialPageRoute(
                      //                             builder: (context) =>
                      //                                 CaroGameScreen(
                      //                                     roomId: joinRoomId),
                      //                           ),
                      //                         ).then((result) async {
                      //                           if (result != null) {
                      //                             // Có dữ liệu trả về
                      //                           }
                      //                           // Xóa phòng sau khi quay lại từ CaroGameScreen
                      //                           final deleteResult =
                      //                               await DataRoom()
                      //                                   .deleteRoom(joinRoomId);
                      //                           print(deleteResult);
                      //                         });
                      //                       },
                      //                       child: const Text("Tham Gia"),
                      //                     ),
                      //                   ],
                      //                 );
                      //               },
                      //             );
                      //           },
                      //         ),
                      //         buildActionButton(
                      //           context,
                      //           icon: Icons.qr_code_scanner,
                      //           label: "Quét QR",
                      //           onTap: () {
                      //             // Xử lý logic quét QR
                      //             showDialog(
                      //               context: context,
                      //               builder: (context) {
                      //                 return AlertDialog(
                      //                   title: const Text("Quét QR"),
                      //                   content: const Text(
                      //                       "Chức năng quét QR sẽ ở đây."),
                      //                   actions: [
                      //                     TextButton(
                      //                       onPressed: () =>
                      //                           Navigator.pop(context),
                      //                       child: const Text("Đóng"),
                      //                     ),
                      //                   ],
                      //                 );
                      //               },
                      //             );
                      //           },
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                    ],
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
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 280,
                  width: 370,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          "assets/images/khung.png"), // Đường dẫn ảnh nền
                      fit: BoxFit.fitHeight, // Cách hiển thị ảnh
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Tham gia phòng",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      const Text(
                        "Bạn muốn tham gia Room?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                height: 70,
                                width: 110,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        "assets/images/btn.png"), // Đường dẫn ảnh nền
                                    fit: BoxFit.fill, // Cách hiển thị ảnh
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "Hủy",
                                        style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 80.0),
                          Stack(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                height: 70,
                                width: 110,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        "assets/images/btn.png"), // Đường dẫn ảnh nền
                                    fit: BoxFit.fill, // Cách hiển thị ảnh
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CaroGameScreen(roomId: roomId),
                                          ),
                                        ).then((result) async {
                                          if (result != null) {
                                            // Có dữ liệu trả về
                                          }
                                          // Không có dữ liệu trả về
                                          final deleteResult = await DataRoom()
                                              .deleteRoom(roomId);
                                          print(deleteResult);
                                        });
                                      },
                                      child: const Text(
                                        "Tham gia",
                                        style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 0, 94, 255),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
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
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/khung.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double containerWidth = constraints.maxWidth;
          double containerHeight = constraints.maxHeight;

          return Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: containerHeight * 0.1), // Khoảng cách động
                    FractionallySizedBox(
                      widthFactor: 0.5, // Chiếm 50% chiều rộng container
                      child: Container(
                        height: containerHeight * 0.2, // Chiều cao theo tỷ lệ
                        width: containerWidth * 0.8,
                        alignment: Alignment.center,
                        child: Text(
                          "Room ${index + 1}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: containerWidth * 0.14, // Font động
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: containerHeight * 0.05), // Khoảng cách động
                    Text(
                      "Người chơi: $currentPlayers/$maxPlayers",
                      style: TextStyle(
                        fontSize: containerWidth * 0.09, // Font động
                        color: const Color.fromARGB(255, 255, 255, 255)
                            .withOpacity(0.6),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.6, // 60% chiều rộng container
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: containerWidth * 0.03, // Padding động
                    vertical: containerHeight * 0.01, // Padding động
                  ),
                  decoration: BoxDecoration(
                    color:
                        currentPlayers < maxPlayers ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(containerWidth * 0.03),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    currentPlayers < maxPlayers ? "Available" : "Full",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: containerWidth * 0.1, // Font động
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: containerHeight * 0.23), // Khoảng cách động
            ],
          );
        },
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
                                  errorMessage =
                                      "Không thể tạo phòng: $newRoomId";
                                });
                              } else {
                                print(newRoomId);
                                // Điều hướng đến màn hình CaroGameScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CaroGameScreen(roomId: newRoomId),
                                  ),
                                ).then((result) async {
                                  if (result != null) {
                                    // Có dữ liệu trả về
                                  }
                                  // Xóa phòng sau khi quay lại từ CaroGameScreen
                                  final deleteResult =
                                      await DataRoom().deleteRoom(newRoomId);
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

class AnimatedBackgroundLoader extends StatefulWidget {
  const AnimatedBackgroundLoader({super.key});

  @override
  State<AnimatedBackgroundLoader> createState() =>
      _AnimatedBackgroundLoaderState();
}

class _AnimatedBackgroundLoaderState extends State<AnimatedBackgroundLoader>
    with SingleTickerProviderStateMixin {
  final List<String> _loadingImages = [
    'assets/images/loading/6.png',
    'assets/images/loading/5.png',
    'assets/images/loading/4.png',
    'assets/images/loading/3.png',
    'assets/images/loading/2.png',
    'assets/images/loading/1.png',
  ];
  int _currentImageIndex = 0;
  int _nextImageIndex = 1;
  bool _isFirstImageDisplayed = true; // Cờ để xác định ảnh đầu tiên
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _opacityAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);

    _startImageRotation();
  }

  void _startImageRotation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_isFirstImageDisplayed) {
        // Bỏ qua hiệu ứng cho ảnh đầu tiên
        setState(() {
          _isFirstImageDisplayed = false;
        });
        return;
      }

      await _animationController.forward(); // Hiệu ứng mờ dần
      setState(() {
        _currentImageIndex = _nextImageIndex;
        _nextImageIndex = (_nextImageIndex + 1) % _loadingImages.length;
      });
      _animationController.reset(); // Reset để chuẩn bị cho lần tiếp theo
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ảnh hiện tại
        flutter.Image.asset(
          _loadingImages[_currentImageIndex],
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        // Hiệu ứng fade chỉ áp dụng từ ảnh thứ hai trở đi
        if (!_isFirstImageDisplayed)
          FadeTransition(
            opacity: _opacityAnimation,
            child: flutter.Image.asset(
              _loadingImages[_nextImageIndex],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
      ],
    );
  }
}

class CaroGameScreen extends StatefulWidget {
  final String roomId;

  const CaroGameScreen({super.key, required this.roomId});

  @override
  _CaroGameScreenState createState() => _CaroGameScreenState();
}

class _CaroGameScreenState extends State<CaroGameScreen> {
  String? nameUser; // Khởi tạo giá trị mặc định
  String? stringAvatar; // Khởi tạo giá trị mặc định

  final int boardSize = 15;
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('wss://carogame.onrender.com'),
  );

  List<String> dataPlayers = []; // [username1, avatar1, username2, avatar2]
  List<String> cells = [];
  String statusMessage = 'Waiting to join a room...';
  String? mySymbol;
  String currentPlayerNow = "X";

  final TextEditingController roomIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getInfoLogin().then((_) {
      joinRoom(); // Chỉ gọi joinRoom sau khi getInfoLogin hoàn tất
    });
    cells = List.filled(boardSize * boardSize, '');
    channel.stream.listen((message) {
      final data = jsonDecode(message);
      setState(() {
        if (data['type'] == 'waiting') {
          statusMessage = data['message'];
          print(1);
        } else if (data['type'] == 'game-ready') {
          statusMessage = data['message'];
          data['players'].forEach((player) {
            dataPlayers.add(player['username']);
            dataPlayers.add(player['avatar']);
          });
          print(2);
        } else if (data['type'] == 'game-start') {
          statusMessage = 'Game started! Your symbol: ${data['symbol']}';
          mySymbol = data['symbol'];
          print(3);
        } else if (data['type'] == 'move') {
          final index = data['payload']['index'];
          final symbol = data['payload']['symbol'];
          cells[index] = symbol;
          print(4);
        } else if (data['type'] == 'game-over') {
          statusMessage = data['message'];
          channel.sink.close();
          print(5);
        } else if (data['type'] == 'time-update') {
          statusMessage = data['payload']['timeLeft'];
          currentPlayerNow = data['payload']['currentPlayer'];
          print(6);
        } else if (data['type'] == 'timeout') {
          statusMessage = data['message'];
          print(7);
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
          'avatar': stringAvatar
        },
      }));
    }
  }

  Future<void> getInfoLogin() async {
    final dataUser = await saveLogin().getUserData();
    setState(() {
      nameUser = dataUser['username'];
      stringAvatar = dataUser['avatar'];
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
            body: LayoutBuilder(
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

                    Container(
                      height: 405,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 144, 97, 80),
                        borderRadius: BorderRadius.circular(25),
                        // image: const DecorationImage(
                        //   image: AssetImage('assets/images/back_game.png'),
                        //   fit: BoxFit.cover,
                        // ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 35),
                              // child: Text(
                              //   statusMessage,
                              //   textAlign: TextAlign.center,
                              //   style: const TextStyle(
                              //     fontSize: 16,
                              //     color: Colors.white,
                              //     fontWeight: FontWeight.bold,
                              //     shadows: [
                              //       Shadow(
                              //         offset: Offset(1.0, 1.0),
                              //         blurRadius: 3.0,
                              //         color: Colors.black,
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ),
                          ),
                        ],
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
                        // Đẩy bảng caro lên sát avatar hơn
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                //horizontal: 5.0,
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
                                            crossAxisSpacing: 1,
                                            mainAxisSpacing: 1,
                                            childAspectRatio: 1,
                                          ),
                                          itemCount: 15 * 15,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            int row = index ~/ boardSize;
                                            int col = index % boardSize;

                                            bool isWinningCell =
                                                winningCells.any(
                                              (cell) =>
                                                  cell[0] == row &&
                                                  cell[1] == col,
                                            );

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
                                                        milliseconds:
                                                            500), // Thời gian hiệu ứng
                                                    transitionBuilder:
                                                        (Widget child,
                                                            Animation<double>
                                                                animation) {
                                                      return FadeTransition(
                                                        opacity:
                                                            animation, // Hiệu ứng mờ dần khi thay đổi
                                                        child: ScaleTransition(
                                                          scale:
                                                              animation, // Hiệu ứng phóng to/thu nhỏ
                                                          child: child,
                                                        ),
                                                      );
                                                    },
                                                    child: Center(
                                                      child: cells[index]
                                                              .isNotEmpty
                                                          ? Text(
                                                              cells[
                                                                  index], // Hiển thị "X" hoặc "O"
                                                              style: TextStyle(
                                                                fontSize: 24,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: cells[
                                                                            index] ==
                                                                        'X'
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .blue,
                                                              ),
                                                            )
                                                          : null, // Không hiển thị gì nếu ô trống
                                                    ),
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
                          height: avatarHeight,
                          // decoration: const BoxDecoration(
                          //   image: DecorationImage(
                          //     image: AssetImage(''),
                          //     fit: BoxFit.cover,
                          //   ),
                          // ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              dataPlayers.isNotEmpty
                                  ? playerWidget(
                                      1, dataPlayers[0], dataPlayers[1])
                                  : Container(),
                              dataPlayers.isNotEmpty
                                  ? playerWidget(
                                      2, dataPlayers[2], dataPlayers[3])
                                  : Container(),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceEvenly, // Căn đều trong màn hình
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
                                  width:
                                      70, // Slightly smaller than outer circle
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
                                  width:
                                      70, // Slightly smaller than outer circle
                                  height: 70,
                                  decoration: const BoxDecoration(
                                    color: Colors.brown, // Inner circle color
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.pause, // Play icon
                                    color: Colors.white,
                                    size: 44, // Icon size
                                  ),
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
                                  width:
                                      70, // Slightly smaller than outer circle
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
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ],
                );
              },
            ),
          );
        });
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
    Uint8List avatar = base64Decode(stringAvatar);
    return SizedBox(
      width: 225, // Chiều rộng cố định để đảm bảo bố cục không thay đổi
      height: 140, // Chiều cao cố định

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
                            fontSize: 20,
                          ),
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
                          image: MemoryImage(avatar),
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
                            fontSize: 20,
                          ),
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

class WritingText extends StatelessWidget {
  final String character; // "X" hoặc "O"
  final Color color;

  const WritingText({required this.character, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    print('Loading Rive file from: assets/rive/drawx.riv');
    return SizedBox(
      width: 40,
      height: 40,
      child: RiveAnimation.asset(
        'assets/rive/drawx.riv',
        artboard: character.toUpperCase(),
        fit: BoxFit.contain,
        onInit: (Artboard artboard) {
          print('Bản vẽ Rive đã được khởi tạo:: ${artboard.name}');
          final controller =
              StateMachineController.fromArtboard(artboard, 'StateMachine');
          if (controller != null) {
            artboard.addController(controller);
            print('StateMachineController added successfully.');
          } else {
            print('Không thể khởi tạo StateMachineController.');
          }
        },
      ),
    );
  }
}
