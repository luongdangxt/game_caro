import 'package:flutter/material.dart';

class ChatOnline extends StatelessWidget {
  const ChatOnline({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
          height: MediaQuery.of(context).size.height * 0.9, // 80% màn hình
          child: Column(
            children: [
              screenWidth > 500
                  ? const SizedBox(height: 220)
                  : const SizedBox(height: 130),
              Expanded(
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.0), // Làm nền trong suốt hoàn toàn
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "Nội dung tin nhắn...",
                      style: TextStyle(
                        fontSize: screenWidth > 500
                            ? screenWidth * 0.03
                            : screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ), // Nội dung chat
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    screenWidth > 500
                        ? const SizedBox(width: 20)
                        : const SizedBox(width: 0),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        height: screenWidth > 500
                            ? screenHeight * 0.06
                            : screenHeight * 0.07,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                              255, 148, 74, 21), // Màu nền nâu nhạt (tan)
                          borderRadius:
                              BorderRadius.circular(20), // Bo góc khung
                          border: Border.all(
                            color: const Color.fromARGB(
                                255, 136, 68, 19), // Màu viền nâu đậm
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20), // Thêm padding bên trong
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: "Nhập tin nhắn...",
                            labelStyle: TextStyle(
                              fontSize: screenWidth > 500
                                  ? screenWidth * 0.03
                                  : screenWidth * 0.03,
                              color: const Color.fromARGB(
                                  255, 255, 255, 255), // Màu chữ của label
                            ),
                            border: InputBorder
                                .none, // Loại bỏ viền mặc định của TextField
                          ),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 255, 255,
                                255), // Màu chữ của nội dung nhập
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                        alignment: Alignment.center,
                        height: screenWidth > 500
                            ? screenHeight * 0.07
                            : screenHeight * 0.07,
                        width: screenWidth > 500
                            ? screenWidth * 0.2
                            : screenWidth * 0.2,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/btn.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Send",
                            style: TextStyle(
                              fontSize: screenWidth > 500
                                  ? screenWidth * 0.03
                                  : screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        )),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
