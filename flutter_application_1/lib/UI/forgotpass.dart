import 'package:flutter/material.dart';
import 'package:flutter_application_1/UI/login.dart';

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
            image:
                AssetImage('assets/images/back.jpg'), // Đường dẫn đến hình ảnh
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dòng text trên cùng (tên màn hình)
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Forgot password',
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
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                          onPressed: () {
                            final username = usernameController.text;
                            // Xử lý đăng nhập tại đây
                            print('Email: $username');
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(top: 12, bottom: 12),
                            child: Text('New password'),
                          )),
                    ],
                  ),
                ),
              ),
              // Dòng kẻ ngăn cách
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
              // Dòng chữ tạo tài khoản mới
              const Text(
                'Already have an account, log in now!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),

              // Ô cuối cùng (tách biệt)
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
                          builder: (context) => loginScreen(),
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
        ),
      ),
    );
  }
}
