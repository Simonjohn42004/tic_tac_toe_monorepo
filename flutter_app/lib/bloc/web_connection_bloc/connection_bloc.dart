import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/backend/game_data/game_data_provider.dart';
import 'package:tic_tac_toe/bloc/web_connection_bloc/connection_event.dart';
import 'package:tic_tac_toe/bloc/web_connection_bloc/connection_state.dart';
import 'package:tic_tac_toe/data_models/room.dart';

/// Handles all WebSocket-related connection events such as room creation, joining, and disconnection.
class ConnectionBloc extends Bloc<ConnectionEvent, NetworkConnectionState> {
  final GameDataProvider _provider;

  ConnectionBloc(this._provider) : super(IdleState()) {
    on<CreateRoomRequestedEvent>(_createRoomRequestedEvent);
    on<JoinRoomRequestedEvent>(_joinRoomRequestedEvent);
    on<ConnectionLostEvent>(_connectionLostEvent);
  }

  /// Handles the flow for creating a room.
  /// Emits:
  /// - [CreatingRoomState] during room creation
  /// - [RoomCreatedSuccessfullyState] on success
  /// - [ConnectionErrorState] on failure
  FutureOr<void> _createRoomRequestedEvent(
    CreateRoomRequestedEvent event,
    Emitter<NetworkConnectionState> emit,
  ) async {
    emit(CreatingRoomState());
    print("[ConnectionBloc] Creating a room...");

    try {
      final room = await _provider.createRoom();
      print("[ConnectionBloc] Room created with ID: ${room.roomId}");

      emit(RoomCreatedSuccessfullyState(
        roomId: room.roomId,
        provider: _provider,
      ));
    } catch (e) {
      print("[ConnectionBloc] Failed to create room: $e");
      emit(ConnectionErrorState(error: "Failed to create room. Please try again."));
    }
  }

  /// Handles the flow for joining an existing room.
  /// Emits:
  /// - [JoiningRoomState] while attempting to join
  /// - [OpponentJoinedState] on success
  /// - [ConnectionErrorState] on failure
  FutureOr<void> _joinRoomRequestedEvent(
    JoinRoomRequestedEvent event,
    Emitter<NetworkConnectionState> emit,
  ) async {
    emit(JoiningRoomState());
    print("[ConnectionBloc] Attempting to join room: ${event.roomId}");

    try {
      await _provider.joinRoom(Room(roomId: event.roomId));
      print("[ConnectionBloc] Successfully joined room ${event.roomId}");

      emit(OpponentJoinedState(provider: _provider));
    } catch (e) {
      print("[ConnectionBloc] Failed to join room: $e");
      emit(ConnectionErrorState(error: "Could not join room. Please check the room ID and try again."));
    }
  }

  /// Handles unexpected disconnections.
  /// Emits:
  /// - [DisconnectedState] with the provided reason
  FutureOr<void> _connectionLostEvent(
    ConnectionLostEvent event,
    Emitter<NetworkConnectionState> emit,
  ) {
    print("[ConnectionBloc] Connection lost: ${event.reason}");
    emit(DisconnectedState(reason: event.reason));
  }
}
