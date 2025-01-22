import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class registerScreen extends StatelessWidget {
  registerScreen({super.key});
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

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
                  height: 400.h, // Thích ứng chiều cao
                  width: 420.w, // Thích ứng chiều rộng
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/khung_login.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Text(
                            'SIGN - UP',
                            style: TextStyle(
                              fontSize: 40.sp, // Điều chỉnh kích thước văn bản
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 50.w),
                          child: Column(
                            children: [
                              TextField(
                                controller: usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person, size: 20.sp),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              SizedBox(height: 16.h),
                              TextField(
                                controller: passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.lock, size: 20.sp),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                obscureText: true,
                              ),
                              SizedBox(height: 16.h),
                              TextField(
                                controller: confirmController,
                                decoration: const InputDecoration(
                                  labelText: 'Confirm password',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              SizedBox(height: 24.h),
                              ElevatedButton(
                                onPressed: () async {
                                  // Xử lý sự kiện
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  child: Text(
                                    'Sign - up',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 300.w,
                          height: 50.h,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const loginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Back to login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
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
