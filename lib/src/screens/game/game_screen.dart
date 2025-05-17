import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/game_service.dart';
import '../../models/game_room.dart';
import 'widgets/role_reveal_widget.dart';
import 'widgets/night_action_widget.dart';
import 'widgets/day_discussion_widget.dart';
import 'widgets/voting_widget.dart';
import 'widgets/game_over_widget.dart';
import 'widgets/player_list_widget.dart';
import 'widgets/chat_widget.dart';
import 'widgets/timer_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameService _gameService;
  late String _roomCode;
  late Timer _phaseTimer;
  bool _showRoleReveal = true;
  bool _showPlayerList = false; // Add this to toggle player list visibility

  @override
  void initState() {
    super.initState();
    _gameService = GameService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _roomCode = ModalRoute.of(context)!.settings.arguments as String;
    _startPhaseTimer();
  }

  @override
  void dispose() {
    _phaseTimer.cancel();
    super.dispose();
  }

  void _startPhaseTimer() {
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkPhaseEnd();
    });
  }

  Future<void> _checkPhaseEnd() async {
    final roomSnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(_roomCode)
        .get();
    
    if (!roomSnapshot.exists) {
      return;
    }
    
    final room = GameRoom.fromDocument(roomSnapshot);
    
    if (room.phaseEndTime == null) {
      return;
    }
    
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (now >= room.phaseEndTime!) {
      await _gameService.processPhaseEnd(_roomCode);
    }
  }

  void _hideRoleReveal() {
    setState(() {
      _showRoleReveal = false;
    });
  }

  Future<void> _leaveGame() async {
    final user = context.read<AuthService>().currentUser;
    if (user != null) {
      await _gameService.leaveRoom(_roomCode, user.uid);
    }
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('You must be logged in to play'),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        await _leaveGame();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mafia Game'),
          automaticallyImplyLeading: false,
          actions: [
            // Add a button to toggle player list
            IconButton(
              icon: const Icon(Icons.people),
              onPressed: () {
                setState(() {
                  _showPlayerList = !_showPlayerList;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: _leaveGame,
            ),
          ],
        ),
        body: StreamBuilder<GameRoom>(
          stream: _gameService.roomStream(_roomCode),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text('Game not found'),
              );
            }

            final room = snapshot.data!;
            final currentPlayer = room.players.firstWhere(
              (p) => p.id == user.uid,
              orElse: () => Player(id: user.uid, name: user.email?.split('@').first ?? 'Player'),
            );

            // Show role reveal at the start of the game
            if (_showRoleReveal && currentPlayer.role != null) {
              return RoleRevealWidget(
                player: currentPlayer,
                onContinue: _hideRoleReveal,
              );
            }

            // Use Stack for mobile layout with overlay for player list
            return Stack(
              children: [
                // Main game content
                Column(
                  children: [
                    // Game info and timer
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.grey[850],
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Phase: ${room.phase.toString().split('.').last.toUpperCase()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (room.phaseEndTime != null)
                            TimerWidget(endTime: room.phaseEndTime!),
                        ],
                      ),
                    ),
                    
                    // Main game content
                    Expanded(
                      child: _buildGameContent(room, currentPlayer),
                    ),
                  ],
                ),
                
                // Player list overlay (conditionally shown)
                if (_showPlayerList)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                    child: GestureDetector(
                      onTap: () {}, // Prevent taps from passing through
                      child: Container(
                        color: Colors.black.withOpacity(0.9),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Players',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _showPlayerList = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: PlayerListWidget(
                                room: room,
                                currentPlayerId: currentPlayer.id,
                                investigatedPlayerIds: NightActionWidget.investigatedPlayerIds,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameContent(GameRoom room, Player currentPlayer) {
    // Check if player is dead
    final isDead = currentPlayer.status == PlayerStatus.dead;
    
    switch (room.phase) {
      case GamePhase.night:
        if (isDead) {
          return const Center(
            child: Text(
              'You are dead. Wait for the game to continue.',
              style: TextStyle(fontSize: 18),
            ),
          );
        }
        
        // Night actions for special roles
        if (currentPlayer.role == PlayerRole.mafia ||
            currentPlayer.role == PlayerRole.detective ||
            currentPlayer.role == PlayerRole.doctor) {
          return NightActionWidget(
            room: room,
            currentPlayer: currentPlayer,
            gameService: _gameService,
            roomCode: _roomCode,
          );
        } else {
          return const Center(
            child: Text(
              'It\'s night time. Wait for special roles to take their actions.',
              style: TextStyle(fontSize: 18),
            ),
          );
        }
        
      case GamePhase.day:
        return DayDiscussionWidget(
          room: room,
          currentPlayer: currentPlayer,
          gameService: _gameService,
          roomCode: _roomCode,
        );
        
      case GamePhase.voting:
        if (isDead) {
          return const Center(
            child: Text(
              'You are dead. Wait for the voting to complete.',
              style: TextStyle(fontSize: 18),
            ),
          );
        }
        
        return VotingWidget(
          room: room,
          currentPlayer: currentPlayer,
          gameService: _gameService,
          roomCode: _roomCode,
        );
        
      case GamePhase.gameOver:
        return GameOverWidget(
          room: room,
          onPlayAgain: _leaveGame,
        );
        
      default:
        return const Center(
          child: Text('Waiting for game to start...'),
        );
    }
  }
}