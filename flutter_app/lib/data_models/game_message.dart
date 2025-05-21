sealed class GameMessage {
  Map<String, dynamic> toJson();
}

class MoveMessage extends GameMessage {
  final int index;

  MoveMessage({required this.index});

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "move",
      "index": index,
    };
  }

  @override
  String toString() => 'MoveMessage(index: $index)';
}

class TextMessage extends GameMessage {
  final String message;

  TextMessage({required this.message});

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "message",
      "text": message,
    };
  }

  @override
  String toString() => 'TextMessage(message: "$message")';
}

