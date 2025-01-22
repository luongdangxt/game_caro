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
                Container(
                  height: 400.h,
                  width: 400.w,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/khung_login.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 10.h, bottom: 5.h),
                          child: Text(
                            'Gomoku Online',
                            style: TextStyle(
                              fontSize: 27.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 50.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: usernameController,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              SizedBox(height: 16.h),
                              TextField(
                                controller: passwordController,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.lock),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                obscureText: true,
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
                                                const myLoading(
                                                    isLoading: true,
                                                    errorMessage: null,
                                                    backScreen: '/login')),
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
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
