import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/game_service.dart';
import '../../models/game_room.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  late GameService _gameService;
  late String _roomCode;
  bool _isStarting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _gameService = GameService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _roomCode = ModalRoute.of(context)!.settings.arguments as String;
  }

  Future<void> _startGame() async {
    setState(() {
      _isStarting = true;
      _errorMessage = null;
    });

    try {
      await _gameService.startGame(_roomCode);
      if (mounted) {
        Navigator.pushReplacementNamed(
          context, 
          '/game',
          arguments: _roomCode,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isStarting = false;
        });
      }
    }
  }

  Future<void> _leaveRoom() async {
    final user = context.read<AuthService>().currentUser;
    if (user != null) {
      await _gameService.leaveRoom(_roomCode, user.uid);
    }
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _copyRoomCode() {
    Clipboard.setData(ClipboardData(text: _roomCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;

    return WillPopScope(
      onWillPop: () async {
        await _leaveRoom();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Game Lobby'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: _leaveRoom,
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
                child: Text('Room not found'),
              );
            }

            final room = snapshot.data!;
            final isHost = user?.uid == room.hostId;

            // Check if game has started
            if (room.phase != GamePhase.waiting) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(
                  context, 
                  '/game',
                  arguments: _roomCode,
                );
              });
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.grey[850],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Room: ${room.name}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.content_copy),
                                onPressed: _copyRoomCode,
                                tooltip: 'Copy room code',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Code: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _roomCode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Host: ${room.players.firstWhere((p) => p.isHost).name}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Players (${room.players.length})',
                    style: const TextStyle(
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
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.shade700,
                            child: Text(
                              player.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(player.name),
                          trailing: player.isHost
                              ? const Chip(
                                  label: Text('Host'),
                                  backgroundColor: Colors.red,
                                  labelStyle: TextStyle(color: Colors.white),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (isHost)
                    ElevatedButton(
                      onPressed: _isStarting ? null : _startGame,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: _isStarting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('START GAME'),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}