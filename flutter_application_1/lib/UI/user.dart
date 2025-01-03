import 'package:flutter/material.dart';

class ScreenUser extends StatefulWidget {
  const ScreenUser({super.key});

  @override
  State<ScreenUser> createState() => _ScreenUserState();
}

class _ScreenUserState extends State<ScreenUser> {
  final urlAvatar = 'no avatar';
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
              backgroundImage: urlAvatar != 'no avatar' ? 
                NetworkImage(urlAvatar) : 
                const AssetImage('assets/images/defaultAvate.jpg'),
            ),
            const SizedBox(height: 10),
            // Tên người dùng
            const Text(
              'User Name',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

          ]
        ) 
      ),
    );
  }
}