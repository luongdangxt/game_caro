import 'package:flutter/material.dart';
import 'package:flutter_application_1/UI/game.dart';
import 'package:flutter_application_1/UI/login.dart';
import 'package:flutter_application_1/UI/quest.dart';
import 'package:flutter_application_1/UI/test.dart';
import 'package:flutter_application_1/UI/today.dart';
import 'package:flutter_application_1/UI/user.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: loginScreen(),
  ));
}

class MyAppMain extends StatefulWidget {
  const MyAppMain({super.key});

  @override
  State<MyAppMain> createState() => _MyAppState();
}

class _MyAppState extends State<MyAppMain> {
  int indexScreen = 0;
  List<Widget> screens = [
    const ScreenToday(),
    const ScreenGame(),
    const ScreenQuest(),
    const ScreenTest(),
    const ScreenUser()
  ];
  List<String> titles = [
    'Hôm nay',
    'Trò chơi',
    'Câu đố',
    'Bài kiểm tra',
    'Người dùng'
  ];
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(392.72, 856.72), // Kích thước thiết kế ban đầu
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: Text(
              titles[indexScreen],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.local_fire_department,
                        color: Colors.grey, size: 35.h),
                    onPressed: () {},
                  ),
                  Text(
                    '0',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18.sp,
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications,
                            color: Colors.black, size: 35.h),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 7.w,
                        top: 7.h,
                        child: CircleAvatar(
                          radius: 10.r,
                          backgroundColor: Colors.red,
                          child: Text(
                            '2',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.h,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.black),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          body: screens[indexScreen],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            fixedColor: const Color.fromARGB(255, 32, 164, 36),
            currentIndex: indexScreen,
            onTap: (e) {
              setState(() {
                indexScreen = e;
              });
            },
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.calendarCheck),
                label: 'Today',
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.gamepad),
                label: 'Trò chơi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.question_mark),
                label: 'câu đố',
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.clipboardList),
                label: 'Bài kiểm tra',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Hồ sơ',
              ),
            ],
          ),
        );
      },
    );
  }
}
