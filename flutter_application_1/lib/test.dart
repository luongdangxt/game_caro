import 'package:flutter/material.dart';
import 'package:flutter_application_1/request/apiRank.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TestAPI(),
    );
  }
}

class TestAPI extends StatefulWidget {
  const TestAPI({super.key});

  @override
  State<TestAPI> createState() => _TestAPIState();
}

class _TestAPIState extends State<TestAPI> {
  String status = "Đang tải...";

  @override
  void initState() {
    super.initState();
    test();
  }

  Future<void> test() async {
    try {
      // Gọi API updateScore
      await DataRank().updateScore('nnduong', 10);
      setState(() {
        status = "Cập nhật điểm thành công!";
      });
    } catch (e) {
      setState(() {
        status = "Lỗi khi cập nhật điểm: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test API'),
      ),
      body: Center(
        child: Text(
          status,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
