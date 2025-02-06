import 'package:flutter/material.dart';

class ChatOnline extends StatelessWidget {
  const ChatOnline({super.key});

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
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  width: 400,
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.0), // Làm nền trong suốt hoàn toàn
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const SingleChildScrollView(
                    padding: EdgeInsets.all(8),
                    child: Text("Nội dung tin nhắn..."), // Nội dung chat
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Gửi"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
