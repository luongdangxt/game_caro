import 'dart:math';

class AI_hard {
  final List<List<String>> board;
  final int gridSize;
  String currentPlayer;

  AI_hard(this.board, this.gridSize, this.currentPlayer);

  void aiMove() {
    // 1. Nếu AI có chuỗi 4 liên tiếp và không bị chặn, ưu tiên chiến thắng
    List<int>? winningMove = _findSpecificChain("O", 4);
    if (winningMove != null) {
      _makeMove(winningMove[0], winningMove[1]);
      return;
    }

    // 2. Nếu người chơi chuẩn bị thắng ngay (chuỗi 4), ưu tiên chặn trước tất cả
    List<int>? opponentCriticalMove = _findSpecificChain("X", 4);
    if (opponentCriticalMove != null) {
      _makeMove(opponentCriticalMove[0], opponentCriticalMove[1]);
      return;
    }

    // 3. Nếu đối thủ có chuỗi 3 liên tiếp mà hai đầu chưa bị chặn, ưu tiên chặn
    List<int>? unblockedChain3 = _findUnblockedChain("X", 3);
    if (unblockedChain3 != null) {
      _makeMove(unblockedChain3[0], unblockedChain3[1]);
      return;
    }

    // 4. Nếu đối thủ có chuỗi 3 đã bị chặn 1 đầu, ưu tiên chặn
    List<int>? semiBlockedChain3 = _findSemiBlockedChain("X", 3);
    if (semiBlockedChain3 != null) {
      _makeMove(semiBlockedChain3[0], semiBlockedChain3[1]);
      return;
    }

    // 5. Nếu đối thủ có chuỗi có ô trống ở giữa, ưu tiên chặn
    List<int>? chainWithGap = _findChainWithMiddleGap("X", 3);
    if (chainWithGap != null) {
      _makeMove(chainWithGap[0], chainWithGap[1]);
      return;
    }

    // 6. Nếu đối thủ có chuỗi 3 nguy hiểm, chặn ngay
    List<int>? blockingMove3 = _findSpecificChain("X", 3);
    if (blockingMove3 != null) {
      _makeMove(blockingMove3[0], blockingMove3[1]);
      return;
    }
// 7. Nếu AI có chuỗi dài hơn đáng kể so với người chơi và không bị chặn, ưu tiên chiến thắng
    List<int>? unblockedLongestAIChain = _findUnblockedLongestChain("O");
    List<int>? unblockedLongestPlayerChain = _findUnblockedLongestChain("X");

    if (unblockedLongestAIChain != null &&
        unblockedLongestPlayerChain != null) {
      int aiChainLength = 0;
      int playerChainLength = 0;

      const directions = [
        [0, 1], [1, 0], [1, 1], [1, -1] // Ngang, dọc, chéo chính, chéo phụ
      ];

      // Kiểm tra độ dài chuỗi lớn nhất của AI
      for (var dir in directions) {
        aiChainLength = max(
            aiChainLength,
            _evaluateChainLength(unblockedLongestAIChain[0],
                unblockedLongestAIChain[1], dir, "O"));
        playerChainLength = max(
            playerChainLength,
            _evaluateChainLength(unblockedLongestPlayerChain[0],
                unblockedLongestPlayerChain[1], dir, "X"));
      }

      if (aiChainLength >= playerChainLength + 2) {
        // Đảm bảo AI có chuỗi vượt trội
        _makeMove(unblockedLongestAIChain[0], unblockedLongestAIChain[1]);
        return;
      }
    }

    // 7. Nếu AI có chuỗi dài hơn người chơi và không bị chặn, ưu tiên chiến thắng
    List<int>? unblockedLongestChain = _findUnblockedLongestChain("O");
    if (unblockedLongestChain != null) {
      _makeMove(unblockedLongestChain[0], unblockedLongestChain[1]);
      return;
    }

    // 8. Nếu AI có chuỗi có ô trống và không bị chặn, ưu tiên đánh mở rộng chuỗi
    List<int>? expandOwnChainMove = _findChainWithEmptySlot("O");
    if (expandOwnChainMove != null) {
      _makeMove(expandOwnChainMove[0], expandOwnChainMove[1]);
      return;
    }

    // 9. Nếu AI có chuỗi mà hai đầu không bị chặn, ưu tiên mở rộng
    List<int>? openEndedChainMove = _findOpenEndedChain("O");
    if (openEndedChainMove != null) {
      _makeMove(openEndedChainMove[0], openEndedChainMove[1]);
      return;
    }

    // 10. Tạo chuỗi 3 tấn công nếu không có nguy cơ thua ngay
    List<int>? offensiveMove = _findSpecificChain("O", 3);
    if (offensiveMove != null) {
      _makeMove(offensiveMove[0], offensiveMove[1]);
      return;
    }

    // 11. Chặn chuỗi 2 nguy hiểm của người chơi
    List<int>? blockingMove2 = _findSpecificChain("X", 2);
    if (blockingMove2 != null) {
      _makeMove(blockingMove2[0], blockingMove2[1]);
      return;
    }
    List<int>? longestOpponentChain = _findLongestChain("X");
    if (longestOpponentChain != null) {
      _makeMove(longestOpponentChain[0], longestOpponentChain[1]);
      return;
    }
    // 12. Tìm nước đi chiến lược (trung tâm/góc)
    List<int>? strategicMove = _findStrategicMove();
    if (strategicMove != null) {
      _makeMove(strategicMove[0], strategicMove[1]);
      return;
    }
  }

