import 'package:flutter/material.dart';
import 'package:flutter_application_1/UI/AudioService.dart';
import 'package:flutter_application_1/setup_sence.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_1/UI/loading.dart';
import 'package:flutter_application_1/UI/register.dart';
import 'package:flutter_application_1/request/apiUser.dart';
import 'package:flutter_application_1/request/saveLogin.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      '/login': (context) => const loginScreen(),
      '/register': (context) => registerScreen(),
    },
    home: const loginScreen(),
  ));
}

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await saveLogin().checkLoggedin();
    // Tải trước nhạc nền
    await AudioManager().load('assets/audio/str1.mp3');
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
      await AudioManager().play();
    }
  }

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Kiểm tra nếu là tablet dựa vào chiều rộng màn hình
    bool isTablet = MediaQuery.of(context).size.width > 500;
    bool istabletH = MediaQuery.of(context).size.height > 650;
    bool istabletH_1 = MediaQuery.of(context).size.height > 800;

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true, // Điều chỉnh kích thước text tự động
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/back_login.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 30.w, right: 30.w),
                child: Container(
                  height: istabletH_1
                      ? (istabletH
                          ? (isTablet ? 430.h : 360.h)
                          : (isTablet ? 500.h : 450.h))
                      : (istabletH
                          ? (isTablet ? 500.h : 400.h)
                          : (isTablet
                              ? 500.h
                              : 450.h)), // Điều chỉnh width cho tablet
                  //istabletH ? 350.h : 500.h, // Điều chỉnh width cho tablet
                  width:
                      isTablet ? 380.w : 350.w, // Điều chỉnh width cho tablet
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/khung_login.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: 10.h, bottom: 5.h, left: 10.w, right: 10.w),
                          child: Text(
                            'Caro Challenge',
                            style: TextStyle(
                              fontSize: 27.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                isTablet ? 50.w : 50.w, // Điều chỉnh padding
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  prefixIcon: Icon(
                                    Icons.person,
                                    size: 24.sp,
                                    color: Colors.grey,
                                  ),

                                  labelStyle: TextStyle(
                                    color: Colors.grey, // Màu label
                                    fontSize: 16.sp,
                                  ),
                                  floatingLabelBehavior: FloatingLabelBehavior
                                      .never, // Không đẩy label lên
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.blue,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.sp,
                                ),
                                cursorColor: Colors.blue,
                              ),
                              SizedBox(height: 16.h),
                              TextField(
                                controller: passwordController,
                                focusNode: FocusNode()
                                  ..addListener(() {
                                    // Nếu bạn muốn có logic thêm khi focus, thêm tại đây.
                                  }),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(
                                    color: Colors.grey
                                        .withOpacity(0.7), // Màu chữ mờ
                                    fontSize: 16.sp,
                                  ),
                                  floatingLabelBehavior: FloatingLabelBehavior
                                      .never, // Giữ nguyên labelText
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        12), // Bo tròn góc
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.blue,
                                      width: 2, // Độ dày viền khi focus
                                    ),
                                  ),
                                  prefixIcon: Icon(Icons.lock,
                                      size: 24.sp,
                                      color: Colors.grey), // Biểu tượng ổ khóa
                                  filled: true,
                                  fillColor: Colors.white, // Màu nền
                                ),
                                style: TextStyle(
                                  color:
                                      Colors.black, // Màu text trong TextField
                                  fontSize: 16.sp,
                                ),
                                cursorColor: Colors.blue, // Màu con trỏ
                                obscureText: true, // Hiển thị dạng mật khẩu
                              ),
                              SizedBox(height: 24.h),
                              ElevatedButton(
                                onPressed: () async {
                                  final username = usernameController.text;
                                  final password = passwordController.text;

                                  if (username.isNotEmpty &&
                                      password.isNotEmpty) {
                                    try {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const AnimatedBackgroundLoader()),
                                      );
                                      final response = await DataUser().login(
                                        username,
                                        password,
                                      );
                                      if (response == 200) {
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        await prefs.setString(
                                            'username', username);
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const HomeScreen(),
                                          ),
                                          (Route<dynamic> route) => false,
                                        );
                                        await AudioManager().play();
                                      } else {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const loginScreen(),
                                          ),
                                          (Route<dynamic> route) => false,
                                        );
                                        showError(
                                            'Something went wrong on the server');
                                      }
                                    } catch (e) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const loginScreen(),
                                        ),
                                        (Route<dynamic> route) => false,
                                      );
                                      showError(
                                          'Login failed\nIncorrect account or password');
                                    }
                                  } else {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const loginScreen(),
                                      ),
                                      (Route<dynamic> route) => false,
                                    );
                                    showError(
                                        'Please enter username and password!');
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  child: Text(
                                    'Sign - in',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              SizedBox(
                                width: 300.w,
                                height: 50.h,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => registerScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign - up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showError(String err) {
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
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/khung.png'),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 200,
                        ),
                        Text(
                          err,
                          style: const TextStyle(
                              fontSize: 20, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Nút Thoát
                            Container(
                              height: 70,
                              width: 150,
                              padding: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/btn.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Quay về màn hình chính
                                },
                                child: const Text(
                                  'Close',
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
