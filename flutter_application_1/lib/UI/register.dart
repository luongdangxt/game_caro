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
    bool isTablet = MediaQuery.of(context).size.width > 500;
    bool istabletH = MediaQuery.of(context).size.height > 650;
    bool istabletH_1 = MediaQuery.of(context).size.height > 800;
    bool isObscured = true;
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
                  padding: EdgeInsets.only(left: 20.w, right: 20.w),
                  child: Container(
                    height: istabletH_1
                        ? (istabletH
                            ? (isTablet ? 500.h : 390.h)
                            : (isTablet ? 500.h : 450.h))
                        : (istabletH
                            ? (isTablet ? 500.h : 430.h)
                            : (isTablet
                                ? 500.h
                                : 450.h)), // Điều chỉnh width cho tablet
                    //istabletH ? 350.h : 500.h, // Điều chỉnh width cho tablet
                    width:
                        isTablet ? 300.w : 350.w, // Điều chỉnh width cho tablet
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
                          // Container(
                          //   height: 400.h, // Thích ứng chiều cao
                          //   width: 420.w, // Thích ứng chiều rộng
                          //   decoration: const BoxDecoration(
                          //     image: DecorationImage(
                          //       image:
                          //           AssetImage('assets/images/khung_login.png'),
                          //       fit: BoxFit.fitHeight,
                          //     ),
                          //   ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  child: Text(
                                    'SIGN - UP',
                                    textAlign:
                                        TextAlign.center, // Căn giữa văn bản
                                    style: TextStyle(
                                      fontSize: 36
                                          .sp, // Giảm kích thước văn bản để phù hợp hơn
                                      fontWeight: FontWeight
                                          .w900, // Tăng độ đậm của chữ
                                      color: Colors.white, // Màu chữ trắng
                                      letterSpacing:
                                          2, // Tạo khoảng cách giữa các ký tự
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 50.w),
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: usernameController,
                                        decoration: InputDecoration(
                                          labelText: 'Username',
                                          labelStyle: TextStyle(
                                            color: Colors.grey.withOpacity(
                                                0.7), // Làm mờ màu chữ của label
                                            fontSize:
                                                16.sp, // Kích thước chữ label
                                          ),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior
                                                  .never, // Giữ label cố định
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // Bo tròn góc khung
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors
                                                  .blue, // Màu viền khi focus
                                              width: 2, // Độ dày viền khi focus
                                            ),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.person,
                                            size: 24.sp, // Kích thước icon
                                            color: Colors.grey, // Màu icon
                                          ),
                                          filled: true,
                                          fillColor: Colors
                                              .white, // Màu nền bên trong TextField
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 12.h,
                                              horizontal: 16
                                                  .w), // Căn chỉnh padding nội dung
                                        ),
                                        keyboardType: TextInputType
                                            .emailAddress, // Định dạng bàn phím
                                        style: TextStyle(
                                          color: Colors
                                              .black, // Màu chữ bên trong TextField
                                          fontSize: 16.sp, // Kích thước chữ
                                        ),
                                        cursorColor: Colors.blue, // Màu con trỏ
                                      ),
                                      SizedBox(height: 16.h),
                                      TextField(
                                        controller: passwordController,
                                        obscureText:
                                            isObscured, // Ẩn hoặc hiển thị mật khẩu
                                        decoration: InputDecoration(
                                          labelText: 'Password',
                                          labelStyle: TextStyle(
                                            color: Colors.grey.withOpacity(
                                                0.7), // Làm mờ màu chữ của label
                                            fontSize:
                                                16.sp, // Kích thước chữ label
                                          ),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior
                                                  .never, // Giữ label cố định
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // Bo tròn góc khung
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors
                                                  .blue, // Màu viền khi focus
                                              width: 2, // Độ dày viền khi focus
                                            ),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.lock,
                                            size: 24.sp, // Kích thước icon
                                            color: Colors.grey, // Màu icon
                                          ),
                                          // suffixIcon: IconButton(
                                          //   icon: Icon(
                                          //     isObscured
                                          //         ? Icons.visibility
                                          //         : Icons
                                          //             .visibility_off, // Biểu tượng
                                          //     color: Colors.grey,
                                          //   ),
                                          //   onPressed: () {
                                          //     // Đổi trạng thái ẩn/hiện mật khẩu
                                          //     setState(() {
                                          //       isObscured = !isObscured;
                                          //     });
                                          //   },
                                          // ),
                                          filled: true,
                                          fillColor: Colors
                                              .white, // Màu nền bên trong TextField
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 12.h,
                                              horizontal: 16
                                                  .w), // Căn chỉnh padding nội dung
                                        ),
                                        style: TextStyle(
                                          color: Colors
                                              .black, // Màu chữ bên trong TextField
                                          fontSize: 16.sp, // Kích thước chữ
                                        ),
                                        cursorColor: Colors.blue, // Màu con trỏ
                                      ),
                                      SizedBox(height: 16.h),
                                      TextField(
                                        controller: confirmController,
                                        obscureText:
                                            isObscured, // Cũng ẩn/hiện mật khẩu giống như password
                                        decoration: InputDecoration(
                                          labelText: 'Confirm password',
                                          labelStyle: TextStyle(
                                            color: Colors.grey.withOpacity(
                                                0.7), // Làm mờ màu chữ của label
                                            fontSize:
                                                16.sp, // Kích thước chữ label
                                          ),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior
                                                  .never, // Giữ label cố định
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // Bo tròn góc khung
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors
                                                  .blue, // Màu viền khi focus
                                              width: 2, // Độ dày viền khi focus
                                            ),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.lock_outline,
                                            size: 24.sp, // Kích thước icon
                                            color: Colors.grey, // Màu icon
                                          ),
                                          // suffixIcon: IconButton(
                                          //   icon: Icon(
                                          //     _isObscured ? Icons.visibility : Icons.visibility_off, // Biểu tượng hiển thị mật khẩu
                                          //     color: Colors.grey,
                                          //   ),
                                          //   onPressed: () {
                                          //     // Đổi trạng thái ẩn/hiện mật khẩu
                                          //     setState(() {
                                          //       _isObscured = !_isObscured;
                                          //     });
                                          //   },
                                          // ),
                                          filled: true,
                                          fillColor: Colors
                                              .white, // Màu nền bên trong TextField
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 12.h,
                                              horizontal: 16
                                                  .w), // Căn chỉnh padding nội dung
                                        ),
                                        style: TextStyle(
                                          color: Colors
                                              .black, // Màu chữ bên trong TextField
                                          fontSize: 16.sp, // Kích thước chữ
                                        ),
                                        cursorColor: Colors.blue, // Màu con trỏ
                                      ),
                                      SizedBox(height: 24.h),
                                      ElevatedButton(
                                        onPressed: () async {
                                          // Xử lý sự kiện
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12.h),
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
                                          builder: (context) =>
                                              const loginScreen(),
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
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
