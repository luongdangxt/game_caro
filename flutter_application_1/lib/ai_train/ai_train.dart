import 'dart:io';
import 'dart:math';
import 'dart:convert';

// Constants for the game
const int gridSize = 15;
const int emptyCell = 0;
const int playerX = 1;
const int playerO = -1;

// Hyperparameters for Q-learning
double alpha = 0.1; // Learning rate
double gamma = 0.95; // Discount factor
double epsilon = 1.0; // Exploration rate
double epsilonDecay = 0.995;
const double epsilonMin = 0.1;
const String qTableFile = "assets/data/q_table.json";

// Helper functions
List<List<int>> createBoard() {
  return List.generate(
      gridSize, (_) => List.generate(gridSize, (_) => emptyCell));
}

String boardToState(List<List<int>> board) {
  return jsonEncode(board);
}

bool isFull(List<List<int>> board) {
  return board.every((row) => row.every((cell) => cell != emptyCell));
}

List<List<int>> availableMoves(List<List<int>> board) {
  List<List<int>> moves = [];
  for (int r = 0; r < gridSize; r++) {
    for (int c = 0; c < gridSize; c++) {
      if (board[r][c] == emptyCell) {
        moves.add([r, c]);
      }
    }
  }
  return moves;
}

int? checkWinner(List<List<int>> board) {
  final directions = [
    [1, 0], // Vertical
    [0, 1], // Horizontal
    [1, 1], // Diagonal top-left to bottom-right
    [1, -1] // Diagonal top-right to bottom-left
  ];

  for (int row = 0; row < gridSize; row++) {
    for (int col = 0; col < gridSize; col++) {
      if (board[row][col] != emptyCell) {
        for (var dir in directions) {
          int count = 0;
          for (int i = 0; i < 5; i++) {
            int r = row + dir[0] * i;
            int c = col + dir[1] * i;
            if (r >= 0 &&
                r < gridSize &&
                c >= 0 &&
                c < gridSize &&
                board[r][c] == board[row][col]) {
              count++;
            } else {
              break;
            }
          }
          if (count == 5) {
            return board[row][col];
          }
        }
      }
    }
  }
  return null;
}

List<int> findBestMove(Map<String, Map<String, double>> qTable,
    List<List<int>> board, int player, double epsilon) {
  String state = boardToState(board);
  List<List<int>> moves = availableMoves(board);

  if (Random().nextDouble() < epsilon) {
    return moves[Random().nextInt(moves.length)]; // Exploration
  }

  double maxQ = double.negativeInfinity;
  List<List<int>> bestMoves = [];

  for (var move in moves) {
    String moveKey = jsonEncode(move);
    double qValue = qTable[state]?[moveKey] ?? 0.0;
    if (qValue > maxQ) {
      maxQ = qValue;
      bestMoves = [move];
    } else if (qValue == maxQ) {
      bestMoves.add(move);
    }
  }

  return bestMoves[Random().nextInt(bestMoves.length)]; // Exploitation
}

void updateQTable(Map<String, Map<String, double>> qTable, String state,
    List<int> action, double reward, String? nextState) {
  String actionKey = jsonEncode(action);
  double currentQ = qTable[state]?[actionKey] ?? 0.0;
  double maxFutureQ = 0.0;

  if (nextState != null && qTable.containsKey(nextState)) {
    maxFutureQ = qTable[nextState]!.values.fold(double.negativeInfinity, max);
  }

  qTable[state] ??= {};
  qTable[state]![actionKey] =
      currentQ + alpha * (reward + gamma * maxFutureQ - currentQ);
}

void saveQTable(Map<String, Map<String, double>> qTable) {
  File(qTableFile).writeAsStringSync(jsonEncode(qTable));
}

Map<String, Map<String, double>> loadQTable() {
  try {
    return jsonDecode(File(qTableFile).readAsStringSync()).map((key, value) =>
        MapEntry(
            key,
            (value as Map).map((innerKey, innerValue) =>
                MapEntry(innerKey, (innerValue as num).toDouble()))));
  } catch (e) {
    return {};
  }
}

void trainAI(int episodes) {
  print("Training simulation started...");
  Map<String, Map<String, double>> qTable = loadQTable();

  for (int episode = 0; episode < episodes; episode++) {
    List<List<int>> board = createBoard();
    String state = boardToState(board);
    bool done = false;

    while (!done) {
      // Player X (learning agent) makes a move
      List<int> action = findBestMove(qTable, board, playerX, epsilon);
      board[action[0]][action[1]] = playerX;
      String nextState = boardToState(board);

      if (checkWinner(board) == playerX) {
        updateQTable(qTable, state, action, 1.0, null);
        done = true;
      } else if (isFull(board)) {
        updateQTable(qTable, state, action, 0.0, null);
        done = true;
      } else {
        // Opponent makes a random move
        List<int> opponentAction = availableMoves(
            board)[Random().nextInt(availableMoves(board).length)];
        board[opponentAction[0]][opponentAction[1]] = playerO;

        if (checkWinner(board) == playerO) {
          updateQTable(qTable, state, action, -1.0, null);
          done = true;
        } else {
          updateQTable(qTable, state, action, 0.0, nextState);
        }
      }

      state = boardToState(board);
    }

    if (epsilon > epsilonMin) {
      epsilon *= epsilonDecay;
    }

    if ((episode + 1) % 100 == 0) {
      print("Episode ${episode + 1}/$episodes completed");
    }
  }

  saveQTable(qTable);
  print("Training simulation completed.");
}

void main() {
  trainAI(1000);
}
