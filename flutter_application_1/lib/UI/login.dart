import 'package:flutter/material.dart';
import 'package:flutter_application_1/UI/forgotpass.dart';
import 'package:flutter_application_1/UI/loading.dart';
import 'package:flutter_application_1/UI/register.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/request/apiUser.dart';
import 'package:flutter_application_1/request/saveLogin.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const loginScreen());
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
          builder: (context) => const MyAppMain(),
        ),
      );
    }
  }

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
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
            height: 500,
            width: 500,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/khung_login.png'),
                fit: BoxFit.fitHeight,
              ),
            ),
            child: Center(
              // Center widget bao bọc toàn bộ Column
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Căn giữa theo trục dọc
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Căn giữa theo trục ngang
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 23, bottom: 20.0),
                    child: Text(
                      'Select account type',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
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
                          const SizedBox(height: 24),
                          ElevatedButton(
                              onPressed: () async {
                                final username = usernameController.text;
                                final password = passwordController.text;

                                if (username.isNotEmpty &&
                                    password.isNotEmpty) {
                                  try {
                                    // Đặt isLoading thành true khi bắt đầu quá trình đăng nhập
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const myLoading(
                                              isLoading: true,
                                              errorMessage: null,
                                              backScreen: '/login')),
                                    );
                                    final response = await DataUser()
                                        .login(username, password);
                                    if (response == 200) {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString(
                                          'username', username);
                                      final avatar =
                                          await DataUser().getAvatar(username);
                                      await prefs.setString('avatar', avatar);
                                      final dataUser =
                                          await saveLogin().getUserData();
                                      print(dataUser['avatar']);
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const MyAppMain()),
                                        (Route<dynamic> route) => false,
                                      );
                                    } else {
                                      // Cập nhật trạng thái khi đăng nhập không thành công
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const myLoading(
                                            isLoading: true,
                                            errorMessage:
                                                'Invalid username or password',
                                            backScreen: '/login',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    // Cập nhật trạng thái khi xảy ra lỗi
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const myLoading(
                                            isLoading: true,
                                            errorMessage: 'Login failed',
                                            backScreen: '/login'),
                                      ),
                                    );
                                  }
                                } else {
                                  // Khi không có tên người dùng hoặc mật khẩu
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const myLoading(
                                          isLoading: true,
                                          errorMessage:
                                              'Please enter username and password!',
                                          backScreen: '/login'),
                                    ),
                                  );
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(top: 12, bottom: 12),
                                child: Text(
                                  'Sign - in',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 300,
                            height: 50,
                            child: TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => registerScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Sign - up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => forgotpassScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color.fromARGB(255, 207, 207, 207),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
