import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tic_tac_toe/data_models/room.dart';
import 'package:tic_tac_toe/backend/web_socket/websocket_exceptions.dart';
import 'package:tic_tac_toe/utilities/app_constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketClient {
  late final WebSocketChannel _channel;

  /// Creates a room and connects to its WebSocket endpoint.
  Future<Room> createRoom() async {
    try {
      final room = await _createAndGetRoom();
      final wsUri = Uri.parse("$websocketName${room.roomId}");
      _channel = WebSocketChannel.connect(wsUri);
      print("Player connected to room ${room.roomId}!");
      return room;
    } catch (e) {
      throw WebsocketConnectingException();
    }
  }

  /// Joins an existing room after verifying its existence.
  Future<void> joinRoom(Room room) async {
    try {
      final response = await http.get(Uri.http(hostName, "$checkRoomPath/${room.roomId}"));

      if (response.statusCode != 200) {
        throw RoomNotFoundException();
      }

      final wsUri = Uri.parse("$websocketName${room.roomId}");
      _channel = WebSocketChannel.connect(wsUri);
      print("Joined room ${room.roomId} successfully!");
    } catch (e) {
      throw WebsocketConnectingException();
    }
  }

  /// Listens to WebSocket messages and delegates based on message type.
  void receiveData({
    required void Function(int index) onIndexReceived,
    required void Function(String message) onStringMessage,
  }) {
    _channel.stream.listen(
      (message) {
        try {
          print("Received message from stream: $message");
          final decoded = jsonDecode(message);

          if (decoded is Map<String, dynamic>) {
            final type = decoded["type"];

            if (type == "move" && decoded["index"] is int) {
              onIndexReceived(decoded["index"]);
            } else if (type == "message" && decoded["text"] is String) {
              onStringMessage(decoded["text"]);
            } else {
              onStringMessage("Unknown message format received.");
            }
          } else {
            onStringMessage("Unexpected message format.");
          }
        } catch (e) {
          print("Error decoding message: $e");
          onStringMessage("Failed to parse message.");
        }
      },
      onError: (error) {
        onStringMessage("WebSocket error: $error");
      },
      onDone: () {
        onStringMessage("Connection closed.");
      },
    );
  }

  /// Sends a JSON-encoded message to the server.
  void sendData(Map<String, dynamic> data) {
    print("Sending data: $data");
    _channel.sink.add(jsonEncode(data));
  }

  /// Closes the WebSocket connection cleanly.
  void close() {
    _channel.sink.close();
  }

  /// Helper to create a room by calling the backend.
  Future<Room> _createAndGetRoom() async {
    try {
      final response = await http.get(Uri.http(hostName, createRoomPath));
      if (response.statusCode != 200) throw GenericException();
      return Room.fromJson(jsonDecode(response.body));
    } catch (_) {
      throw GenericException();
    }
  }

  WebSocketChannel get channel => _channel;
}


