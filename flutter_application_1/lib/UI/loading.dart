import 'package:flutter/material.dart';

class myLoading extends StatefulWidget {
  final bool isLoading;
  final String? errorMessage;
  final String backScreen;
  const myLoading(
      {super.key,
      this.errorMessage,
      required this.isLoading,
      required this.backScreen});

  @override
  State<myLoading> createState() => _myLoadingState();
}

class _myLoadingState extends State<myLoading> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: widget.errorMessage == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 50,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Nút Close để tắt lớp phủ
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(widget.backScreen);
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
      ),
    );
  }
}
