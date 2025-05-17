import 'package:flutter/material.dart';
import '../../../models/game_room.dart';
import '../../../services/game_service.dart';

class NightActionWidget extends StatefulWidget {
  final GameRoom room;
  final Player currentPlayer;
  final GameService gameService;
  final String roomCode;
  // Static set to track investigated players
  static final Set<String> investigatedPlayerIds = {};

  const NightActionWidget({
    super.key,
    required this.room,
    required this.currentPlayer,
    required this.gameService,
    required this.roomCode,
  });

  @override
  State<NightActionWidget> createState() => _NightActionWidgetState();
}

class _NightActionWidgetState extends State<NightActionWidget> {
  String? _selectedPlayerId;
  bool _isSubmitting = false;

  Future<void> _submitAction() async {
    if (_selectedPlayerId == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.gameService.submitNightAction(
        widget.roomCode,
        widget.currentPlayer.id,
        widget.currentPlayer.role!,
        _selectedPlayerId!,
      );
      
      // If detective, add the investigated player to the set
      if (widget.currentPlayer.role == PlayerRole.detective) {
        NightActionWidget.investigatedPlayerIds.add(_selectedPlayerId!);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.currentPlayer.role!;
    
    // Check if action already submitted
    bool actionSubmitted = false;
    switch (role) {
      case PlayerRole.mafia:
        actionSubmitted = widget.room.mafiaTarget != null;
        break;
      case PlayerRole.detective:
        actionSubmitted = widget.room.detectiveTarget != null;
        break;
      case PlayerRole.doctor:
        actionSubmitted = widget.room.doctorTarget != null;
        break;
      default:
        break;
    }

    // Get eligible targets (alive players except self for mafia and doctor)
    final eligiblePlayers = widget.room.players.where((p) {
      if (p.status != PlayerStatus.alive) return false;
      
      if (role == PlayerRole.mafia || role == PlayerRole.doctor) {
        return p.id != widget.currentPlayer.id;
      }
      
      return true;
    }).toList();

    String actionTitle;
    String actionDescription;
    Color actionColor;
    
    switch (role) {
      case PlayerRole.mafia:
        actionTitle = 'Choose a target to eliminate';
        actionDescription = 'Select a player to eliminate tonight.';
        actionColor = Colors.red;
        break;
      case PlayerRole.detective:
        actionTitle = 'Choose a player to investigate';
        actionDescription = 'Select a player to learn their role.';
        actionColor = Colors.blue;
        break;
      case PlayerRole.doctor:
        actionTitle = 'Choose a player to save';
        actionDescription = 'Select a player to protect tonight.';
        actionColor = Colors.green;
        break;
      default:
        actionTitle = '';
        actionDescription = '';
        actionColor = Colors.grey;
    }

    if (actionSubmitted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'Your action has been submitted',
              style: TextStyle(
                fontSize: 20,
                color: actionColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Waiting for other players to complete their actions...',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            actionTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: actionColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            actionDescription,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: eligiblePlayers.length,
              itemBuilder: (context, index) {
                final player = eligiblePlayers[index];
                final isSelected = _selectedPlayerId == player.id;
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? actionColor : Colors.grey[700],
                    child: Text(
                      player.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(player.name),
                  selected: isSelected,
                  selectedTileColor: actionColor.withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      _selectedPlayerId = player.id;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _selectedPlayerId == null || _isSubmitting
                ? null
                : _submitAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              minimumSize: const Size(double.infinity, 56),
            ),
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('CONFIRM'),
          ),
        ],
      ),
    );
  }
}