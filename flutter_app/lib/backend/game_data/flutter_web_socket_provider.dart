import 'dart:async';
import 'package:tic_tac_toe/data_models/game_message.dart';
import 'package:tic_tac_toe/data_models/room.dart';
import 'package:tic_tac_toe/backend/web_socket/web_socket_client.dart';
import 'package:tic_tac_toe/backend/game_data/game_data_provider.dart';

class FlutterWebSocketProvider extends GameDataProvider {
  final WebSocketClient _client;

  FlutterWebSocketProvider({required WebSocketClient client}) : _client = client;

  @override
  Future<Room> createRoom() async {
    print("[WebSocketProvider] Creating room...");
    return await _client.createRoom();
  }

  @override
  Future<void> joinRoom(Room room) async {
    print("[WebSocketProvider] Joining room with ID: ${room.roomId}");
    await _client.joinRoom(room);
  }

  @override
  Stream<GameMessage> receiveData() {
    final controller = StreamController<GameMessage>();

    print("[WebSocketProvider] Setting up data receiver...");

    _client.receiveData(
      onIndexReceived: (index) {
        print("[WebSocketProvider] Received move index: $index");
        controller.add(MoveMessage(index: index));
      },
      onStringMessage: (message) {
        print("[WebSocketProvider] Received text message: $message");
        controller.add(TextMessage(message: message));
      },
    );

    // Ensure cleanup when the stream is cancelled
    controller.onCancel = () {
      print("[WebSocketProvider] Stream cancelled. Closing connection.");
      close();
    };

    return controller.stream;
  }

  @override
  void sendMessage(GameMessage message) {
    print("[WebSocketProvider] Sending message: $message");
    _client.sendData(message.toJson());
  }

  @override
  void close() {
    print("[WebSocketProvider] Closing WebSocket connection.");
    _client.close();
  }
}
