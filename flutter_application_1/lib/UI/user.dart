import 'package:flutter/material.dart';

class ScreenUser extends StatefulWidget {
  const ScreenUser({super.key});

  @override
  State<ScreenUser> createState() => _ScreenUserState();
}

class _ScreenUserState extends State<ScreenUser> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Divider(
              color: Color.fromARGB(255, 32, 164, 36),
              height: 1.0,         
            ),
          ]
        ) 
      ),
    );
  }
}