import 'package:flutter/material.dart';
import '../../../models/game_room.dart';

class RoleRevealWidget extends StatelessWidget {
  final Player player;
  final VoidCallback onContinue;

  const RoleRevealWidget({
    super.key,
    required this.player,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final role = player.role ?? PlayerRole.villager;
    
    String roleTitle;
    String roleDescription;
    IconData roleIcon;
    Color roleColor;
    
    switch (role) {
      case PlayerRole.mafia:
        roleTitle = 'Mafia';
        roleDescription = 'Your goal is to eliminate all villagers. Each night, you can choose one player to eliminate.';
        roleIcon = Icons.local_police;
        roleColor = Colors.red;
        break;
      case PlayerRole.detective:
        roleTitle = 'Detective';
        roleDescription = 'Your goal is to find the mafia. Each night, you can investigate one player to learn their role.';
        roleIcon = Icons.search;
        roleColor = Colors.blue;
        break;
      case PlayerRole.doctor:
        roleTitle = 'Doctor';
        roleDescription = 'Your goal is to save lives. Each night, you can protect one player from being eliminated.';
        roleIcon = Icons.medical_services;
        roleColor = Colors.green;
        break;
      case PlayerRole.villager:
        roleTitle = 'Villager';
        roleDescription = 'Your goal is to find and eliminate the mafia through discussion and voting.';
        roleIcon = Icons.person;
        roleColor = Colors.orange;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your Role',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            CircleAvatar(
              radius: 60,
              backgroundColor: roleColor,
              child: Icon(
                roleIcon,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              roleTitle,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: roleColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              roleDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: roleColor,
                minimumSize: const Size(200, 56),
              ),
              child: const Text(
                'CONTINUE',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}