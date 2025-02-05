import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/CaroGame.dart';
import 'package:flutter_application_1/UI/AudioService.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/UI/register.dart';
import 'package:flutter_application_1/model/model.dart';
import 'package:flutter_application_1/online.dart';
import 'package:flutter_application_1/request/apiRank.dart';
import 'package:flutter_application_1/request/apiRoom.dart';
import 'package:flutter_application_1/request/saveLogin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'CaroGame.dart';
import 'AI caro/caro_offline.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:rive/rive.dart' as rive;

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      '/login': (context) => const loginScreen(),
      '/register': (context) => const registerScreen(),
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
  //late AudioPlayer _audioPlayer; // Khởi tạo biến AudioPlayer
  bool showImage = false; // Biến trạng thái để kiểm soát hiển thị hình ảnh

  @override
  void initState() {
    super.initState();
    playRandomMusic();
    _startTransition();
  }

  Future<void> playRandomMusic() async {
    final List<String> audioPaths = [
      'assets/audio/stg1.mp3',
      'assets/audio/stg2.mp3',
      'assets/audio/stg3.mp3',
      'assets/audio/stg4.mp3',
      'assets/audio/stg5.mp3',
      'assets/audio/stg6.mp3',
      'assets/audio/stg7.mp3',
      'assets/audio/str1.mp3',
      'assets/audio/str2.mp3',
    ];

    // Chọn ngẫu nhiên một bài hát
    final randomIndex = Random().nextInt(audioPaths.length);
    final randomTrack = audioPaths[randomIndex];

    // Dừng nhạc đang phát
    await AudioManager().stop();

    // Tải và phát nhạc mới
    await AudioManager().load(randomTrack);
    await AudioManager().play();

    // Lắng nghe sự kiện khi bài hát kết thúc (chỉ nên đăng ký một lần)
    AudioManager().audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        playRandomMusic(); // Phát bài tiếp theo
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
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
    addRanksToList();
  }

  Map<String, dynamic>? rankUser;
  late Map<String, dynamic> userName;
  final List<Map<String, dynamic>> _rankList = [
    {'username': 'tuansa', 'score': 125},
    {'username': 'hahn', 'score': 75},
    {'username': 'haics', 'score': 55},
    {'username': 'anhdz', 'score': 40},
  ];
  final List<Map<String, dynamic>> list10 = [];
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

  Future<void> addRanksToList() async {
    try {
      // Lấy dữ liệu từ API
      final dataRank = DataRank();
      List<Rank> ranks = await dataRank.loadRanks();
      userName = await saveLogin().getUserData();

      // Chuyển đổi Rank thành Map<String, dynamic>
      final List<Map<String, dynamic>> newRanks = ranks.map((rank) {
        return {
          'username': rank.username,
          'score': rank.score,
        };
      }).toList();
      _rankList.addAll(newRanks);
    } catch (e) {
      print('Lỗi khi thêm dữ liệu: $e');
    }
  }

  // Hàm hiển thị Modal Bottom Sheet
  void _showRankList(BuildContext context) {
    // Lấy tối đa 11 phần tử từ danh sách
    final sortedRankList = List<Map<String, dynamic>>.from(_rankList)
      ..sort((a, b) => b['score'].compareTo(a['score']));
    for (var i = 0; i < sortedRankList.length; i++) {
      if (sortedRankList[i]['username'] == userName['username']) {
        rankUser = {
          'rank': i,
          'username': sortedRankList[i]['username'],
          'score': sortedRankList[i]['score']
        };
      }
    }
    final limitedRankList = sortedRankList.take(10).toList();
    if (rankUser != null) {
      limitedRankList.add(rankUser!);
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleDialog(
          rankList: limitedRankList,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.8;
        const end = 1.0;
        const curve = Curves.easeOutBack;
        final tween = Tween<double>(begin: begin, end: end)
            .chain(CurveTween(curve: curve));
        final scaleAnimation = animation.drive(tween);

        return ScaleTransition(
          scale: scaleAnimation,
          child: child,
        );
      },
    );
  }

  String selectedIndex = 'assets/images/av1.png';
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
                            height: screenWidth > 500
                                ? screenHeight * 0.135
                                : screenHeight * 0.12,
                            width: screenWidth > 500
                                ? screenWidth * 0.6
                                : screenWidth * 0.7,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/btn.png'),
                                fit: BoxFit.fitHeight,
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
                              child: Text(
                                'Caro Challenge',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth > 500
                                      ? screenWidth * 0.05
                                      : screenWidth * 0.06,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.012),
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: screenWidth > 500
                                ? screenHeight * 0.115
                                : screenHeight * 0.10,
                            width: screenWidth > 500
                                ? screenWidth * 0.6
                                : screenWidth * 0.7,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/btn.png'),
                                fit: BoxFit.fitHeight,
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
                              child: Text(
                                'Play Online',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth > 500
                                      ? screenWidth * 0.04
                                      : screenWidth * 0.055,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.012),
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: screenWidth > 500
                                ? screenHeight * 0.115
                                : screenHeight * 0.10,
                            width: screenWidth > 500
                                ? screenWidth * 0.6
                                : screenWidth * 0.7,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/btn.png'),
                                fit: BoxFit.fitHeight,
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
                                    builder: (context) =>
                                        CaroGame(selectedIndex: selectedIndex),
                                  ),
                                );
                              },
                              child: Text(
                                'Play Offline',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth > 500
                                      ? screenWidth * 0.04
                                      : screenWidth * 0.055,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.012),
                    SizedBox(
                      height: screenWidth > 500
                          ? screenHeight * 0.115
                          : screenHeight * 0.10,
                      width: screenWidth > 500
                          ? screenWidth * 0.6
                          : screenWidth * 0.7,
                      child: GestureDetector(
                          onTap: () => _showRankList(context),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: screenWidth > 500
                                    ? screenHeight * 0.115
                                    : screenHeight * 0.10,
                                width: screenWidth > 500
                                    ? screenWidth * 0.6
                                    : screenWidth * 0.7,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/btn.png'),
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ),
                              Text(
                                'Rank',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth > 500
                                      ? screenWidth * 0.04
                                      : screenWidth * 0.055,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )),
                    ),
                    SizedBox(height: screenHeight * 0.012),
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceEvenly, // Các phần tử cách đều nhau
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Đóng ứng dụng
                            if (Platform.isAndroid || Platform.isIOS) {
                              SystemNavigator.pop(); // Dùng cho Android và iOS
                            } else {
                              exit(0); // Dùng cho các nền tảng khác
                            }
                          },
                          child: Container(
                            height: screenWidth > 500
                                ? screenHeight * 0.08
                                : screenHeight * 0.08,
                            width: screenWidth > 500
                                ? screenWidth * 0.1
                                : screenWidth * 0.153,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/btn_how.png'),
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const loginScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                            saveLogin().logout();
                          },
                          child: Container(
                            height: screenWidth > 500
                                ? screenHeight * 0.08
                                : screenHeight * 0.08,
                            width: screenWidth > 500
                                ? screenWidth * 0.1
                                : screenWidth * 0.153,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/btn_home.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (isMuted) {
                              // Nếu đang tắt, bật lại nhạc với âm lượng 1.0
                              await AudioManager().audioPlayer.setVolume(1.0);
                              await AudioManager().audioPlayer.play();
                            } else {
                              // Nếu đang bật, tắt nhạc (giảm âm lượng về 0)
                              await AudioManager().audioPlayer.setVolume(0.0);
                              await AudioManager().audioPlayer.stop();
                            }
                            setState(() {
                              isMuted = !isMuted; // Đảo trạng thái
                            });
                            print("Audio ${isMuted ? 'muted' : 'unmuted'}");
                          },
                          child: Container(
                            height: screenWidth > 500
                                ? screenHeight * 0.08
                                : screenHeight * 0.08,
                            width: screenWidth > 500
                                ? screenWidth * 0.1
                                : screenWidth * 0.153,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(isMuted
                                    ? 'assets/images/btn_audio_off.png'
                                    : 'assets/images/btn_audio.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    child: Container(
                      color: const Color.fromARGB(255, 160, 87, 39),
                      height: screenWidth > 500
                          ? screenHeight * 0.055
                          : screenHeight * 0.055,
                    ),
                  ),
                  SizedBox(
                    height: screenWidth > 500
                        ? screenHeight * 0.044
                        : screenHeight * 0.04,
                    child: Text(
                      'SELECT YOUR AVATAR',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: screenWidth > 500
                            ? screenWidth * 0.04
                            : screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
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
                      height: screenWidth > 500
                          ? screenHeight * 0.08
                          : screenHeight * 0.11,
                      width: screenWidth > 500
                          ? screenWidth * 0.1
                          : screenWidth * 0.2,
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
                      height: screenWidth > 500
                          ? screenHeight * 0.08
                          : screenHeight * 0.11,
                      width: screenWidth > 500
                          ? screenWidth * 0.1
                          : screenWidth * 0.2,
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
                      height: screenWidth > 500
                          ? screenHeight * 0.08
                          : screenHeight * 0.11,
                      width: screenWidth > 500
                          ? screenWidth * 0.1
                          : screenWidth * 0.2,
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
              SizedBox(height: screenHeight * 0.01),
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
                      height: screenWidth > 500
                          ? screenHeight * 0.08
                          : screenHeight * 0.11,
                      width: screenWidth > 500
                          ? screenWidth * 0.1
                          : screenWidth * 0.2,
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
                      height: screenWidth > 500
                          ? screenHeight * 0.08
                          : screenHeight * 0.11,
                      width: screenWidth > 500
                          ? screenWidth * 0.1
                          : screenWidth * 0.2,
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
                      height: screenWidth > 500
                          ? screenHeight * 0.08
                          : screenHeight * 0.11,
                      width: screenWidth > 500
                          ? screenWidth * 0.1
                          : screenWidth * 0.2,
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
class PlayOnlineScreen extends StatefulWidget {
  final String avatar;
  const PlayOnlineScreen({super.key, required this.avatar});

  @override
  State<PlayOnlineScreen> createState() => _PlayOnlineScreenState();
}

class _PlayOnlineScreenState extends State<PlayOnlineScreen> {
  late Future<List<Room>> _futureRooms;
  @override
  void initState() {
    super.initState();
    _futureRooms = callLoadRooms();
    addRanksToList();
  }

  Map<String, dynamic>? rankUser;
  late Map<String, dynamic> userName;
  final List<Map<String, dynamic>> rankList = [
    {'username': 'tuansa', 'score': 125},
    {'username': 'hahn', 'score': 75},
    {'username': 'haics', 'score': 55},
    {'username': 'anhdz', 'score': 40},
  ];
  final List<Map<String, dynamic>> list10 = [];
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

  Future<void> addRanksToList() async {
    try {
      // Lấy dữ liệu từ API
      final dataRank = DataRank();
      List<Rank> ranks = await dataRank.loadRanks();
      userName = await saveLogin().getUserData();

      // Chuyển đổi Rank thành Map<String, dynamic>
      final List<Map<String, dynamic>> newRanks = ranks.map((rank) {
        return {
          'username': rank.username,
          'score': rank.score,
        };
      }).toList();
      rankList.addAll(newRanks);
    } catch (e) {
      print('Lỗi khi thêm dữ liệu: $e');
    }
  }

  // Hàm hiển thị Modal Bottom Sheet

  @override
  Widget build(BuildContext context) {
    final TextEditingController idRoom = TextEditingController();
    final ScrollController scrollController = ScrollController();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: FutureBuilder(
        future: _futureRooms,
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
                                    height: screenWidth > 500
                                        ? screenHeight * 0.1
                                        : screenHeight * 0.05,
                                    width: screenWidth > 500
                                        ? screenWidth * 0.23
                                        : screenWidth * 0.2,
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
                                height: screenWidth > 500
                                    ? screenHeight * 0.12
                                    : screenHeight * 0.12,
                                width: screenWidth > 500
                                    ? screenWidth * 0.35
                                    : screenWidth * 0.5,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image:
                                        AssetImage('assets/images/khung.png'),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              Text(
                                "Play Online",
                                style: TextStyle(
                                  fontSize: screenWidth > 500
                                      ? screenWidth * 0.05
                                      : screenWidth * 0.06,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: screenWidth > 500
                                ? screenHeight * 0.1
                                : screenHeight * 0.05,
                            width: screenWidth > 500
                                ? screenWidth * 0.13
                                : screenWidth * 0.13,
                          ),
                          const SizedBox(
                            height: 60,
                          ),
                        ],
                      ),

                      // Hộp tiêu đề "Play Online"
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
                      Row(
                        children: [
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              height: screenWidth > 500
                                  ? screenHeight * 0.06
                                  : screenHeight * 0.07,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(
                                    255, 148, 74, 21), // Màu nền nâu nhạt (tan)
                                borderRadius:
                                    BorderRadius.circular(20), // Bo góc khung
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
                                decoration: InputDecoration(
                                  labelText: "ID Room",
                                  labelStyle: TextStyle(
                                    fontSize: screenWidth > 500
                                        ? screenWidth * 0.03
                                        : screenWidth * 0.03,
                                    color: const Color.fromARGB(255, 255, 255,
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
                              height: screenWidth > 500
                                  ? screenHeight * 0.07
                                  : screenHeight * 0.08,
                              width: screenWidth > 500
                                  ? screenWidth * 0.2
                                  : screenWidth * 0.2,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/btn.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  final joinRoomId = idRoom.text;
                                  if (joinRoomId.isNotEmpty) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CaroGameScreen(
                                            roomId: joinRoomId,
                                            avatar: widget.avatar,
                                          ),
                                        ));
                                  }
                                },
                                child: Text(
                                  "ENTER",
                                  style: TextStyle(
                                    fontSize: screenWidth > 500
                                        ? screenWidth * 0.03
                                        : screenWidth * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                  ),
                                ),
                              )),
                          const SizedBox(width: 20),
                        ],
                      ),

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
                        SizedBox(
                          height: screenWidth > 500
                              ? screenHeight * 0.85
                              : screenHeight * 0.82,
                        ),
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
                          width: screenWidth > 500
                              ? screenWidth * 0.9
                              : screenWidth * 0.9,
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                                alignment: Alignment.center,
                                height: screenWidth > 500
                                    ? screenHeight * 0.1
                                    : screenHeight * 0.13,
                                width: screenWidth > 500
                                    ? screenWidth * 0.4
                                    : screenWidth * 0.9,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/btn.png'),
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                                child: SizedBox(
                                  height: screenWidth > 500
                                      ? screenHeight * 0.1
                                      : screenHeight * 0.11,
                                  width: screenWidth > 500
                                      ? screenWidth * 0.4
                                      : screenWidth * 0.6,
                                  child: TextButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            alignment: Alignment.center,
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    0, 255, 255, 255),
                                            content: Container(
                                              height: screenWidth > 500
                                                  ? screenHeight * 0.22
                                                  : screenHeight * 0.28,
                                              width: screenWidth > 500
                                                  ? screenWidth * 0.4
                                                  : screenWidth * 0.9,
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
                                                  Row(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal:
                                                                32.0), // Thêm padding cho hai bên
                                                        child: GestureDetector(
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
                                                  const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Choose type room",
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.015,
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
                                                              builder: (context) =>
                                                                  CaroGameScreen(
                                                                roomId:
                                                                    newRoomId,
                                                                avatar: widget
                                                                    .avatar,
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
                                                            print(deleteResult);
                                                          });
                                                        },
                                                        child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          height: 70,
                                                          width: 100,
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
                                                            "Public",
                                                            style: TextStyle(
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
                                                                  avatar: widget
                                                                      .avatar,
                                                                ),
                                                              ));
                                                        },
                                                        child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          height: 70,
                                                          width: 100,
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
                                                            "Private",
                                                            style: TextStyle(
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
                                    child: const Text(
                                      "CREATE ROOM",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ),
                                  ),
                                )),
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
                                    height: screenWidth > 500
                                        ? screenHeight * 0.1
                                        : screenHeight * 0.05,
                                    width: screenWidth > 500
                                        ? screenWidth * 0.13
                                        : screenWidth * 0.2,
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
                                height: screenWidth > 500
                                    ? screenHeight * 0.12
                                    : screenHeight * 0.1,
                                width: screenWidth > 500
                                    ? screenWidth * 0.4
                                    : screenWidth * 0.4,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image:
                                        AssetImage('assets/images/khung.png'),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              Text(
                                "Play Online",
                                style: TextStyle(
                                  fontSize: screenWidth > 500
                                      ? screenWidth * 0.04
                                      : screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: screenWidth > 500
                                ? screenWidth * 0.1
                                : screenWidth * 0.13,
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
                      Row(
                        children: [
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              height: screenWidth > 500
                                  ? screenHeight * 0.06
                                  : screenHeight * 0.07,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(
                                    255, 148, 74, 21), // Màu nền nâu nhạt (tan)
                                borderRadius:
                                    BorderRadius.circular(20), // Bo góc khung
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
                                decoration: InputDecoration(
                                  labelText: "ID Room",
                                  labelStyle: TextStyle(
                                    fontSize: screenWidth > 500
                                        ? screenWidth * 0.03
                                        : screenWidth * 0.03,
                                    color: const Color.fromARGB(255, 255, 255,
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
                              height: screenWidth > 500
                                  ? screenHeight * 0.07
                                  : screenHeight * 0.08,
                              width: screenWidth > 500
                                  ? screenWidth * 0.2
                                  : screenWidth * 0.2,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/btn.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  final joinRoomId = idRoom.text;
                                  if (joinRoomId.isNotEmpty) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CaroGameScreen(
                                            roomId: joinRoomId,
                                            avatar: widget.avatar,
                                          ),
                                        ));
                                  }
                                },
                                child: Text(
                                  "ENTER",
                                  style: TextStyle(
                                    fontSize: screenWidth > 500
                                        ? screenWidth * 0.03
                                        : screenWidth * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                  ),
                                ),
                              )),
                          const SizedBox(width: 20),
                        ],
                      ),
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
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: screenWidth > 500
                                  ? 4
                                  : 2, // Số container mỗi hàng
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
                                widget.avatar,
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenWidth > 500
                            ? screenHeight * 0.05
                            : screenHeight * 0.1,
                      ),
                    ],
                  ),
                  // Thanh ngang cố định ở phía dưới
                  Column(
                    children: [
                      SizedBox(
                        height: screenWidth > 500
                            ? screenHeight * 0.85
                            : screenHeight * 0.82,
                      ),
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
                        width: screenWidth > 500
                            ? screenWidth * 0.9
                            : screenWidth * 0.9,
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                              alignment: Alignment.center,
                              height: screenWidth > 500
                                  ? screenHeight * 0.1
                                  : screenHeight * 0.13,
                              width: screenWidth > 500
                                  ? screenWidth * 0.4
                                  : screenWidth * 0.9,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/btn.png'),
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                              child: SizedBox(
                                height: screenWidth > 500
                                    ? screenHeight * 0.1
                                    : screenHeight * 0.11,
                                width: screenWidth > 500
                                    ? screenWidth * 0.4
                                    : screenWidth * 0.6,
                                child: TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          alignment: Alignment.center,
                                          backgroundColor: const Color.fromARGB(
                                              0, 255, 255, 255),
                                          content: Container(
                                            height: screenWidth > 500
                                                ? screenHeight * 0.22
                                                : screenHeight * 0.28,
                                            width: screenWidth > 500
                                                ? screenWidth * 0.4
                                                : screenWidth * 0.9,
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
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal:
                                                              32.0), // Thêm padding cho hai bên
                                                      child: GestureDetector(
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
                                                const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Choose type room",
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color.fromARGB(
                                                            255, 255, 255, 255),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.015,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
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
                                                            builder: (context) =>
                                                                CaroGameScreen(
                                                              roomId: newRoomId,
                                                              avatar:
                                                                  widget.avatar,
                                                            ),
                                                          ),
                                                        ).then((result) async {
                                                          if (result != null) {
                                                            // Có dữ liệu trả về
                                                          }
                                                          // Xóa phòng sau khi quay lại từ CaroGameScreen
                                                          final deleteResult =
                                                              await DataRoom()
                                                                  .deleteRoom(
                                                                      newRoomId);
                                                          print(deleteResult);
                                                        });
                                                      },
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        height: 70,
                                                        width: 100,
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
                                                          "Public",
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
                                                    const SizedBox(
                                                      width: 30,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  CaroGameScreen(
                                                                roomId:
                                                                    privateIdRoom(),
                                                                avatar: widget
                                                                    .avatar,
                                                              ),
                                                            ));
                                                      },
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        height: 70,
                                                        width: 100,
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
                                                          "Private",
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
                                  child: const Text(
                                    "CREATE ROOM",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
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
                                        DataRoom().deleteRoom(roomId);
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
  final List<String> loadingImages = [
    'assets/images/loading/6.png',
    'assets/images/loading/5.png',
    'assets/images/loading/4.png',
    'assets/images/loading/3.png',
    'assets/images/loading/2.png',
    'assets/images/loading/1.png',
  ];
  int currentImageIndex = 0;
  int nextImageIndex = 1;
  bool isFirstImageDisplayed = true; // Cờ để xác định ảnh đầu tiên
  late AnimationController animationController;
  late Animation<double> opacityAnimation;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    opacityAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(animationController);

    startImageRotation();
  }

  void startImageRotation() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (isFirstImageDisplayed) {
        // Bỏ qua hiệu ứng cho ảnh đầu tiên
        setState(() {
          isFirstImageDisplayed = false;
        });
        return;
      }

      await animationController.forward(); // Hiệu ứng mờ dần
      setState(() {
        currentImageIndex = nextImageIndex;
        nextImageIndex = (nextImageIndex + 1) % loadingImages.length;
      });
      animationController.reset(); // Reset để chuẩn bị cho lần tiếp theo
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ảnh hiện tại
        flutter.Image.asset(
          loadingImages[currentImageIndex],
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        // Hiệu ứng fade chỉ áp dụng từ ảnh thứ hai trở đi
        if (!isFirstImageDisplayed)
          FadeTransition(
            opacity: opacityAnimation,
            child: flutter.Image.asset(
              loadingImages[nextImageIndex],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
      ],
    );
  }
}

