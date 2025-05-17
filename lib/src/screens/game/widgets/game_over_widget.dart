import 'package:flutter/material.dart';
import '../../../models/game_room.dart';

class GameOverWidget extends StatelessWidget {
  final GameRoom room;
  final VoidCallback onPlayAgain;

  const GameOverWidget({
    super.key,
    required this.room,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    // Check if mafia won by looking at the game state
    final alivePlayers = room.players.where((p) => p.status == PlayerStatus.alive).toList();
    final aliveMafia = alivePlayers.where((p) => p.role == PlayerRole.mafia).length;
    final aliveVillagers = alivePlayers.length - aliveMafia;
    
    // Mafia wins if they equal or outnumber the villagers
    final isMafiaWin = aliveMafia >= aliveVillagers && aliveMafia > 0;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isMafiaWin ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            Icon(
              isMafiaWin ? Icons.local_police : Icons.people,
              size: 80,
              color: isMafiaWin ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              '${isMafiaWin ? 'Mafia' : 'Villagers'} Win!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isMafiaWin ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              'Player Roles:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: room.players.length,
                itemBuilder: (context, index) {
                  final player = room.players[index];
                  
                  String roleText;
                  IconData roleIcon;
                  Color roleColor;
                  
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
                      roleText = 'Unknown';
                      roleIcon = Icons.question_mark;
                      roleColor = Colors.grey;
                  }
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: roleColor,
                      child: Icon(roleIcon, color: Colors.white, size: 20),
                    ),
                    title: Text(player.name),
                    subtitle: Text(roleText),
                    trailing: player.status == PlayerStatus.dead
                        ? const Icon(Icons.close, color: Colors.red)
                        : const Icon(Icons.check, color: Colors.green),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPlayAgain,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 56),
              ),
              child: const Text(
                'PLAY AGAIN',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}