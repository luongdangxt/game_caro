import 'package:flutter/material.dart';
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
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
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
                                          builder: (context) => const myLoading(
                                            isLoading: true,
                                            errorMessage: null,
                                            backScreen: '/login',
                                          ),
                                        ),
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
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const myLoading(
                                              isLoading: true,
                                              errorMessage:
                                                  'Invalid username or password',
                                              backScreen: '/login',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const myLoading(
                                            isLoading: true,
                                            errorMessage: 'Login failed',
                                            backScreen: '/login',
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const myLoading(
                                          isLoading: true,
                                          errorMessage:
                                              'Please enter username and password!',
                                          backScreen: '/login',
                                        ),
                                      ),
                                    );
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
}
