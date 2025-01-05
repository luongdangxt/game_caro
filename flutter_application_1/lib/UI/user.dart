import 'package:flutter/material.dart';
import 'package:flutter_application_1/UI/login.dart';
import 'package:flutter_application_1/request/saveLogin.dart';

class ScreenUser extends StatefulWidget {
  const ScreenUser({super.key});

  @override
  State<ScreenUser> createState() => _ScreenUserState();
}

class _ScreenUserState extends State<ScreenUser> {
  String nameUser = 'no name'; // Khởi tạo giá trị mặc định
  String urlAvatar = 'no avatar'; // Khởi tạo giá trị mặc định

  @override
  void initState() {
    super.initState();
    getInfoLogin();
  }

  Future<void> getInfoLogin() async {
    final dataUser = await saveLogin().getUserData();
    setState(() {
      nameUser = dataUser['username'] ?? 'no name';
      urlAvatar = dataUser['avatar'] ?? 'no avatar';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(
              color: Color.fromARGB(255, 32, 164, 36),
              height: 1.0,
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50, // Kích thước hình tròn
              backgroundImage: urlAvatar != 'no avatar'
                  ? NetworkImage(urlAvatar) as ImageProvider
                  : const AssetImage('assets/images/defaultAvatar.jpg'),
            ),
            const SizedBox(height: 10),
            // Tên người dùng
            Text(
              nameUser,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity, // Cho button chiếm toàn bộ chiều rộng
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    // Xử lý đăng xuất
                    await saveLogin().logout();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>  loginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Log out',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
