import 'package:flutter/material.dart';

Future<void> showJoinRoomAlertBox(
  BuildContext context,
  void Function(int roomId) onPressed,
) {
  final TextEditingController textController = TextEditingController();

  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Join Room"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter the Room ID"),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: "Room ID",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final input = textController.text.trim();
              final roomId = int.tryParse(input);
              if (roomId != null) {
                Navigator.of(context).pop(); // Close the dialog
                onPressed(roomId);
              } else {
                // Show error or shake dialog, depending on UX needs
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid number')),
                );
              }
            },
            child: const Text("OK"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cancel
            child: const Text("Cancel"),
          ),
        ],
      );
    },
  );
}
