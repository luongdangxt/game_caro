import 'package:flutter/material.dart';
import 'package:flutter_application_1/UI/loading.dart';
import 'package:flutter_application_1/UI/login.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/request/apiUser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class registerScreen extends StatelessWidget {
  registerScreen({super.key});
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/back_login.png'), // Đường dẫn đến hình ảnh
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            height: 500,
            width: 500,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/khung_login.png'), // Đường dẫn đến hình ảnh
                fit: BoxFit.fitHeight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dòng text trên cùng (tên màn hình)
                  const Padding(
                    padding: EdgeInsets.only(
                        top: 1.0, bottom: 16, left: 50, right: 50),
                    child: Text(
                      'SIGN - UP',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Đăng kí tài khoản
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 1.0, bottom: 16, left: 50, right: 50),
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
                              filled: true, // Bật tính năng nền màu
                              fillColor: Color.fromARGB(
                                  255, 255, 255, 255), // Chọn màu nền bạn muốn
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock),
                              filled: true, // Bật tính năng nền màu
                              fillColor: Color.fromARGB(
                                  255, 255, 255, 255), // Chọn màu nền bạn muốn
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: confirmController,
                            decoration: const InputDecoration(
                                labelText: 'Confirm password',
                                border: OutlineInputBorder(),
                                filled: true, // Bật tính năng nền màu
                                fillColor: Color.fromARGB(255, 255, 255, 255)),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                              onPressed: () async {
                                final username = usernameController.text;
                                final password = passwordController.text;
                                final confirm = confirmController.text;
                                // Xử lý đăng kí tại đây
                                if (username.isNotEmpty &&
                                    password.isNotEmpty &&
                                    password == confirm) {
                                  try {
                                    // Đặt isLoading thành true khi bắt đầu quá trình đăng nhập
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const myLoading(
                                            isLoading: true,
                                            errorMessage: null,
                                            backScreen: '/register'),
                                      ),
                                    );
                                    final response = await DataUser()
                                        .register(username, password);
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString('username', username);
                                    await prefs.setString('avatar',
                                        'assets/images/defaultAvatar.jpg');
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const MyAppMain(),
                                      ),
                                    );
                                    print('Register successful: $response');
                                  } catch (e) {
                                    // Đặt isLoading thành true khi bắt đầu quá trình đăng nhập
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const myLoading(
                                            isLoading: true,
                                            errorMessage: 'Register failed',
                                            backScreen: '/register'),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(top: 12, bottom: 12),
                                child: Text(
                                  'Sign - up',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  // Dòng kẻ ngăn cách

                  // Dòng chữ tạo tài khoản mới

                  // Ô cuối cùng (tách biệt)
                  SizedBox(
                    width: 300,
                    height: 50,
                    child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const loginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Back to login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