class ScaleDialog extends StatefulWidget {
  final List<Map<String, dynamic>> rankList;

  const ScaleDialog({super.key, required this.rankList});

  @override
  _ScaleDialogState createState() => _ScaleDialogState();
}

class _ScaleDialogState extends State<ScaleDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    scaleAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
    );
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true, // Điều chỉnh kích thước text tự động
        splitScreenMode: true,
        builder: (context, child) {
          return ScaleTransition(
            scale: scaleAnimation,
            child: Container(
              margin: EdgeInsets.only(
                  top: 30.h,
                  bottom: 30.h,
                  left: 30.w,
                  right: 30.w), // Thêm khoảng cách lùi vào toàn bộ các cạnh
              padding: EdgeInsets.only(
                  top: 50.h, bottom: 50.h, left: 30.w, right: 30.w),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/21.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                    top: 16.h, bottom: 16.h, left: 16.h, right: 16.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 85.h),
                    SizedBox(
                      height: screenHeight < 700 ? 420.h : 470.h,
                      width: 450.w,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(), // Không cho phép cuộn của ListView riêng biệt
                              itemCount: widget.rankList.length,
                              itemBuilder: (context, index) {
                                final rank = widget.rankList[index];
                                return Column(
                                  children: [
                                    if (index < 10)
                                      Card(
                                        color: Colors.transparent,
                                        elevation: 0,
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              left: 30.w, right: 30.w),
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/22.png'),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              child:
                                                  Text((index + 1).toString()),
                                            ),
                                            title: Text(rank['username']),
                                            subtitle:
                                                Text('Score: ${rank['score']}'),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      thickness: 5,
                      color: Colors.green,
                    ),
                    Stack(
                      children: [
                        Positioned(
                          child: Card(
                            color: Colors.transparent,
                            elevation: 0,
                            child: Container(
                              padding: EdgeInsets.only(left: 30.w, right: 30.w),
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/22.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: widget.rankList.length > 10
                                  ? ListTile(
                                      leading: CircleAvatar(
                                        child: Text(
                                            (widget.rankList[10]['rank'] + 1)
                                                .toString()),
                                      ),
                                      title:
                                          Text(widget.rankList[10]['username']),
                                      subtitle: Text(
                                          'Score: ${widget.rankList[10]['score']}'),
                                    )
                                  : const ListTile(
                                      leading: CircleAvatar(
                                        child: Text('---'),
                                      ),
                                      title: Text('---'),
                                      subtitle: Text('Score: ---'),
                                    ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
