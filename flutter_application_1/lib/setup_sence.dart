import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/CaroGame.dart';
import 'package:flutter_application_1/UI/login.dart';
import 'package:flutter_application_1/UI/register.dart';
import 'package:flutter_application_1/model/model.dart';
import 'package:flutter_application_1/online.dart';
import 'package:flutter_application_1/request/apiRoom.dart';
import 'package:flutter_application_1/request/saveLogin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'CaroGame.dart';
import 'AI caro/caro_offline.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:rive/rive.dart' as rive;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      '/login': (context) => const loginScreen(),
      '/register': (context) => registerScreen(),
    },
    home: const HomeScreen(),
  ));
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

  String selectedIndex = 'assets/images/av1.png';
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
          // Hai nút với màu khác nhau
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
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
                                shadowColor:
                                    Colors.transparent, // Bỏ hiệu ứng bóng
                              ),
                              onPressed: () {
                                // Navigator.pop(
                                //     context); // Quay lại màn hình trước đó
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
                    const SizedBox(height: 25),
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
                                shadowColor:
                                    Colors.transparent, // Bỏ hiệu ứng bóng
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlayOnlineScreen(
                                      avatar: selectedIndex,
                                    ),
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
                    const SizedBox(height: 25),
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
                                shadowColor:
                                    Colors.transparent, // Bỏ hiệu ứng bóng
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
                    const SizedBox(height: 25),
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
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    child: Container(
                      color: const Color.fromARGB(255, 160, 87, 39),
                      height: 50,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                    child: Text(
                      'SELECT YOUR AVATAR',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 28,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex =
                            'assets/images/av1.png'; // Gán chỉ số nút được chọn
                      });
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: selectedIndex == 'assets/images/av1.png'
                            ? Border.all(
                                color: const Color.fromARGB(255, 47, 240, 175),
                                width: 5) // Tô viền màu xanh
                            : null, // Không viền nếu không được chọn
                        image: const DecorationImage(
                          image: AssetImage('assets/images/av1.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex =
                            'assets/images/av2.png'; // Gán chỉ số nút được chọn
                      });
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: selectedIndex == 'assets/images/av2.png'
                            ? Border.all(
                                color: const Color.fromARGB(255, 47, 240, 175),
                                width: 5)
                            : null,
                        image: const DecorationImage(
                          image: AssetImage('assets/images/av2.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex =
                            'assets/images/av3.png'; // Gán chỉ số nút được chọn
                      });
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: selectedIndex == 'assets/images/av3.png'
                            ? Border.all(
                                color: const Color.fromARGB(255, 47, 240, 175),
                                width: 5)
                            : null,
                        image: const DecorationImage(
                          image: AssetImage('assets/images/av3.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 22,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex =
                            'assets/images/av4.png'; // Gán chỉ số nút được chọn
                      });
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: selectedIndex == 'assets/images/av4.png'
                            ? Border.all(
                                color: const Color.fromARGB(255, 47, 240, 175),
                                width: 5)
                            : null,
                        image: const DecorationImage(
                          image: AssetImage('assets/images/av4.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex =
                            'assets/images/av5.png'; // Gán chỉ số nút được chọn
                      });
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: selectedIndex == 'assets/images/av5.png'
                            ? Border.all(
                                color: const Color.fromARGB(255, 47, 240, 175),
                                width: 5)
                            : null,
                        image: const DecorationImage(
                          image: AssetImage('assets/images/av5.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex =
                            'assets/images/av6.png'; // Gán chỉ số nút được chọn
                      });
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: selectedIndex == 'assets/images/av6.png'
                            ? Border.all(
                                color: const Color.fromARGB(255, 47, 240, 175),
                                width: 5)
                            : null,
                        image: const DecorationImage(
                          image: AssetImage('assets/images/av6.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Thêm màn hình "Play Online"
class PlayOnlineScreen extends StatelessWidget {
  final List<Map<String, dynamic>> _rankList = [
    {'username': 'UserA', 'score': 10},
    {'username': 'UserB', 'score': 9},
    {'username': 'UserC', 'score': 8},
    {'username': 'UserC', 'score': 7},
    {'username': 'UserC', 'score': 6},
    {'username': 'UserE', 'score': 5},
    {'username': 'UserA', 'score': 4},
    {'username': 'UserB', 'score': 3},
    {'username': 'UserC', 'score': 2},
    {'username': 'UserC', 'score': 1},
    {'username': 'UserC', 'score': 0},
    {'username': 'UserE', 'score': 900},
  ];
  final String avatar;
  PlayOnlineScreen({super.key, required this.avatar});

  Future<List<Room>> callLoadRooms() async {
    final dataFetcher = DataRoom();
    return await dataFetcher.loadRooms();
  }

  final TextEditingController idRoom = TextEditingController();

  String privateIdRoom() {
    final random = Random();
    String letters = '';
    String numbers = '';

    // Tạo 3 chữ cái viết hoa
    for (int i = 0; i < 3; i++) {
      letters += String.fromCharCode(
          random.nextInt(26) + 65); // 65 là mã ASCII của 'A'
    }

    // Tạo 3 số
    for (int i = 0; i < 3; i++) {
      numbers += random.nextInt(10).toString();
    }

    return letters + numbers;
  }

  // Hàm hiển thị Modal Bottom Sheet
  void _showRankList(BuildContext context) {
    // Lấy tối đa 11 phần tử từ danh sách
    final sortedRankList = List<Map<String, dynamic>>.from(_rankList)
      ..sort((a, b) => b['score'].compareTo(a['score']));
    final limitedRankList = sortedRankList.take(11).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Danh sách Rank',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: limitedRankList.length,
                itemBuilder: (context, index) {
                  final rank = limitedRankList[index];
                  return Column(
                    children: [
                      if (index == 10 && rank['username'] == 'test')
                        const Divider(thickness: 2), // Dấu kẻ ở giữa
                      rank['username'] == 'test'
                          ? Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text((2).toString()),
                                ),
                                title: Text(rank['username']),
                                subtitle: Text('Score: ${rank['score']}'),
                              ),
                            )
                          : Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text((index + 1).toString()),
                                ),
                                title: Text(rank['username']),
                                subtitle: Text('Score: ${rank['score']}'),
                              ),
                            ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController idRoom = TextEditingController();
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      body: FutureBuilder(
        future: callLoadRooms(),
        builder: (context, snapshot) {
          // Kiểm tra trạng thái kết nối
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AnimatedBackgroundLoader();
          } else if (snapshot.data == null) {
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
                            .spaceAround, // Đặt khoảng cách đều
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
                          SizedBox(
                            height: 60,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _showRankList(context),
                                  child: Container(
                                    height: 60,
                                    width: 60,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/rank.jpg'),
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

                      const SizedBox(
                        height: 280,
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
                                      horizontal: 20), // Thêm padding bên trong
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
                                      image:
                                          AssetImage('assets/images/btn.png'),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      final joinRoomId = idRoom.text;
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CaroGameScreen(
                                              roomId: joinRoomId,
                                              avatar: avatar,
                                            ),
                                          ));
                                    },
                                    child: const Text(
                                      "ENTER",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
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
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    "CREATE ROOM",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ),
                                )),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 150,
                                  width: 300,
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
                                                  decoration:
                                                      const BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          'assets/images/khung.png'),
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        32.0), // Thêm padding cho hai bên
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                // Hành động khi nhấn vào Container
                                                                Navigator.pop(
                                                                    context);

                                                                // Hoặc điều hướng, logic khác ở đây
                                                              },
                                                              child: Container(
                                                                height: 35,
                                                                width: 70,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  image:
                                                                      DecorationImage(
                                                                    image: AssetImage(
                                                                        'assets/images/btn_back.png'),
                                                                    fit: BoxFit
                                                                        .fitHeight,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () async {
                                                              // Gọi API để tạo phòng và lấy roomId
                                                              final newRoomId =
                                                                  await DataRoom()
                                                                      .createRoom(
                                                                'roomName',
                                                                'roomType',
                                                                "test11@gmail.com",
                                                                10,
                                                              );

                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          CaroGameScreen(
                                                                    roomId:
                                                                        newRoomId,
                                                                    avatar:
                                                                        avatar,
                                                                  ),
                                                                ),
                                                              ).then(
                                                                  (result) async {
                                                                if (result !=
                                                                    null) {
                                                                  // Có dữ liệu trả về
                                                                }
                                                                // Xóa phòng sau khi quay lại từ CaroGameScreen
                                                                final deleteResult =
                                                                    await DataRoom()
                                                                        .deleteRoom(
                                                                            newRoomId);
                                                                print(
                                                                    deleteResult);
                                                              });
                                                            },
                                                            child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              height: 70,
                                                              width: 100,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image: AssetImage(
                                                                      'assets/images/btn.png'),
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                              ),
                                                              child: const Text(
                                                                "Public",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromARGB(
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
                                                                    builder:
                                                                        (context) =>
                                                                            CaroGameScreen(
                                                                      roomId:
                                                                          privateIdRoom(),
                                                                      avatar:
                                                                          avatar,
                                                                    ),
                                                                  ));
                                                            },
                                                            child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              height: 70,
                                                              width: 100,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image: AssetImage(
                                                                      'assets/images/btn.png'),
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                              ),
                                                              child: const Text(
                                                                "Private",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromARGB(
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
                                                      const SizedBox(
                                                        height: 40,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: const SizedBox(
                                          height: 120,
                                          width: 260,
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
              ),
            );
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
                        child: Scrollbar(
                          thumbVisibility: true, // Hiển thị thanh cuộn
                          controller:
                              scrollController, // Liên kết với ScrollController
                          child: GridView.builder(
                            controller:
                                scrollController, // Liên kết ScrollController với GridView
                            padding: const EdgeInsets.symmetric(
                                horizontal: 1, vertical: 16),
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
                                avatar,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 280,
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
                                      horizontal: 20), // Thêm padding bên trong
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
                                      image:
                                          AssetImage('assets/images/btn.png'),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      final joinRoomId = idRoom.text;
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CaroGameScreen(
                                              roomId: joinRoomId,
                                              avatar: avatar,
                                            ),
                                          ));
                                    },
                                    child: const Text(
                                      "ENTER",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
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
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    "CREATE ROOM",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ),
                                )),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 150,
                                  width: 300,
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
                                                  decoration:
                                                      const BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          'assets/images/khung.png'),
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        32.0), // Thêm padding cho hai bên
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                // Hành động khi nhấn vào Container
                                                                Navigator.pop(
                                                                    context);

                                                                // Hoặc điều hướng, logic khác ở đây
                                                              },
                                                              child: Container(
                                                                height: 35,
                                                                width: 70,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  image:
                                                                      DecorationImage(
                                                                    image: AssetImage(
                                                                        'assets/images/btn_back.png'),
                                                                    fit: BoxFit
                                                                        .fitHeight,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () async {
                                                              // Gọi API để tạo phòng và lấy roomId
                                                              final newRoomId =
                                                                  await DataRoom()
                                                                      .createRoom(
                                                                'roomName',
                                                                'roomType',
                                                                "test11@gmail.com",
                                                                10,
                                                              );

                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          CaroGameScreen(
                                                                    roomId:
                                                                        newRoomId,
                                                                    avatar:
                                                                        avatar,
                                                                  ),
                                                                ),
                                                              ).then(
                                                                  (result) async {
                                                                if (result !=
                                                                    null) {
                                                                  // Có dữ liệu trả về
                                                                }
                                                                // Xóa phòng sau khi quay lại từ CaroGameScreen
                                                                final deleteResult =
                                                                    await DataRoom()
                                                                        .deleteRoom(
                                                                            newRoomId);
                                                                print(
                                                                    deleteResult);
                                                              });
                                                            },
                                                            child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              height: 70,
                                                              width: 100,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image: AssetImage(
                                                                      'assets/images/btn.png'),
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                              ),
                                                              child: const Text(
                                                                "Public",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromARGB(
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
                                                                    builder:
                                                                        (context) =>
                                                                            CaroGameScreen(
                                                                      roomId:
                                                                          privateIdRoom(),
                                                                      avatar:
                                                                          avatar,
                                                                    ),
                                                                  ));
                                                            },
                                                            child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              height: 70,
                                                              width: 100,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image: AssetImage(
                                                                      'assets/images/btn.png'),
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                              ),
                                                              child: const Text(
                                                                "Private",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromARGB(
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
                                                      const SizedBox(
                                                        height: 40,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: const SizedBox(
                                          height: 120,
                                          width: 260,
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
    int currentPlayers, int maxPlayers, String roomId, String avatar) {
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
                                                CaroGameScreen(
                                              roomId: roomId,
                                              avatar: avatar,
                                            ),
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
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) =>
                                //         CaroGameScreen(roomId: newRoomId, avatar: av,),
                                //   ),
                                // ).then((result) async {
                                //   if (result != null) {
                                //     // Có dữ liệu trả về
                                //   }
                                //   // Xóa phòng sau khi quay lại từ CaroGameScreen
                                //   final deleteResult =
                                //       await DataRoom().deleteRoom(newRoomId);
                                //   print(deleteResult);
                                // });
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
