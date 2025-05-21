import 'package:tic_tac_toe/backend/game_data/game_data_provider.dart';

abstract class NetworkConnectionState {}

class IdleState extends NetworkConnectionState {}

class CreatingRoomState extends NetworkConnectionState {}

class RoomCreatedSuccessfullyState extends NetworkConnectionState {
  final int roomId;
  final GameDataProvider provider;

  RoomCreatedSuccessfullyState({required this.roomId, required this.provider});
}

class WaitingForOpponentState extends NetworkConnectionState {}

class JoiningRoomState extends NetworkConnectionState {}

class OpponentJoinedState extends NetworkConnectionState {
  final GameDataProvider provider;

  OpponentJoinedState({required this.provider});
}

class ConnectionErrorState extends NetworkConnectionState {
  final String error;
  ConnectionErrorState({required this.error});
}

class DisconnectedState extends NetworkConnectionState {
  final String reason;
  DisconnectedState({this.reason = "Disconnected from server"});
}
