import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hiển thị List Rank',
      home: RankScreen(),
    );
  }
}

class RankScreen extends StatelessWidget {
  // Danh sách rank
  final List<Map<String, dynamic>> _rankList = [
    {'stt': 1, 'username': 'UserA', 'score': 1200},
    {'stt': 2, 'username': 'UserB', 'score': 1100},
    {'stt': 3, 'username': 'UserC', 'score': 1050},
    {'stt': 4, 'username': 'UserD', 'score': 950},
    {'stt': 5, 'username': 'UserE', 'score': 900},
    {'stt': 1, 'username': 'UserA', 'score': 1200},
    {'stt': 2, 'username': 'UserB', 'score': 1100},
    {'stt': 3, 'username': 'UserC', 'score': 1050},
    {'stt': 4, 'username': 'UserD', 'score': 950},
    {'stt': 5, 'username': 'UserE', 'score': 900},
    {'stt': 5, 'username': 'UserE', 'score': 900},
    {'stt': 5, 'username': 'UserE', 'score': 900},
    {'stt': 5, 'username': 'UserE', 'score': 900},
    {'stt': 1, 'username': 'UserA', 'score': 1200},
    {'stt': 2, 'username': 'UserB', 'score': 1100},
    {'stt': 3, 'username': 'UserC', 'score': 1050},
    {'stt': 4, 'username': 'UserD', 'score': 950},
    {'stt': 5, 'username': 'UserE', 'score': 900},
    {'stt': 5, 'username': 'UserE', 'score': 900},
  ];

  RankScreen({super.key});

  // Hàm hiển thị Modal Bottom Sheet
  void _showRankList(BuildContext context) {
    // Lấy tối đa 11 phần tử từ danh sách
    final limitedRankList = _rankList.take(11).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Danh sách Rank',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: limitedRankList.length,
                itemBuilder: (context, index) {
                  final rank = limitedRankList[index];

                  return Column(
                    children: [
                      if (index == 10)
                        const Divider(thickness: 2), // Dấu kẻ ở giữa
                      Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(rank['stt'].toString()),
                          ),
                          title: Text(rank['username']),
                          subtitle: Text('Score: ${rank['score']}'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hiển thị List Rank'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showRankList(context),
          child: const Text('Hiển thị danh sách Rank'),
        ),
      ),
    );
  }
}
