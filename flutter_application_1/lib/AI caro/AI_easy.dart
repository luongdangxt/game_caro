import 'dart:math';

class AI_easy {
  int blockCount = 0;
  int aiChainCount = 0;
  int randomMoveCount = 0;
  bool isGameOver = false;
  String currentPlayer = "X";
  String winnerMessage = "";
  List<List<String>> board;
  int gridSize;

  AI_easy({required this.board, required this.gridSize});

  void aiMove() {
    if (isGameOver) return;

    // Kiểm tra và chặn người chơi nếu cần
    if (blockCount < 3) {
      List<int>? move = findThreeInRow("X");
      if (move != null) {
        blockPlayer(move);
        return;
      }
    }

    // Nếu AI chưa đạt 4 ô liên tiếp, tiếp tục đánh chuỗi 4
    if (aiChainCount < 4) {
      if (!makeSequentialMove()) {
        makeRandomMove(); // Nếu không đánh chuỗi được thì đánh ngẫu nhiên
      }
    } 
    // Sau khi hoàn thành chuỗi 4, thực hiện 2 lần đánh ngẫu nhiên
    else if (randomMoveCount < 2) {
      makeRandomMove();
      randomMoveCount++;
    } 
    // Sau 2 lần đánh ngẫu nhiên, quay lại đánh chuỗi 4
    else {
      aiChainCount = 0;
      randomMoveCount = 0;
      makeSequentialMove();
    }
  }

  bool makeSequentialMove() {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (board[row][col] == "O") {
          const directions = [
            [0, 1],  // Hướng ngang
            [1, 0],  // Hướng dọc
            [1, 1],  // Hướng chéo phải
            [1, -1]  // Hướng chéo trái
          ];

          for (var direction in directions) {
            for (int i = 1; i <= 3; i++) {
              int newRow = row + direction[0] * i;
              int newCol = col + direction[1] * i;

              if (isValidCell(newRow, newCol) && board[newRow][newCol] == "") {
                board[newRow][newCol] = "O";
                aiChainCount++;
                currentPlayer = "X";
                return true;
              }
            }
          }
        }
      }
    }
    return false;
  }

  void makeRandomMove() {
    List<List<int>> emptyCells = [];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (board[i][j] == "") {
          emptyCells.add([i, j]);
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      final randomMove = emptyCells[Random().nextInt(emptyCells.length)];
      board[randomMove[0]][randomMove[1]] = "O";
      currentPlayer = "X";
    }
  }

  void blockPlayer(List<int> move) {
    if (blockCount >= 3) return;

    board[move[0]][move[1]] = "O"; // Chặn nước đi của người chơi
    blockCount++;
    currentPlayer = "X";
  }

  List<int>? findThreeInRow(String player) {
    // Duyệt qua tất cả các ô trên bàn cờ
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (board[row][col] == player) {
          // Kiểm tra 4 hướng từ ô (row, col)
          const directions = [
            [0, 1],  // Hướng ngang
            [1, 0],  // Hướng dọc
            [1, 1],  // Hướng chéo phải xuống
            [1, -1]  // Hướng chéo trái xuống
          ];

          for (var direction in directions) {
            int count = 1;

            // Đếm các ô liên tiếp của người chơi theo hướng hiện tại
            for (int i = 1; i <= 2; i++) { // Chỉ kiểm tra chuỗi 3
              int newRow = row + direction[0] * i;
              int newCol = col + direction[1] * i;

              if (isValidCell(newRow, newCol) &&
                  board[newRow][newCol] == player) {
                count++;
              } else {
                break;
              }
            }

            // Nếu tìm thấy chuỗi 3 ô liên tiếp
            if (count == 3) {
              // Kiểm tra ô tiếp theo để chặn
              int blockRow = row + direction[0] * 3;
              int blockCol = col + direction[1] * 3;
              if (isValidCell(blockRow, blockCol) &&
                  board[blockRow][blockCol] == "") {
                return [blockRow, blockCol];
              }

              // Kiểm tra ô trước đó để chặn
              int blockRowBack = row - direction[0];
              int blockColBack = col - direction[1];
              if (isValidCell(blockRowBack, blockColBack) &&
                  board[blockRowBack][blockColBack] == "") {
                return [blockRowBack, blockColBack];
              }
            }
          }
        }
      }
    }
    return null; // Không tìm thấy chuỗi 3
  }

  bool isValidCell(int row, int col) {
    return row >= 0 && row < gridSize && col >= 0 && col < gridSize;
  }
}

