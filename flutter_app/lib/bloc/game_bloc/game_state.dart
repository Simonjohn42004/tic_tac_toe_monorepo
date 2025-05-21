import 'dart:collection';
import 'package:tic_tac_toe/data_models/player.dart';

// Main state management for the game, we use the gameBoard for providing the current board to each state
abstract class GameState {
  List<Player> gameBoard;
  Queue<int>? playerXQueue;
  Queue<int>? playerOQueue;

  GameState(this.gameBoard, this.playerXQueue, this.playerOQueue);
}

// The start of the game, when the board is emtpty
class InitialiseGameState extends GameState {
  bool isNextPlayerX = true;
  InitialiseGameState()
    : super(
        List.generate(
          9,
          (_) => Player.none,
        ),
        Queue<int>(),
        Queue<int>(),
      );
}

// The game is won by one of the players state
class GameWinState extends GameState {
  final Player player;
  List<int> winingIndices;

  GameWinState(
    super.gameBoard,
    super.playerXQueue,
    super.playerOQueue, {
    required this.player,
    required this.winingIndices,
  });
}

// The game is drawn state
class GameDrawState extends GameState {
  GameDrawState(super.gameBoard, super.playerXQueue, super.playerOQueue);
}

class GameOnGoingState extends GameState {
  final bool isNextPlayerX;
  final int? pendingRemovalBox;
  GameOnGoingState(
    super.gameBoard,
    super.playerXQueue,
    super.playerOQueue, {
    required this.isNextPlayerX,
    required this.pendingRemovalBox,
  });
}
