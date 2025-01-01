import 'dart:math';

class AI_hard {
  final List<List<String>> board;
  final int gridSize;
  String currentPlayer;

  AI_hard(this.board, this.gridSize, this.currentPlayer);

  void aiMove() {
    // 1. Ưu tiên chiến thắng ngay lập tức nếu có thể
    List<int>? winningMove = _findSpecificChain("O", 4); // Tìm chuỗi 4 để chiến thắng
    if (winningMove != null) {
      _makeMove(winningMove[0], winningMove[1]);
      return;
    }

    // 2. Chặn nước đi chiến thắng của đối thủ
    List<int>? opponentWinningMove = _findSpecificChain("X", 4);
    if (opponentWinningMove != null) {
      _makeMove(opponentWinningMove[0], opponentWinningMove[1]);
      return;
    }

    // 3. Tạo cơ hội tấn công chuỗi 3
    List<int>? offensiveMove = _findSpecificChain("O", 3);
    if (offensiveMove != null) {
      _makeMove(offensiveMove[0], offensiveMove[1]);
      return;
    }

    // 4. Chặn chuỗi 3 nguy hiểm của đối thủ
    List<int>? blockingMove = _findSpecificChain("X", 3);
    if (blockingMove != null) {
      _makeMove(blockingMove[0], blockingMove[1]);
      return;
    }

    // 5. Tìm nước đi chiến lược (trung tâm/góc hoặc tạo thế mạnh dài hạn)
    List<int>? strategicMove = _findStrategicMove();
    if (strategicMove != null) {
      _makeMove(strategicMove[0], strategicMove[1]);
      return;
    }

    // 6. Tìm ô bất kỳ còn trống (lựa chọn dự phòng)
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (board[row][col] == "") {
          _makeMove(row, col);
          return;
        }
      }
    }
  }

  void _makeMove(int row, int col) {
    board[row][col] = "O";
    currentPlayer = "X";
  }

  List<int>? _findSpecificChain(String player, int chainLength) {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (board[row][col] == player) {
          const directions = [
            [0, 1], [1, 0], [1, 1], [1, -1]
          ];

          for (var direction in directions) {
            int count = 1;
            List<int>? emptyCell;

            for (int i = 1; i < chainLength; i++) {
              int newRow = row + direction[0] * i;
              int newCol = col + direction[1] * i;
              if (_isValidCell(newRow, newCol)) {
                if (board[newRow][newCol] == player) {
                  count++;
                } else if (board[newRow][newCol] == "" && emptyCell == null) {
                  emptyCell = [newRow, newCol];
                } else {
                  break;
                }
              }
            }

            if (count == chainLength - 1 && emptyCell != null) {
              return emptyCell;
            }
          }
        }
      }
    }
    return null;
  }

  List<int>? _findStrategicMove() {
    int center = gridSize ~/ 2;
    if (board[center][center] == "") {
      return [center, center];
    }
    return null;
  }

  bool _isValidCell(int row, int col) {
    return row >= 0 && row < gridSize && col >= 0 && col < gridSize;
  }
}
