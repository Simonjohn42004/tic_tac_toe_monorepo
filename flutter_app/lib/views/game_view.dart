import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tic_tac_toe/bloc/game_bloc/game_bloc.dart';
import 'package:tic_tac_toe/bloc/game_bloc/game_event.dart';
import 'package:tic_tac_toe/bloc/game_bloc/game_state.dart';
import 'package:tic_tac_toe/data_models/player.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  @override
  Widget build(BuildContext context) {
    // Safely attempt to read GameBloc and log failure if not found
    try {
      final bloc = context.watch<GameBloc>();
      debugPrint("GameBloc found: $bloc");
    } catch (e) {
      debugPrint("Error: GameBloc not found in GameView -> $e");
      // Consider showing a fallback screen or alert if needed
    }

    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        // Determine game title based on state
        String gameTitle = switch (state) {
          GameOnGoingState s => s.isNextPlayerX ? "Player X turn" : "Player O turn",
          InitialiseGameState _ => "Player X turn",
          GameDrawState _ => "Game Draw! Play again?",
          GameWinState s => s.player == Player.x ? "Player X won" : "Player O won",
          _ => "Loading...",
        };

        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Tic Tac Toe"),
            centerTitle: true,
            backgroundColor: Colors.green,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  gameTitle,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                // Game board (3x3 grid)
                SizedBox(
                  height: screenHeight * 0.4,
                  width: screenWidth * 0.9,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      final gameBoard = state.gameBoard;

                      final symbol = index < gameBoard.length
                          ? gameBoard[index].symbol
                          : "";

                      final isWinningBox = state is GameWinState &&
                          state.winingIndices.contains(index);

                      final isPendingRemoval = state is GameOnGoingState &&
                          state.pendingRemovalBox == index;

                      return GestureDetector(
                        onTap: () {
                          context.read<GameBloc>().add(
                                OnBoxTappedEvent(index: index),
                              );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            color: isWinningBox
                                ? Colors.green
                                : Colors.grey[300],
                          ),
                          child: Center(
                            child: Text(
                              symbol,
                              style: GoogleFonts.balooDa2(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: isPendingRemoval ? Colors.red : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),

                // Reset button
                ElevatedButton(
                  onPressed: () {
                    context.read<GameBloc>().add(GameResetEvent());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
