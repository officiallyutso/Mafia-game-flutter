import 'package:flutter/material.dart';
import '../../../models/game_room.dart';
import '../../../services/game_service.dart';

class VotingWidget extends StatefulWidget {
  final GameRoom room;
  final Player currentPlayer;
  final GameService gameService;
  final String roomCode;

  const VotingWidget({
    super.key,
    required this.room,
    required this.currentPlayer,
    required this.gameService,
    required this.roomCode,
  });

  @override
  State<VotingWidget> createState() => _VotingWidgetState();
}

class _VotingWidgetState extends State<VotingWidget> {
  String? _selectedPlayerId;
  bool _isSubmitting = false;

  Future<void> _submitVote() async {
    if (_selectedPlayerId == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.gameService.submitVote(
        widget.roomCode,
        widget.currentPlayer.id,
        _selectedPlayerId!,
      );
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
    // Check if vote already submitted
    final hasVoted = widget.room.votes.containsKey(widget.currentPlayer.id);

    // Get eligible targets (alive players except self)
    final eligiblePlayers = widget.room.players.where((p) {
      return p.status == PlayerStatus.alive && p.id != widget.currentPlayer.id;
    }).toList();

    if (hasVoted) {
      final votedForId = widget.room.votes[widget.currentPlayer.id];
      final votedForPlayer = widget.room.players.firstWhere(
        (p) => p.id == votedForId,
        orElse: () => Player(id: '', name: 'Unknown'),
      );

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.how_to_vote,
              color: Colors.amber,
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              'You have voted for:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              votedForPlayer.name,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Waiting for other players to vote...',
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
          const Text(
            'Vote to eliminate a player',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select a player you suspect is a mafia member.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: eligiblePlayers.length,
              itemBuilder: (context, index) {
                final player = eligiblePlayers[index];
                final isSelected = _selectedPlayerId == player.id;
                
                // Count votes for this player
                final voteCount = widget.room.votes.values
                    .where((id) => id == player.id)
                    .length;
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? Colors.amber : Colors.grey[700],
                    child: Text(
                      player.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(player.name),
                  subtitle: Text('Votes: $voteCount'),
                  selected: isSelected,
                  selectedTileColor: Colors.amber.withOpacity(0.1),
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
                : _submitVote,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              minimumSize: const Size(double.infinity, 56),
            ),
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('SUBMIT VOTE'),
          ),
        ],
      ),
    );
  }
}