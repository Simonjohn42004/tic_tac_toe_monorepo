import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tic_tac_toe/utilities/app_constants.dart';
import 'package:tic_tac_toe/backend/game_data/flutter_web_socket_provider.dart';
import 'package:tic_tac_toe/backend/game_data/offline_provider.dart';
import 'package:tic_tac_toe/backend/web_socket/web_socket_client.dart';

import 'package:tic_tac_toe/bloc/game_bloc/game_bloc.dart';
import 'package:tic_tac_toe/bloc/web_connection_bloc/connection_bloc.dart';

import 'package:tic_tac_toe/views/connection_page_view.dart';
import 'package:tic_tac_toe/views/game_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Set main home page
      home: const HomePage(),

      // Define routes
      routes: {
        connectionPageRoute: (context) => const ConnectionPage(),
      },
    );
  }
}

/// Home screen with options for online/offline game
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tic Tac Toe", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "The Moving Tic Tac Toe",
              style: GoogleFonts.alkatra(
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Offline Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                final provider = OfflineGameDataProvider();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => GameBloc(provider),
                      child: const GameView(),
                    ),
                  ),
                );
              },
              child: const Text("Play Offline", style: TextStyle(fontSize: 18)),
            ),

            const SizedBox(height: 16),

            // Online Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                final provider = FlutterWebSocketProvider(
                  client: WebSocketClient(),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => ConnectionBloc(provider),
                      child: const ConnectionPage(),
                    ),
                  ),
                );
              },
              child: const Text("Play Online", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
