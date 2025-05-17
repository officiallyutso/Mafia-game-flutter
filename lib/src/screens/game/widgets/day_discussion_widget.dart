import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/game_room.dart';
import '../../../services/game_service.dart';
import 'player_list_widget.dart';
import 'chat_widget.dart';

class DayDiscussionWidget extends StatelessWidget {
  final GameRoom room;
  final Player currentPlayer;
  final GameService gameService;
  final String roomCode;

  const DayDiscussionWidget({
    super.key,
    required this.room,
    required this.currentPlayer,
    required this.gameService,
    required this.roomCode,
  });

  @override
  Widget build(BuildContext context) {
    final isDead = currentPlayer.status == PlayerStatus.dead;

    return Column(
      children: [
        // Chat takes full height now
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: gameService.messagesStream(roomCode),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              return ChatWidget(
                messages: snapshot.data?.docs ?? [],
                currentPlayerId: currentPlayer.id,
                gameService: gameService,
                roomCode: roomCode,
                isDisabled: isDead,
                hintText: isDead 
                    ? 'You are dead and cannot participate in discussion' 
                    : 'Type your message...',
              );
            },
          ),
        ),
      ],
    );
  }
}