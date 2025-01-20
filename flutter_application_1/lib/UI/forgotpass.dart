import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: forgotpassScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class forgotpassScreen extends StatelessWidget {
  forgotpassScreen({super.key});
  final TextEditingController usernameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/back_login.png'), // Đường dẫn đến hình ảnh
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
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
                  ),
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text(
                          'Forgot password',
                          style: TextStyle(
                            fontSize: 40,
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
                                  fillColor: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                  onPressed: () {
                                    final username = usernameController.text;
                                    // Xử lý đăng nhập tại đây
                                    print('Email: $username');
                                  },
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.only(top: 12, bottom: 12),
                                    child: Text(
                                      'New password',
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

                      // Ô cuối cùng (tách biệt)
                      const SizedBox(height: 10),
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
                              'Already have an account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                      ),
                    ],
                  ),
                ],
              ),
              // Dòng text trên cùng (tên màn hình)

              // Đăng kí tài khoản
            ],
          ),
        ),
      ),
    );
  }
}
