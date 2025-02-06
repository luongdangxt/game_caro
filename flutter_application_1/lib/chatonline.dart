import 'package:flutter/material.dart';

class ChatOnline extends StatefulWidget {
  final List<String> chats; // Chứa danh sách tin nhắn
  final String username; // Tên người dùng hiện tại

  const ChatOnline({super.key, required this.chats, required this.username});

  @override
  State<ChatOnline> createState() => _ChatOnlineState();
}

class _ChatOnlineState extends State<ChatOnline> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.only(left: 30, right: 30),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage("assets/images/chatb.png"), // Ảnh nền
            fit: BoxFit.fitHeight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8, // 80% màn hình
          child: Column(
            children: [
              const SizedBox(height: 130),
              Expanded(
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.0), // Làm nền trong suốt
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: widget.chats.length,
                    itemBuilder: (context, index) {
                      final chat = widget.chats[index];
                      bool isMe = chat.split(':')[0].trim() == widget.username;
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blueAccent : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            chat,
                            style: TextStyle(
                                color: isMe ? Colors.white : Colors.black),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Nhập tin nhắn...",
                          filled: true,
                          fillColor: Colors.white
                              .withOpacity(0.0), // Làm trong suốt input
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none, // Bỏ viền
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text("Gửi"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
