import 'dart:math';

class AI_medium {
  final List<List<String>> board;
  final int gridSize;
  String currentPlayer;

  AI_medium(this.board, this.gridSize, this.currentPlayer);

  void aiMove() {
    // 1. Ưu tiên giành chiến thắng nếu có thể
    List<int>? winningMove = _findThreeInRow("O");
    if (winningMove != null) {
      _makeMove(winningMove[0], winningMove[1]);
      return;
    }

    // 2. Chặn nước đi thắng của người chơi nếu có
    List<int>? blockingMove = _findThreeInRow("X");
    if (blockingMove != null) {
      _makeMove(blockingMove[0], blockingMove[1]);
      return;
    }

    // 3. Cố gắng kéo dài chuỗi hiện tại của AI
    List<int>? chainMove = _findChainMove("O");
    if (chainMove != null) {
      _makeMove(chainMove[0], chainMove[1]);
      return;
    }

    // 4. Chặn chuỗi tiềm năng của người chơi
    List<int>? potentialBlock = _findPotentialMove("X");
    if (potentialBlock != null) {
      _makeMove(potentialBlock[0], potentialBlock[1]);
      return;
    }

    // 5. Nếu không có nước đi chiến lược, ưu tiên vị trí trung tâm hoặc đánh ngẫu nhiên
    _makeStrategicOrRandomMove();
  }

  void _makeMove(int row, int col) {
    board[row][col] = "O";
    currentPlayer = "X";
  }

  List<int>? _findThreeInRow(String player) {
    return _findSpecificChain(player, 3);
  }

  List<int>? _findPotentialMove(String player) {
    return _findSpecificChain(player, 2);
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
            for (int i = 1; i < chainLength; i++) {
              int newRow = row + direction[0] * i;
              int newCol = col + direction[1] * i;
              if (_isValidCell(newRow, newCol) &&
                  board[newRow][newCol] == player) {
                count++;
              } else {
                break;
              }
            }

            if (count == chainLength) {
              int extendRow = row + direction[0] * chainLength;
              int extendCol = col + direction[1] * chainLength;
              if (_isValidCell(extendRow, extendCol) &&
                  board[extendRow][extendCol] == "") {
                return [extendRow, extendCol];
              }

              int blockRowBack = row - direction[0];
              int blockColBack = col - direction[1];
              if (_isValidCell(blockRowBack, blockColBack) &&
                  board[blockRowBack][blockColBack] == "") {
                return [blockRowBack, blockColBack];
              }
            }
          }
        }
      }
    }
    return null;
  }

  void _makeStrategicOrRandomMove() {
    List<List<int>> strategicCells = _findStrategicCells();
    if (strategicCells.isNotEmpty) {
      final strategicMove = strategicCells[Random().nextInt(strategicCells.length)];
      _makeMove(strategicMove[0], strategicMove[1]);
      return;
    }
    _makeRandomMove();
  }

  List<List<int>> _findStrategicCells() {
    List<List<int>> cells = [];
    int center = gridSize ~/ 2;

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (board[i][j] == "") {
          int score = _calculateCellScore(i, j, center);
          cells.add([i, j, score]);
        }
      }
    }

    cells.sort((a, b) => b[2].compareTo(a[2]));
    return cells.map((cell) => [cell[0], cell[1]]).toList();
  }

  int _calculateCellScore(int row, int col, int center) {
    int distanceToCenter = (row - center).abs() + (col - center).abs();
    int strategicScore = 100 - distanceToCenter;

    const directions = [
      [0, 1], [1, 0], [1, 1], [1, -1]
    ];
    for (var direction in directions) {
      for (int i = 1; i <= 2; i++) {
        int newRow = row + direction[0] * i;
        int newCol = col + direction[1] * i;
        if (_isValidCell(newRow, newCol) && board[newRow][newCol] == "O") {
          strategicScore += 10;
        }
      }
    }
    return strategicScore;
  }

  List<int>? _findChainMove(String player) {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (board[row][col] == player) {
          const directions = [
            [0, 1], [1, 0], [1, 1], [1, -1]
          ];

          for (var direction in directions) {
            int count = 1;
            for (int i = 1; i <= 2; i++) {
              int newRow = row + direction[0] * i;
              int newCol = col + direction[1] * i;
              if (_isValidCell(newRow, newCol) &&
                  board[newRow][newCol] == player) {
                count++;
              } else {
                break;
              }
            }

            if (count >= 2) {
              int extendRow = row + direction[0] * count;
              int extendCol = col + direction[1] * count;
              if (_isValidCell(extendRow, extendCol) &&
                  board[extendRow][extendCol] == "") {
                return [extendRow, extendCol];
              }
            }
          }
        }
      }
    }
    return null;
  }

  void _makeRandomMove() {
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
      _makeMove(randomMove[0], randomMove[1]);
    }
  }

  bool _isValidCell(int row, int col) {
    return row >= 0 && row < gridSize && col >= 0 && col < gridSize;
  }
}
