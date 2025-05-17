import 'package:flutter/material.dart';
import '../../../models/game_room.dart';

class PlayerListWidget extends StatelessWidget {
  final GameRoom room;
  final String currentPlayerId;

  const PlayerListWidget({
    super.key,
    required this.room,
    required this.currentPlayerId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Players',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: room.players.length,
              itemBuilder: (context, index) {
                final player = room.players[index];
                final isCurrentPlayer = player.id == currentPlayerId;
                
                // Get player role info if the player is dead or current player
                String? roleText;
                IconData? roleIcon;
                Color roleColor = Colors.grey;
                
                if (player.status == PlayerStatus.dead || isCurrentPlayer) {
                  switch (player.role) {
                    case PlayerRole.mafia:
                      roleText = 'Mafia';
                      roleIcon = Icons.local_police;
                      roleColor = Colors.red;
                      break;
                    case PlayerRole.detective:
                      roleText = 'Detective';
                      roleIcon = Icons.search;
                      roleColor = Colors.blue;
                      break;
                    case PlayerRole.doctor:
                      roleText = 'Doctor';
                      roleIcon = Icons.medical_services;
                      roleColor = Colors.green;
                      break;
                    case PlayerRole.villager:
                      roleText = 'Villager';
                      roleIcon = Icons.person;
                      roleColor = Colors.orange;
                      break;
                    default:
                      roleText = null;
                      roleIcon = null;
                  }
                }
                
                return Card(
                  color: isCurrentPlayer ? Colors.grey[800] : Colors.grey[850],
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: player.status == PlayerStatus.dead 
                          ? Colors.grey 
                          : Colors.red.shade700,
                      child: Text(
                        player.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          decoration: player.status == PlayerStatus.dead 
                              ? TextDecoration.lineThrough 
                              : null,
                        ),
                      ),
                    ),
                    title: Text(
                      player.name,
                      style: TextStyle(
                        fontWeight: isCurrentPlayer ? FontWeight.bold : null,
                        decoration: player.status == PlayerStatus.dead 
                            ? TextDecoration.lineThrough 
                            : null,
                      ),
                    ),
                    subtitle: roleText != null 
                        ? Row(
                            children: [
                              Icon(roleIcon, size: 14, color: roleColor),
                              const SizedBox(width: 4),
                              Text(
                                roleText,
                                style: TextStyle(color: roleColor),
                              ),
                            ],
                          ) 
                        : null,
                    trailing: player.status == PlayerStatus.dead 
                        ? const Icon(Icons.close, color: Colors.red) 
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}