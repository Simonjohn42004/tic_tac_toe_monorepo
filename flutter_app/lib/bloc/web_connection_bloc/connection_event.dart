abstract class ConnectionEvent {}

class CreateRoomRequestedEvent extends ConnectionEvent {}

class JoinRoomRequestedEvent extends ConnectionEvent {
  final int roomId;

  JoinRoomRequestedEvent({required this.roomId});
}

class ConnectionLostEvent extends ConnectionEvent {
  final String reason;
  ConnectionLostEvent({required this.reason});
}
