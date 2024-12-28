import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

void main() => runApp(CaroGameApp());

class CaroGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caro Game',
      home: CaroGameScreen(),
    );
  }
}

class CaroGameScreen extends StatefulWidget {
  @override
  _CaroGameScreenState createState() => _CaroGameScreenState();
}

class _CaroGameScreenState extends State<CaroGameScreen> {
  final int boardSize = 15;
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('wss://carogame.onrender.com'),
  );

  List<String> cells = [];
  String statusMessage = 'Waiting to join a room...';
  String? mySymbol;
  final TextEditingController roomIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cells = List.filled(boardSize * boardSize, '');

    channel.stream.listen((message) {
      final data = jsonDecode(message);
      setState(() {
        if (data['type'] == 'waiting' || data['type'] == 'game-ready') {
          statusMessage = data['message'];
        } else if (data['type'] == 'game-start') {
          statusMessage = 'Game started! Your symbol: ${data['symbol']}';
          mySymbol = data['symbol'];
        } else if (data['type'] == 'move') {
          final index = data['payload']['index'];
          final symbol = data['payload']['symbol'];
          cells[index] = symbol;
        } else if (data['type'] == 'game-over') {
          statusMessage = data['message'];
          channel.sink.close();
        }
      });
    });
  }

  void joinRoom() {
    final roomId = roomIdController.text.trim();
    if (roomId.isNotEmpty) {
      channel.sink.add(jsonEncode({
        'type': 'join-room',
        'payload': {'roomId': roomId},
      }));
    }
  }

  void makeMove(int index) {
    if (cells[index].isEmpty) {
      channel.sink.add(jsonEncode({
        'type': 'move',
        'payload': {'index': index},
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Caro Game'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: roomIdController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Room ID',
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: joinRoom,
                  child: Text('Join Room'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(statusMessage, style: TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: boardSize,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: boardSize * boardSize,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => makeMove(index),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Center(
                      child: Text(
                        cells[index],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}