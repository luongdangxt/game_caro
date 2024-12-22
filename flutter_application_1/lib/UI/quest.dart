import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenQuest extends StatefulWidget {
  const ScreenQuest({super.key});

  @override
  State<ScreenQuest> createState() => _ScreenQuestState();
}

class _ScreenQuestState extends State<ScreenQuest> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(392.72, 856.72), // Kích thước thiết kế ban đầu
      builder: (context, child) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const Divider(
                  color: Color.fromARGB(255, 32, 164, 36),
                  height: 1.0,
                ),
                SizedBox(height: 20.h),
                Wrap(
                    spacing: 20, // Khoảng cách ngang giữa các Container
                    runSpacing: 20, // Khoảng cách dọc giữa các dòng
                    children: [
                      questBox('assets/images/gamecaro.png', 'quest1'),
                      questBox('assets/images/gamecaro.png', 'quest1'),
                      questBox('assets/images/gamecaro.png', 'quest1'),
                      questBox('assets/images/gamecaro.png', 'quest1'),
                    ]),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.0.w,  
                      vertical: 15.0.h,   
                    ),
                    child: SizedBox(
                      width:
                          double.infinity, // Cho button chiếm toàn bộ chiều rộng
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 89, 213, 93),
                        ),
                        onPressed: () {},
                        child: Text(
                          'Bắt đầu tập luyện',
                          style: TextStyle(fontSize: 18.sp, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 1, height: 70.h),
              ],
            ),
          ),
        ],
      )
    );
      }
    );
  }

  Column questBox(String urlImg, String name) {
    return Column(
      children: [
        Wrap(
            spacing: 10.w, // Khoảng cách ngang giữa các Container
            runSpacing: 10.h, // Khoảng cách dọc giữa các dòng
            children: [
              Container(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(5), // Bán kính bo góc ảnh
                    child: Image.asset(
                      urlImg, // Đường dẫn ảnh
                      width: 150.w,
                      height: 100.h,
                      fit: BoxFit.cover, // Giữ tỷ lệ ảnh
                    ),
                  ),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15.sp,
                    ),
                  )
                ],
              )),
            ]),
      ],
    );
  }
}
