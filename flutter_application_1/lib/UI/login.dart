import 'package:flutter/material.dart';
import 'package:flutter_application_1/UI/forgotpass.dart';
import 'package:flutter_application_1/UI/loading.dart';
import 'package:flutter_application_1/UI/register.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/request/apiUser.dart';
import 'package:flutter_application_1/request/saveLogin.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/back.jpg'),
                fit: BoxFit.cover,
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
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      'Select account type',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 5.0),
                    child: Text(
                      'Sign in with',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
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
                                child: Text('Login'),
                              )),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => forgotpassScreen(),
                                ),
                              );
                            },
                            child: const Text('Forgot Password?'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Container(
                      width: 300,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Google (Coming soon)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.black,
                            thickness: 1,
                            endIndent: 10,
                          ),
                        ),
                        Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.black,
                            thickness: 1,
                            indent: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    "Don't have an account, register now!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 300,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(221, 152, 150, 150),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
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
                          'Register new account',
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
