import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tic_tac_toe/bloc/game_bloc/game_bloc.dart';
import 'package:tic_tac_toe/bloc/web_connection_bloc/connection_bloc.dart';
import 'package:tic_tac_toe/bloc/web_connection_bloc/connection_event.dart';
import 'package:tic_tac_toe/bloc/web_connection_bloc/connection_state.dart';

import 'package:tic_tac_toe/utilities/join_room_alert_box.dart';
import 'package:tic_tac_toe/views/error_alert_dialog.dart';
import 'package:tic_tac_toe/views/game_view.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  bool _errorShown = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectionBloc, NetworkConnectionState>(
      listener: (context, state) async {
        // Handle successful room creation or joining
        if (state is RoomCreatedSuccessfullyState ||
            state is OpponentJoinedState) {
          final provider =
              state is RoomCreatedSuccessfullyState
                  ? state.provider
                  : (state as OpponentJoinedState).provider;

          // Navigate to game view with GameBloc injected
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider(
                    create: (_) => GameBloc(provider),
                    child: const GameView(),
                  ),
            ),
          );
        }

        // Handle error state (once)
        if (state is ConnectionErrorState && !_errorShown) {
          _errorShown = true;
          await showErrorDialogBox(context);
          _errorShown = false;
        }
      },
      child: BlocBuilder<ConnectionBloc, NetworkConnectionState>(
        builder: (context, state) {
          final isLoading =
              state is CreatingRoomState || state is JoiningRoomState;

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Tic Tac Toe",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
            body: Center(
              child:
                  isLoading
                      ? const CircularProgressIndicator()
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              context.read<ConnectionBloc>().add(
                                CreateRoomRequestedEvent(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "Create Room",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              await showJoinRoomAlertBox(context, (roomId) {
                                context.read<ConnectionBloc>().add(
                                  JoinRoomRequestedEvent(roomId: roomId),
                                );
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "Join Room",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
            ),
          );
        },
      ),
    );
  }
}
