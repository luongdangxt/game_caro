import 'package:flutter_application_1/model/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenGame extends StatefulWidget {
  const ScreenGame({super.key});

  @override
  State<ScreenGame> createState() => _ScreenGameState();
}

class _ScreenGameState extends State<ScreenGame> {
  List<itemBGame> items = [
    itemBGame(name: 'Tic tac toe', description: 'Mức 1/100', urlImg: 'assets/images/gamecaro.png', lock: false),
  ];
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(392.72, 856.72), // Kích thước thiết kế ban đầu
      builder: (context, child) {
      return SingleChildScrollView(
        child: Column(children: [
          const Divider(
            color: Color.fromARGB(255, 32, 164, 36),
            height: 1.0,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Trò chơi miễn phí trong ngày',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                softWrap: true,
                maxLines: 2,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8), // Bán kính bo góc ảnh
            child: Image.asset(
              width: 300.w,
              height: 100.h,
              'assets/images/gamecaro.png', // Đặt hình ảnh của bạn ở đây
              fit: BoxFit.cover,
            ),
          ),
          itemBoxGame('Các trò chơi miễn phí', items),
          SizedBox(height: 20.h)
        ])
      );
      }
    );
  }
  

  Column itemBoxGame(String name,List<itemBGame> items) {
    return Column(children: [
        Container(
          padding: const EdgeInsets.all(10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              name,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              softWrap: true,
              maxLines: 2,
            ),
          ),
        ),
        Wrap(
            spacing: 10, // Khoảng cách ngang giữa các Container
            runSpacing: 10, // Khoảng cách dọc giữa các dòng
            children: [
              for (var item in items)
                itemGame(item.name,item.urlImg,item.description,item.lock)
            ]
          ),
      ]);
  }

  Container itemGame(String name, String urlImg, String lever, bool lock) {
    return Container(
      child: Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5), // Bán kính bo góc ảnh
              child: lock ? ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.grey, // Áp dụng màu xám
                  BlendMode.saturation, // Kết hợp chế độ saturation để loại bỏ màu
                ),
                child: Image.asset(
                  urlImg, // Đường dẫn ảnh
                  width: 150.w,
                  height: 120.h,
                  fit: BoxFit.cover, // Giữ tỷ lệ ảnh
                ),
              ):Image.asset(
                  urlImg, // Đường dẫn ảnh
                  width: 150.w,
                  height: 120.h,
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
        ),
        Positioned(
            bottom: 40.h,
            left: 5.w,
            child: Container(
                width: 70.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 14, 14, 113),
                  borderRadius: BorderRadius.circular(5), // Bán kính bo góc
                ),
                child: Center(
                    child: Text(
                  lever,
                  style: TextStyle(
                    color: Color.fromARGB(255, 214, 210, 210),
                    fontSize: 10.sp  
                  ),
                ))))
      ],)
    );
  }
}
