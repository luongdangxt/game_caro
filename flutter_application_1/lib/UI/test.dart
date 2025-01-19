import 'package:flutter/material.dart';

class ScreenTest extends StatefulWidget {
  const ScreenTest({super.key});

  @override
  State<ScreenTest> createState() => _ScreenTestState();
}

class _ScreenTestState extends State<ScreenTest> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
          child: Column(children: [
        Divider(
          color: Color.fromARGB(255, 32, 164, 36),
          height: 1.0,
        ),
      ])),
    );
  }
}
