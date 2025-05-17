import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/game_service.dart';
import '../../models/game_room.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomNameController = TextEditingController();
  
  int _mafiaCount = 1;
  int _detectiveCount = 1;
  int _doctorCount = 1;
  int _dayTimeSeconds = 120;
  int _nightTimeSeconds = 30;
  int _voteTimeSeconds = 30;
  
  bool _isCreating = false;
  String? _errorMessage;

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCreating = true;
        _errorMessage = null;
      });

      try {
        final user = context.read<AuthService>().currentUser;
        if (user == null) {
          throw Exception('You must be logged in to create a room');
        }

        final gameService = GameService();
        final roomCode = await gameService.createRoom(
          GameRoom(
            name: _roomNameController.text.trim(),
            hostId: user.uid,
            mafiaCount: _mafiaCount,
            detectiveCount: _detectiveCount,
            doctorCount: _doctorCount,
            dayTimeSeconds: _dayTimeSeconds,
            nightTimeSeconds: _nightTimeSeconds,
            voteTimeSeconds: _voteTimeSeconds,
            players: [
              Player(
                id: user.uid,
                name: user.email?.split('@').first ?? 'Player',
                isHost: true,
              ),
            ],
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
            _isCreating = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Room'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _roomNameController,
                decoration: const InputDecoration(
                  labelText: 'Room Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a room name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Game Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildRoleCountSetting(
                'Mafia',
                _mafiaCount,
                (value) => setState(() => _mafiaCount = value),
              ),
              _buildRoleCountSetting(
                'Detective',
                _detectiveCount,
                (value) => setState(() => _detectiveCount = value),
              ),
              _buildRoleCountSetting(
                'Doctor',
                _doctorCount,
                (value) => setState(() => _doctorCount = value),
              ),
              const SizedBox(height: 24),
              const Text(
                'Time Settings (seconds)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTimeSlider(
                'Day Discussion Time',
                _dayTimeSeconds,
                0, //////////////////CHANGE KARNA HOGA YE TOH
                300,
                (value) => setState(() => _dayTimeSeconds = value),
              ),
              _buildTimeSlider(
                'Night Action Time',
                _nightTimeSeconds,
                15,
                60,
                (value) => setState(() => _nightTimeSeconds = value),
              ),
              _buildTimeSlider(
                'Voting Time',
                _voteTimeSeconds,
                15,
                60,
                (value) => setState(() => _voteTimeSeconds = value),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isCreating ? null : _createRoom,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: _isCreating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('CREATE ROOM'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCountSetting(
    String role,
    int value,
    Function(int) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$role Count:',
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Text(
            '$value',
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlider(
    String label,
    int value,
    int min,
    int max,
    Function(int) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: $value seconds',
            style: const TextStyle(fontSize: 16),
          ),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: (max - min) ~/ 15,
            label: '$value seconds',
            onChanged: (double newValue) {
              onChanged(newValue.round());
            },
          ),
        ],
      ),
    );
  }
}