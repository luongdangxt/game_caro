import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/CaroGame.dart';
import 'package:flutter_application_1/UI/AudioService.dart';
import 'package:flutter_application_1/chatonline.dart';
import 'package:flutter_application_1/request/apiRank.dart';
import 'package:flutter_application_1/request/saveLogin.dart';
import 'package:flutter_application_1/setup_sence.dart';
import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:just_audio/just_audio.dart' as just_audio;

class CaroGameScreen extends StatefulWidget {
  final String roomId;
  final String avatar;
  const CaroGameScreen({super.key, required this.roomId, required this.avatar});

  @override
  _CaroGameScreenState createState() => _CaroGameScreenState();
}

class _CaroGameScreenState extends State<CaroGameScreen> {
  String? nameUser; // Khởi tạo giá trị mặc định
  bool isBlinking = false; // Trạng thái nhấp nháy

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

  Future<void> playRandomMusic() async {
    final List<String> audioPaths = [
      'assets/audio/stg1.mp3',
      'assets/audio/stg2.mp3',
      'assets/audio/stg3.mp3',
      'assets/audio/stg4.mp3',
      'assets/audio/stg5.mp3',
      'assets/audio/stg6.mp3',
      'assets/audio/stg7.mp3',
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
  void initState() {
    super.initState();
    playRandomMusic();
    // Nếu cần hiệu ứng nhấp nháy, chạy Timer để thay đổi trạng thái liên tục
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        isBlinking = !isBlinking; // Đổi trạng thái nhấp nháy
        timer.cancel();
      });
    });

    statusMessage = 'ROOM ID: ${widget.roomId}';
    getInfoLogin().then((_) {
      joinRoom(); // Chỉ gọi joinRoom sau khi getInfoLogin hoàn tất
    });
    cells = List.filled(boardSize * boardSize, '');
    channel.stream.listen((message) {
      final data = jsonDecode(message);
      setState(() {
        DataRank dataRank = DataRank();
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

          _playerRight();
        } else if (data['type'] == 'game-over') {
          print('game-over');
          if (data['message'] == 'X wins!') {
            statusMessage = data['message'];
            indexWin = List<int>.from(data['payload']); // Lưu các ô thắng
            if (mySymbol == 'X') {
              Future.delayed(Duration(milliseconds: winningCells.length * 5000),
                  () async {
                try {
                  await _audioPlayer.setAsset('assets/audio/win.wav');
                  await _audioPlayer.play();
                } catch (e) {
                  print('Error playing audio: $e');
                }
                showVictoryDialog('10');
                dataRank.updateScore(nameUser!, 10);
              });
            } else {
              Future.delayed(Duration(milliseconds: winningCells.length * 5000),
                  () async {
                try {
                  await _audioPlayer.setAsset('assets/audio/lose.wav');
                  await _audioPlayer.play();
                } catch (e) {
                  print('Error playing audio: $e');
                }
                showLoseDialog('-5');
              });
              dataRank.updateScore(nameUser!, -5);
            }
          } else if (data['message'] == 'O wins!') {
            statusMessage = data['message'];
            indexWin = List<int>.from(data['payload']); // Lưu các ô thắng
            if (mySymbol == 'O') {
              Future.delayed(Duration(milliseconds: winningCells.length * 5000),
                  () {
                showVictoryDialog('10');
                dataRank.updateScore(nameUser!, 10);
              });
            } else {
              Future.delayed(Duration(milliseconds: winningCells.length * 5000),
                  () {
                showLoseDialog('-5');
                dataRank.updateScore(nameUser!, -5);
              });
            }
          } else if (data['message'] == "Opponent disconnected!") {
            statusMessage = data['message'];
            print('disconnect ' + data['symbol']);
            if (mySymbol != data['symbol']) {
              Future.delayed(
                  Duration(milliseconds: winningCells.length * 33000), () {
                showVictoryDialog('10');
                dataRank.updateScore(nameUser!, 10);
              });
            } else {
              Future.delayed(Duration(milliseconds: winningCells.length * 3000),
                  () {
                showLoseDialog('-5');
                dataRank.updateScore(nameUser!, -5);
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
      /////////////////////////////////////////////////////////////////////////////////////////////////
      // final player = audioplayers.AudioPlayer(); // Sử dụng prefix
      // player
      //     .play(audioplayers.AssetSource('assets/audio/tik.wav'))
      //     .catchError((e) {
      //   print('Error playing sound: $e');
      // });

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

  final AudioPlayer _audioPlayer = AudioPlayer();

  void _playerLeft() async {
    try {
      await _audioPlayer.setAsset('assets/audio/pop.wav');
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _playerRight() async {
    try {
      await _audioPlayer.setAsset('assets/audio/tik.wav');
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 500;
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
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
                                      image: AssetImage(
                                          'assets/images/btn_back.png'),
                                      fit: BoxFit.fitWidth,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            0, 255, 255, 255),
                                                    content: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.4,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.28,
                                                        decoration:
                                                            const BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image: AssetImage(
                                                                'assets/images/khung.png'),
                                                            fit: BoxFit.fill,
                                                          ),
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              "Do you want to exit?",
                                                              style: TextStyle(
                                                                fontSize: 18.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 20.h,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Navigator
                                                                        .pushAndRemoveUntil(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                const HomeScreen(),
                                                                      ),
                                                                      (Route<dynamic>
                                                                              route) =>
                                                                          false,
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.09,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.145,
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
                                                                    child:
                                                                        const Text(
                                                                      "NO",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            18,
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
                                                                SizedBox(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.03,
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                const HomeScreen(),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.09,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.145,
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
                                                                    child:
                                                                        const Text(
                                                                      "YES",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            18,
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
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  height: 90.h,
                                  width: 200.w,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image:
                                          AssetImage('assets/images/khung.png'),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                Text(
                                  statusMessage,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: const [
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (isMuted) {
                                  // Nếu đang tắt, bật lại nhạc với âm lượng 1.0
                                  await AudioManager()
                                      .audioPlayer
                                      .setVolume(1.0);
                                  await AudioManager().audioPlayer.play();
                                } else {
                                  // Nếu đang bật, tắt nhạc (giảm âm lượng về 0)
                                  await AudioManager()
                                      .audioPlayer
                                      .setVolume(0.0);
                                  await AudioManager().audioPlayer.stop();
                                }
                                setState(() {
                                  isMuted = !isMuted; // Đảo trạng thái
                                });
                                print("Audio ${isMuted ? 'muted' : 'unmuted'}");
                              },
                              child: Container(
                                height: MediaQuery.of(context).size.width * 0.1,
                                width: MediaQuery.of(context).size.width * 0.1,
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
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.01,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.6),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double availableWidth = constraints.maxWidth -
                                    30; // Trừ padding hai bên
                                double size =
                                    availableWidth < constraints.maxHeight
                                        ? availableWidth
                                        : constraints.maxHeight;
                                double cellSize = size / 15;

                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Nền lưới ngoài
                                    Container(
                                      width: size + 10,
                                      height: (size + 10),
                                      // margin: const EdgeInsets.symmetric(
                                      //     horizontal: 5.0),
                                      decoration: const BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 253, 213, 80),
                                      ),
                                    ),
                                    // Lưới bên trong
                                    Container(
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
                                          // Vẽ lưới
                                          CustomPaint(
                                            size: Size(size, size),
                                            painter: GridPainter(
                                              boardSize: 15,
                                              cellSize: cellSize,
                                            ),
                                          ),
                                          // Lưới và các phần tử
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
                                                onTap: () {
                                                  makeMove(index);
                                                  _playerLeft();
                                                },
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
                                                        BorderRadius.circular(
                                                            5),
                                                    boxShadow: [
                                                      if (isWinningCell)
                                                        const BoxShadow(
                                                          color: Colors.orange,
                                                          blurRadius: 10,
                                                          offset: Offset(0, 0),
                                                        ),
                                                    ],
                                                  ),
                                                  alignment: Alignment
                                                      .center, // Căn giữa nội dung
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
                                                              fontSize: cellSize *
                                                                  0.7, // Tự động điều chỉnh kích thước chữ
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
                                                                .center, // Căn giữa chữ
                                                          )
                                                        : null,
                                                  ),
                                                ),
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

                        SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.03, // Chiều cao là 10% chiều cao màn hình
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: GestureDetector(
                                onTap: () {
                                  // Xử lý khi ấn nút
                                  _showChatBox(context);
                                },
                                child: Container(
                                  width: 50.w,
                                  height: 50.h,
                                  decoration: const BoxDecoration(
                                    //shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image:
                                          AssetImage('assets/images/chat.png'),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                              ),
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
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showChatBox(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép điều chỉnh kích thước hộp thoại
      backgroundColor: Colors.transparent, // Tránh bị cắt góc
      builder: (context) => const Padding(
        padding: EdgeInsets.all(20),
        child: ChatOnline(),
      ),
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
      width: 150.w,
      height: 100.h,
      child: Stack(
        children: [
          player == 1
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: currentPlayerNow == "X"
                        ? (isBlinking ? leftSelect : left) // Nhấp nháy
                        : left,
                    borderRadius: BorderRadius.circular(30),
                  ),
                )
              : AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: currentPlayerNow == "O"
                        ? (isBlinking ? rightSelect : right) // Nhấp nháy
                        : right,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
          // Container(
          //   decoration: BoxDecoration(
          //     color: isLeftSide
          //         ? currentPlayerNow == "X"
          //             ? leftSelect
          //             : left
          //         : currentPlayerNow == "O"
          //             ? rightSelect
          //             : right,
          //     borderRadius: BorderRadius.circular(25),
          //   ),
          // ),
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
                      width: 50.w,
                      height: 50.h,
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    timer?.cancel();
    channel.sink.close();
    super.dispose();
  }

  void showVictoryDialog(String Score) {
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
                          height: 240,
                          width: 240,
                        ),
                        Text(
                          'Score: $Score',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Nút Thoát
                            Container(
                              height: 70,
                              width: 125,
                              padding: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/btn.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
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

  void showLoseDialog(String Score) {
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
                          height: 240,
                          width: 240,
                        ),
                        Text(
                          'Score: $Score',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Nút Thoát
                            Container(
                              height: 70,
                              width: 125,
                              padding: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/btn.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
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
