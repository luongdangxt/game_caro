import 'package:flutter_application_1/CaroGame.dart';
import 'package:flutter_application_1/model/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/setup_sence.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenToday extends StatefulWidget {
  const ScreenToday({super.key});

  @override
  State<ScreenToday> createState() => _ScreenTodayState();
}

class _ScreenTodayState extends State<ScreenToday> {
  List<itemBox> truongtrinhdaotao = [
    itemBox(name: 'X-O', description: 'Tic tac toe', urlImg: 'assets/images/gamecaro.png'),
  ];
  List<itemBox> trochoithugian = [
  ];
  List<itemBox> baitest = [
  ];
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(392.72, 856.72), // Kích thước thiết kế ban đầu
      builder: (context, child) {
        return Scaffold(
      body: Stack(
        children: [
          // Nội dung của bạn
          SingleChildScrollView(
            child: Column(
              children: [
                const Divider(
                  color: Color.fromARGB(255, 32, 164, 36),
                  height: 1,
                ),
                truongtrinhdaotao.length > 0 ?newboxToday('Chương trình đào tạo',truongtrinhdaotao) : Container(),
                trochoithugian.length > 0 ? newboxToday('Trò chơi thư giãn', trochoithugian) : Container(),
                baitest.length > 0 ? newboxToday('Bài test được khuyên', baitest) : Container(),
                SizedBox(height: 70.h),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: SizedBox(
                width: double.infinity, // Cho button chiếm toàn bộ chiều rộng
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 89, 213, 93),
                  ),
                  onPressed: (){},
                  child: Text(
                    'Bắt đầu tập luyện',
                    style: TextStyle(fontSize: 18.sp, color: Colors.white),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
      },
    );
  }

  Column newboxToday(String nameHead,List<itemBox> items) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(15),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            nameHead,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      for (var i = 0; i < items.length; i++) 
        newitemBox(items[i].name, items[i].description, items[i].urlImg)
    ]);
  }

  Padding newitemBox(String nameGame,String desGame,String urlImg) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, bottom: 20), // Thay margin bằng padding
      child: InkWell(
        onTap: () {
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        },
        child: Container(
          width: 300.w,
          height: 130.h,
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.teal, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              SizedBox(
              width: 150.w,
              height: 100.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      nameGame,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      softWrap: true,
                      maxLines: 2,
                    ),
                  ),
                  desGame == '' ? Container() : Align(
                    alignment: Alignment.centerLeft,
                    child: Text(desGame),
                  )
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8), // Bán kính bo góc ảnh
              child: Image.asset(
                urlImg, // Đặt hình ảnh của bạn ở đây
                fit: BoxFit.cover,
              ),
            ),
          ]),
        )
      ),
    );
  }
}
