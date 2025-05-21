class Room {
  final int roomId;

  Room({required this.roomId});

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(roomId: json["roomId"]);
  }
}
