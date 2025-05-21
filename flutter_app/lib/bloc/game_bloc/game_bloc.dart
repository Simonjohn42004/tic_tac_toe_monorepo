import 'dart:collection';
import 'package:bloc/bloc.dart';
import 'package:tic_tac_toe/backend/game_data/game_data_provider.dart';
import 'package:tic_tac_toe/bloc/game_bloc/game_event.dart';
import 'package:tic_tac_toe/bloc/game_bloc/game_state.dart';
import 'package:tic_tac_toe/data_models/game_message.dart';
import 'package:tic_tac_toe/data_models/player.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GameDataProvider _dataProvider;

  /// Winning combinations on the board
  final List<List<int>> _winningCombos = const [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  late final Stream<GameMessage> _messageStream;

  GameBloc(this._dataProvider) : super(InitialiseGameState()) {
    on<OnBoxTappedEvent>(_onBoxTapped);
    on<GameResetEvent>(_onGameReset);

    // Subscribe to incoming messages (online or offline)
    _messageStream = _dataProvider.receiveData();
    _listenToIncomingMoves();
  }

  /// Listens to moves/messages from the opponent or local player (offline mode)
  void _listenToIncomingMoves() {
    _messageStream.listen((event) {
      if (event is MoveMessage) {
        print("[GameBloc] Move received with index: ${event.index}");

        if (event.index == -1) {
          print("[GameBloc] Reset signal received");
          add(GameResetEvent(fromRemote: true));
          return;
        }

        add(OnBoxTappedEvent(index: event.index));
      }
    });
  }

  /// Handles box tap event, processes game logic and updates state.
  Future<void> _onBoxTapped(
    OnBoxTappedEvent event,
    Emitter<GameState> emit,
  ) async {
    final currentState = state;

    if (currentState is! InitialiseGameState &&
        currentState is! GameOnGoingState) {
      print("[GameBloc] Tap ignored: invalid state");
      return;
    }

    // Clone current board and queues for mutation
    final Queue<int> currentXQueue = Queue<int>.from(currentState.playerXQueue ?? Queue<int>());
    final Queue<int> currentOQueue = Queue<int>.from(currentState.playerOQueue ?? Queue<int>());
    final updatedBoard = List<Player>.from(currentState.gameBoard);

    final isPlayerX = currentState is InitialiseGameState ||
        (currentState is GameOnGoingState && currentState.isNextPlayerX);

    // If cell already filled, ignore the tap
    if (updatedBoard[event.index] != Player.none) {
      print("[GameBloc] Tap ignored: cell already occupied");
      return;
    }

    // Player's move logic
    final activeQueue = isPlayerX ? currentXQueue : currentOQueue;

    // Remove oldest mark if player has 3 marks already
    if (activeQueue.length == 3) {
      final int toRemove = activeQueue.removeLast();
      updatedBoard[toRemove] = Player.none;
      print("[GameBloc] Removed oldest mark at index $toRemove for player ${isPlayerX ? 'X' : 'O'}");
    }

    // Add new move
    updatedBoard[event.index] = isPlayerX ? Player.x : Player.o;
    activeQueue.addFirst(event.index);
    print("[GameBloc] Player ${isPlayerX ? 'X' : 'O'} played at index ${event.index}");

    // Determine which box might be removed next for the opponent
    final opponentQueue = isPlayerX ? currentOQueue : currentXQueue;
    int? nextPendingRemoval;
    if (opponentQueue.length == 3) {
      nextPendingRemoval = opponentQueue.last;
    }

    // Update state
    final nextState = _checkWin(
      updatedBoard,
      currentXQueue,
      currentOQueue,
      !isPlayerX,
      nextPendingRemoval,
    );
    emit(nextState);

    // Notify opponent or mirror for offline mode
    _dataProvider.sendMessage(MoveMessage(index: event.index));
  }

  /// Handles game reset locally or from remote
  void _onGameReset(
    GameResetEvent event,
    Emitter<GameState> emit,
  ) {
    if (!event.fromRemote) {
      _dataProvider.sendMessage(MoveMessage(index: -1)); // Notify peer
      print("[GameBloc] Local reset, notifying opponent");
    } else {
      print("[GameBloc] Reset from remote peer");
    }

    emit(InitialiseGameState());
  }

  /// Checks for win or draw conditions
  GameState _checkWin(
    List<Player> board,
    Queue<int> playerXQueue,
    Queue<int> playerOQueue,
    bool isNextPlayerX,
    int? pendingRemovalBox,
  ) {
    for (final combo in _winningCombos) {
      final a = board[combo[0]];
      final b = board[combo[1]];
      final c = board[combo[2]];

      if (a != Player.none && a == b && b == c) {
        print("[GameBloc] Player $a wins with combo $combo");
        return GameWinState(
          board,
          playerXQueue,
          playerOQueue,
          player: a,
          winingIndices: combo,
        );
      }
    }

    final hasEmpty = board.any((cell) => cell == Player.none);
    if (hasEmpty) {
      return GameOnGoingState(
        board,
        playerXQueue,
        playerOQueue,
        isNextPlayerX: isNextPlayerX,
        pendingRemovalBox: pendingRemovalBox,
      );
    }

    print("[GameBloc] Game ended in a draw");
    return GameDrawState(board, playerXQueue, playerOQueue);
  }
}
