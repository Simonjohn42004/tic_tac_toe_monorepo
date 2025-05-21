import 'dart:async';

import 'package:tic_tac_toe/backend/game_data/game_data_provider.dart';
import 'package:tic_tac_toe/data_models/game_message.dart';
import 'package:tic_tac_toe/data_models/room.dart';

/// Simulates WebSocket communication in offline mode by using a local stream.
class OfflineGameDataProvider extends GameDataProvider {
  final _streamController = StreamController<GameMessage>.broadcast();

  @override
  Future<Room> createRoom() async {
    // Offline mode doesn't use real rooms, return a dummy one
    final room = Room(roomId: 1);
    print("Offline room created: ${room.roomId}");
    return room;
  }

  @override
  Future<void> joinRoom(Room room) async {
    // No-op for offline; room is already considered joined
    print("Offline: joined room ${room.roomId}");
  }

  @override
  Stream<GameMessage> receiveData() {
    return _streamController.stream;
  }

  @override
  void sendMessage(GameMessage message) {
    print("Offline sending message: $message");
    _streamController.add(message);
  }

  @override
  void close() {
    print("Offline stream closed.");
    _streamController.close();
  }
}
