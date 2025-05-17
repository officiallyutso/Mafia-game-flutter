import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/game_service.dart';
import '../../models/game_room.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomCodeController = TextEditingController();
  bool _isJoining = false;
  String? _errorMessage;

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isJoining = true;
        _errorMessage = null;
      });

      try {
        final user = context.read<AuthService>().currentUser;
        if (user == null) {
          throw Exception('You must be logged in to join a room');
        }

        final gameService = GameService();
        final roomCode = _roomCodeController.text.trim();
        
        await gameService.joinRoom(
          roomCode,
          Player(
            id: user.uid,
            name: user.email?.split('@').first ?? 'Player',
          ),
        );

        if (mounted) {
          Navigator.pushReplacementNamed(
            context, 
            '/lobby',
            arguments: roomCode,
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isJoining = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Room'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.meeting_room,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _roomCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Room Code',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a room code';
                    }
                    if (value.length != 6) {
                      return 'Room code must be 6 digits';
                    }
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isJoining ? null : _joinRoom,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: _isJoining
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('JOIN ROOM'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}