  void _makeMove(int row, int col) {
    board[row][col] = "O";
    currentPlayer = "X";
  }

  List<int>? _findSpecificChain_1(String player, int chainLength) {
    const directions = [
      [0, 1], // Hàng ngang
      [1, 0], // Hàng dọc
      [1, 1], // Chéo chính
      [1, -1] // Chéo phụ
    ];

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (board[row][col] == player) {
          for (var direction in directions) {
            int count = 1;
            List<int>? firstEmpty;
            List<int>? lastEmpty;
            bool blockedStart = false, blockedEnd = false;

            // Kiểm tra hướng chính
            for (int i = 1; i < chainLength; i++) {
              int newRow = row + direction[0] * i;
              int newCol = col + direction[1] * i;

              if (_isValidCell(newRow, newCol)) {
                if (board[newRow][newCol] == player) {
                  count++;
                } else if (board[newRow][newCol] == "" && firstEmpty == null) {
                  firstEmpty = [newRow, newCol];
                } else {
                  blockedEnd = true;
                  break;
                }
              }
            }

            // Kiểm tra hướng ngược lại
            for (int i = 1; i < chainLength; i++) {
              int newRow = row - direction[0] * i;
              int newCol = col - direction[1] * i;

              if (_isValidCell(newRow, newCol)) {
                if (board[newRow][newCol] == player) {
                  count++;
                } else if (board[newRow][newCol] == "" && lastEmpty == null) {
                  lastEmpty = [newRow, newCol];
                } else {
                  blockedStart = true;
                  break;
                }
              }
            }

            // Nếu phát hiện chuỗi có thể thắng, trả về nước chặn
            if (count >= chainLength - 1 && (!blockedStart || !blockedEnd)) {
              return firstEmpty ?? lastEmpty;
            }
          }
        }
      }
    }
    return null;
  }

  List<int>? _findOpenEndedChain(String player) {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (board[row][col] == player) {
          // Kiểm tra theo hàng ngang
          if (col > 0 &&
              col + 2 < gridSize &&
              board[row][col - 1] == "" &&
              board[row][col + 1] == player &&
              board[row][col + 2] == "") {
            return [row, col - 1];
          }

          // Kiểm tra theo hàng dọc
          if (row > 0 &&
              row + 2 < gridSize &&
              board[row - 1][col] == "" &&
              board[row + 1][col] == player &&
              board[row + 2][col] == "") {
            return [row - 1, col];
          }

          // Kiểm tra đường chéo chính
          if (row > 0 &&
              row + 2 < gridSize &&
              col > 0 &&
              col + 2 < gridSize &&
              board[row - 1][col - 1] == "" &&
              board[row + 1][col + 1] == player &&
              board[row + 2][col + 2] == "") {
            return [row - 1, col - 1];
          }

          // Kiểm tra đường chéo phụ
          if (row > 0 &&
              row + 2 < gridSize &&
              col - 2 >= 0 &&
              col + 1 < gridSize &&
              board[row - 1][col + 1] == "" &&
              board[row + 1][col - 1] == player &&
              board[row + 2][col - 2] == "") {
            return [row - 1, col + 1];
          }
        }
      }
    }
    return null;
  }

  List<int>? _findSemiBlockedChain(String player, int chainLength) {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (board[row][col] == player) {
          const directions = [
            [0, 1], // Hàng ngang
            [1, 0], // Hàng dọc
            [1, 1], // Chéo chính
            [1, -1] // Chéo phụ
          ];

          for (var direction in directions) {
            int count = 1;
            bool isBlockedStart = false;
            bool isBlockedEnd = false;
            List<int>? movePosition;

            // Kiểm tra hướng chính
            for (int i = 1; i < chainLength; i++) {
              int newRow = row + direction[0] * i;
              int newCol = col + direction[1] * i;

              if (_isValidCell(newRow, newCol)) {
                if (board[newRow][newCol] == player) {
                  count++;
                } else if (board[newRow][newCol] == "" &&
                    movePosition == null) {
                  movePosition = [newRow, newCol];
                } else {
                  isBlockedEnd = true;
                  break;
                }
              } else {
                isBlockedEnd = true;
                break;
              }
            }

            // Kiểm tra hướng ngược lại
            for (int i = 1; i < chainLength; i++) {
              int newRow = row - direction[0] * i;
              int newCol = col - direction[1] * i;

              if (_isValidCell(newRow, newCol)) {
                if (board[newRow][newCol] == player) {
                  count++;
                } else if (board[newRow][newCol] == "" &&
                    movePosition == null) {
                  movePosition = [newRow, newCol];
                } else {
                  isBlockedStart = true;
                  break;
                }
              } else {
                isBlockedStart = true;
                break;
              }
            }

            // Nếu chuỗi đã bị chặn một đầu, kiểm tra và trả về vị trí chặn
            if (count == chainLength &&
                (isBlockedStart != isBlockedEnd) &&
                movePosition != null) {
              return movePosition;
            }
          }
        }
      }
    }
    return null;
  }

  List<int>? _findChainWithEmptySlot(String player) {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (board[row][col] == player) {
          const directions = [
            [0, 1], // Hàng ngang
            [1, 0], // Hàng dọc
            [1, 1], // Chéo chính
            [1, -1] // Chéo phụ
          ];

          for (var direction in directions) {
            int count = 1;
            List<int>? emptySlot;

            // Kiểm tra hướng chính
            for (int i = 1; i < gridSize; i++) {
              int newRow = row + direction[0] * i;
              int newCol = col + direction[1] * i;

              if (_isValidCell(newRow, newCol)) {
                if (board[newRow][newCol] == player) {
                  count++;
                } else if (board[newRow][newCol] == "" && emptySlot == null) {
                  emptySlot = [newRow, newCol];
                } else {
                  break;
                }
              }
            }

            // Kiểm tra hướng ngược lại
            for (int i = 1; i < gridSize; i++) {
              int newRow = row - direction[0] * i;
              int newCol = col - direction[1] * i;

              if (_isValidCell(newRow, newCol)) {
                if (board[newRow][newCol] == player) {
                  count++;
                } else if (board[newRow][newCol] == "" && emptySlot == null) {
                  emptySlot = [newRow, newCol];
                } else {
                  break;
                }
              }
            }

            // Nếu phát hiện chuỗi có ô trống liền kề, trả về vị trí đó
            if (count >= 2 && emptySlot != null) {
              return emptySlot;
            }
          }
        }
      }
    }
    return null;
  }

  List<int>? _findUnblockedLongestChain(String player) {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (board[row][col] == player) {
          const directions = [
            [0, 1], // Hàng ngang
            [1, 0], // Hàng dọc
            [1, 1], // Chéo chính
            [1, -1] // Chéo phụ
          ];

          for (var direction in directions) {
            int count = 1;
            bool isBlockedStart = false;
            bool isBlockedEnd = false;
            List<int>? movePosition;

            // Kiểm tra hướng đi
            for (int i = 1; i < gridSize; i++) {
              int newRow = row + direction[0] * i;
              int newCol = col + direction[1] * i;

              if (_isValidCell(newRow, newCol)) {
                if (board[newRow][newCol] == player) {
                  count++;
                } else if (board[newRow][newCol] == "" &&
                    movePosition == null) {
                  movePosition = [newRow, newCol];
                } else {
                  if (board[newRow][newCol] != "") isBlockedEnd = true;
                  break;
                }
              }
            }

            // Kiểm tra hướng ngược lại
            for (int i = 1; i < gridSize; i++) {
              int newRow = row - direction[0] * i;
              int newCol = col - direction[1] * i;

              if (_isValidCell(newRow, newCol)) {
                if (board[newRow][newCol] == player) {
                  count++;
                } else if (board[newRow][newCol] == "" &&
                    movePosition == null) {
                  movePosition = [newRow, newCol];
                } else {
                  if (board[newRow][newCol] != "") isBlockedStart = true;
                  break;
                }
              }
            }

            // Nếu chuỗi không bị chặn hai đầu và dài nhất
            if (!isBlockedStart && !isBlockedEnd && movePosition != null) {
              return movePosition;
            }
          }
        }
      }
    }
    return null;
  }

  List<int>? _findChainWithMiddleGap(String player, int chainLength) {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (board[row][col] == player) {
          const directions = [
            [0, 1], // Hàng ngang
            [1, 0], // Hàng dọc
            [1, 1], // Chéo chính
            [1, -1] // Chéo phụ
          ];

          for (var direction in directions) {
            int count = 1;
            List<int>? gapPosition;

            for (int i = 1; i < chainLength + 1; i++) {
              int newRow = row + direction[0] * i;
              int newCol = col + direction[1] * i;

              if (_isValidCell(newRow, newCol)) {
                if (board[newRow][newCol] == player) {
                  count++;
                } else if (board[newRow][newCol] == "" && gapPosition == null) {
                  gapPosition = [newRow, newCol];
                } else {
                  break;
                }
              }
            }

            // Nếu là chuỗi có khoảng trống ở giữa và không bị chặn
            if (count == chainLength && gapPosition != null) {
              return gapPosition;
            }
          }
        }
      }
    }
    return null;
  }

  List<int>? _findUnblockedChain(String player, int chainLength) {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (board[row][col] == player) {
          const directions = [
            [0, 1], // Hàng ngang
            [1, 0], // Hàng dọc
            [1, 1], // Chéo chính
            [1, -1] // Chéo phụ
          ];

          for (var direction in directions) {
            int count = 1;
            List<int>? emptyStart;
            List<int>? emptyEnd;

            // Kiểm tra chuỗi theo hướng chính
            for (int i = 1; i < chainLength; i++) {
              int newRow = row + direction[0] * i;
              int newCol = col + direction[1] * i;

              if (_isValidCell(newRow, newCol)) {
                if (board[newRow][newCol] == player) {
                  count++;
                } else if (board[newRow][newCol] == "" && emptyEnd == null) {
                  emptyEnd = [newRow, newCol];
                } else {
                  break;
                }
              }
            }

            // Kiểm tra phía ngược lại của chuỗi
            for (int i = 1; i < chainLength; i++) {
              int newRow = row - direction[0] * i;
              int newCol = col - direction[1] * i;

              if (_isValidCell(newRow, newCol)) {
                if (board[newRow][newCol] == player) {
                  count++;
                } else if (board[newRow][newCol] == "" && emptyStart == null) {
                  emptyStart = [newRow, newCol];
                } else {
                  break;
                }
              }
            }

            // Nếu là chuỗi 3 liên tiếp và cả hai đầu đều trống, trả về nước chặn
            if (count == chainLength &&
                emptyStart != null &&
                emptyEnd != null) {
              return emptyStart; // Ưu tiên chặn ở đầu chuỗi
            }
          }
        }
      }
    }
    return null;
  }

  List<int>? _findSpecificChain(String player, int chainLength) {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (board[row][col] == player) {
          const directions = [
            [0, 1], // Hàng ngang
            [1, 0], // Hàng dọc
            [1, 1], // Chéo chính
            [1, -1] // Chéo phụ
          ];

          for (var direction in directions) {
            int count = 1;
            List<int>? firstEmpty;
            List<int>? lastEmpty;

            // Kiểm tra hướng chính
            for (int i = 1; i < chainLength; i++) {
              int newRow = row + direction[0] * i;
              int newCol = col + direction[1] * i;

              if (_isValidCell(newRow, newCol)) {
                if (board[newRow][newCol] == player) {
                  count++;
                } else if (board[newRow][newCol] == "" && firstEmpty == null) {
                  firstEmpty = [newRow, newCol];
                } else {
                  break;
                }
              }
            }

            // Kiểm tra hướng ngược lại
            for (int i = 1; i < chainLength; i++) {
              int newRow = row - direction[0] * i;
              int newCol = col - direction[1] * i;

              if (_isValidCell(newRow, newCol)) {
                if (board[newRow][newCol] == player) {
                  count++;
                } else if (board[newRow][newCol] == "" && lastEmpty == null) {
                  lastEmpty = [newRow, newCol];
                } else {
                  break;
                }
              }
            }

            // Nếu phát hiện chuỗi nguy hiểm, trả về nước đi chặn
            if (count >= chainLength &&
                (firstEmpty != null || lastEmpty != null)) {
              return firstEmpty ?? lastEmpty;
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

  List<int>? _findLongestChain(String player) {
    int maxLength = 0;
    List<int>? bestMove;

    const directions = [
      [0, 1], [1, 0], [1, 1], [1, -1] // Ngang, dọc, chéo chính, chéo phụ
    ];

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (board[row][col] == "") {
          // Ô trống có thể đi
          for (var dir in directions) {
            int length = _evaluateChainLength(row, col, dir, player);
            if (length > maxLength) {
              maxLength = length;
              bestMove = [row, col];
            }
          }
        }
      }
    }

    return bestMove;
  }

  int _evaluateChainLength(
      int row, int col, List<int> direction, String player) {
    int count = 0;
    count += _countInDirection(row, col, direction[0], direction[1], player);
    count += _countInDirection(row, col, -direction[0], -direction[1], player);
    return count;
  }

  int _countInDirection(int row, int col, int dRow, int dCol, String player) {
    int r = row + dRow;
    int c = col + dCol;
    int count = 0;

    while (_isValidCell(r, c) && board[r][c] == player) {
      count++;
      r += dRow;
      c += dCol;
    }

    return count;
  }
}
