import 'dart:async';

import 'package:tic_tac_toe/data_models/game_message.dart';
import 'package:tic_tac_toe/data_models/room.dart';

abstract class GameDataProvider {
  /// Connects to the server, creates a new room, and joins its WebSocket.
  Future<Room> createRoom();

  /// Join a room that was already created by another user.
  Future<void> joinRoom(Room room);

  /// Sends a structured game message to the WebSocket.
  void sendMessage(GameMessage message);

  /// Listens to incoming structured game messages from the WebSocket.
  /// Emits messages like moves, text messages, game over signals, etc.
  Stream<GameMessage> receiveData();

  /// Closes the WebSocket connection gracefully.
  void close();
}

