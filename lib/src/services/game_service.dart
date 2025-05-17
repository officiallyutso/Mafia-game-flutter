import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_room.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  CollectionReference get _roomsCollection => _firestore.collection('rooms');
  CollectionReference get _messagesCollection => _firestore.collection('messages');
  
  // Generate a random 6-digit room code
  String _generateRoomCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
  
  // Create a new game room
  Future<String> createRoom(GameRoom room) async {
    // Generate a unique room code
    String roomCode = _generateRoomCode();
    bool isUnique = false;
    
    // Ensure the room code is unique
    while (!isUnique) {
      final existingRoom = await _roomsCollection.doc(roomCode).get();
      if (!existingRoom.exists) {
        isUnique = true;
      } else {
        roomCode = _generateRoomCode();
      }
    }
    
    // Save the room to Firestore
    await _roomsCollection.doc(roomCode).set(room.toMap());
    
    return roomCode;
  }
  
  // Join an existing room
  Future<GameRoom> joinRoom(String roomCode, Player player) async {
    final roomDoc = await _roomsCollection.doc(roomCode).get();
    
    if (!roomDoc.exists) {
      throw Exception('Room not found');
    }
    
    final room = GameRoom.fromDocument(roomDoc);
    
    // Check if the game has already started
    if (room.phase != GamePhase.waiting) {
      throw Exception('Game has already started');
    }
    
    // Add the player to the room
    final updatedPlayers = [...room.players, player];
    
    await _roomsCollection.doc(roomCode).update({
      'players': updatedPlayers.map((p) => p.toMap()).toList(),
    });
    
    return room.copyWith(players: updatedPlayers);
  }
  
  // Leave a room
  Future<void> leaveRoom(String roomCode, String playerId) async {
    final roomDoc = await _roomsCollection.doc(roomCode).get();
    
    if (!roomDoc.exists) {
      return;
    }
    
    final room = GameRoom.fromDocument(roomDoc);
    
    // Remove the player from the room
    final updatedPlayers = room.players.where((p) => p.id != playerId).toList();
    
    // If no players left, delete the room
    if (updatedPlayers.isEmpty) {
      await _roomsCollection.doc(roomCode).delete();
      return;
    }
    
    // If the host is leaving, assign a new host
    if (room.hostId == playerId && updatedPlayers.isNotEmpty) {
      final newHost = updatedPlayers.first;
      newHost.isHost = true;
      
      await _roomsCollection.doc(roomCode).update({
        'players': updatedPlayers.map((p) => p.toMap()).toList(),
        'hostId': newHost.id,
      });
    } else {
      await _roomsCollection.doc(roomCode).update({
        'players': updatedPlayers.map((p) => p.toMap()).toList(),
      });
    }
  }
  
  // Start the game
  Future<void> startGame(String roomCode) async {
    final roomDoc = await _roomsCollection.doc(roomCode).get();
    
    if (!roomDoc.exists) {
      throw Exception('Room not found');
    }
    
    final room = GameRoom.fromDocument(roomDoc);
    
    // Check if there are enough players
    final minPlayers = room.mafiaCount + room.detectiveCount + room.doctorCount + 1;
    if (room.players.length < minPlayers) {
      throw Exception('Not enough players to start the game');
    }
    
    // Assign roles to players
    final players = List<Player>.from(room.players);
    players.shuffle();
    
    int mafiaAssigned = 0;
    int detectiveAssigned = 0;
    int doctorAssigned = 0;
    
    for (var i = 0; i < players.length; i++) {
      if (mafiaAssigned < room.mafiaCount) {
        players[i].role = PlayerRole.mafia;
        mafiaAssigned++;
      } else if (detectiveAssigned < room.detectiveCount) {
        players[i].role = PlayerRole.detective;
        detectiveAssigned++;
      } else if (doctorAssigned < room.doctorCount) {
        players[i].role = PlayerRole.doctor;
        doctorAssigned++;
      } else {
        players[i].role = PlayerRole.villager;
      }
    }
    
    // Start with night phase
    final now = DateTime.now().millisecondsSinceEpoch;
    final phaseEndTime = now + (room.nightTimeSeconds * 1000);
    
    await _roomsCollection.doc(roomCode).update({
      'players': players.map((p) => p.toMap()).toList(),
      'phase': GamePhase.night.toString().split('.').last,
      'phaseEndTime': phaseEndTime,
    });
  }
  
  // Get a stream of room updates
  Stream<GameRoom> roomStream(String roomCode) {
    return _roomsCollection.doc(roomCode).snapshots().map(
          (snapshot) => GameRoom.fromDocument(snapshot),
        );
  }
  
  // Submit a night action (mafia, detective, doctor)
  Future<void> submitNightAction(
    String roomCode,
    String playerId,
    PlayerRole role,
    String targetId,
  ) async {
    final field = role == PlayerRole.mafia
        ? 'mafiaTarget'
        : role == PlayerRole.doctor
            ? 'doctorTarget'
            : 'detectiveTarget';
    
    await _roomsCollection.doc(roomCode).update({
      field: targetId,
    });
  }
  
  // Submit a vote during voting phase
  Future<void> submitVote(
    String roomCode,
    String voterId,
    String targetId,
  ) async {
    await _roomsCollection.doc(roomCode).update({
      'votes.$voterId': targetId,
    });
  }
  
  // Process the end of a phase
  Future<void> processPhaseEnd(String roomCode) async {
    final roomDoc = await _roomsCollection.doc(roomCode).get();
    
    if (!roomDoc.exists) {
      return;
    }
    
    final room = GameRoom.fromDocument(roomDoc);
    
    switch (room.phase) {
      case GamePhase.night:
        await _processNightEnd(roomCode, room);
        break;
      case GamePhase.day:
        await _processDayEnd(roomCode, room);
        break;
      case GamePhase.voting:
        await _processVotingEnd(roomCode, room);
        break;
      default:
        break;
    }
  }
  
  // Process the end of night phase
  Future<void> _processNightEnd(String roomCode, GameRoom room) async {
    final players = List<Player>.from(room.players);
    
    // Process mafia kill
    if (room.mafiaTarget != null) {
      // Check if doctor saved the target
      if (room.mafiaTarget != room.doctorTarget) {
        final targetIndex = players.indexWhere((p) => p.id == room.mafiaTarget);
        if (targetIndex != -1) {
          players[targetIndex].status = PlayerStatus.dead;
        }
      }
    }
    
    // Move to day phase
    final now = DateTime.now().millisecondsSinceEpoch;
    final phaseEndTime = now + (room.dayTimeSeconds * 1000);
    
    await _roomsCollection.doc(roomCode).update({
      'players': players.map((p) => p.toMap()).toList(),
      'phase': GamePhase.day.toString().split('.').last,
      'phaseEndTime': phaseEndTime,
      'mafiaTarget': null,
      'doctorTarget': null,
      'detectiveTarget': null,
    });
    
    // Check if game is over
    await _checkGameOver(roomCode, players);
  }
  
  // Process the end of day phase
  Future<void> _processDayEnd(String roomCode, GameRoom room) async {
    // Move to voting phase
    final now = DateTime.now().millisecondsSinceEpoch;
    final phaseEndTime = now + (room.voteTimeSeconds * 1000);
    
    await _roomsCollection.doc(roomCode).update({
      'phase': GamePhase.voting.toString().split('.').last,
      'phaseEndTime': phaseEndTime,
      'votes': {},
    });
  }
  
  // Process the end of voting phase
  Future<void> _processVotingEnd(String roomCode, GameRoom room) async {
    final players = List<Player>.from(room.players);
    
    // Count votes
    final voteCounts = <String, int>{};
    room.votes.forEach((_, targetId) {
      voteCounts[targetId] = (voteCounts[targetId] ?? 0) + 1;
    });
    
    // Find the player with the most votes
    String? eliminatedId;
    int maxVotes = 0;
    
    voteCounts.forEach((playerId, count) {
      if (count > maxVotes) {
        maxVotes = count;
        eliminatedId = playerId;
      } else if (count == maxVotes) {
        // Tie - no elimination
        eliminatedId = null;
      }
    });
    
    // Eliminate the player if there was a clear majority
    if (eliminatedId != null) {
      final targetIndex = players.indexWhere((p) => p.id == eliminatedId);
      if (targetIndex != -1) {
        players[targetIndex].status = PlayerStatus.dead;
      }
    }
    
    // Move to night phase
    final now = DateTime.now().millisecondsSinceEpoch;
    final phaseEndTime = now + (room.nightTimeSeconds * 1000);
    
    await _roomsCollection.doc(roomCode).update({
      'players': players.map((p) => p.toMap()).toList(),
      'phase': GamePhase.night.toString().split('.').last,
      'phaseEndTime': phaseEndTime,
      'votes': {},
    });
    
    // Check if game is over
    await _checkGameOver(roomCode, players);
  }
  
  // Check if the game is over
  Future<void> _checkGameOver(String roomCode, List<Player> players) async {
    final alivePlayers = players.where((p) => p.status == PlayerStatus.alive).toList();
    final aliveMafia = alivePlayers.where((p) => p.role == PlayerRole.mafia).length;
    final aliveVillagers = alivePlayers.length - aliveMafia;
    
    // Game over conditions
    bool isGameOver = false;
    String? winningTeam;
    
    // Mafia wins if they equal or outnumber the villagers
    if (aliveMafia >= aliveVillagers) {
      isGameOver = true;
      winningTeam = 'mafia';
    }
    
    // Villagers win if all mafia are eliminated
    if (aliveMafia == 0) {
      isGameOver = true;
      winningTeam = 'villagers';
    }
    
    if (isGameOver) {
      await _roomsCollection.doc(roomCode).update({
        'phase': GamePhase.gameOver.toString().split('.').last,
        'winningTeam': winningTeam,
      });
    }
  }
  
  // Send a chat message
  Future<void> sendMessage(String roomCode, String senderId, String senderName, String message) async {
    await _messagesCollection.add({
      'roomCode': roomCode,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  
  // Get chat messages stream
  Stream<QuerySnapshot> messagesStream(String roomCode) {
    return _messagesCollection
        .where('roomCode', isEqualTo: roomCode)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}

// Extension to make copying GameRoom easier
extension GameRoomExtension on GameRoom {
  GameRoom copyWith({
    String? id,
    String? name,
    String? hostId,
    int? mafiaCount,
    int? detectiveCount,
    int? doctorCount,
    int? dayTimeSeconds,
    int? nightTimeSeconds,
    int? voteTimeSeconds,
    List<Player>? players,
    GamePhase? phase,
    int? phaseEndTime,
    String? mafiaTarget,
    String? doctorTarget,
    String? detectiveTarget,
    Map<String, String>? votes,
  }) {
    return GameRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      hostId: hostId ?? this.hostId,
      mafiaCount: mafiaCount ?? this.mafiaCount,
      detectiveCount: detectiveCount ?? this.detectiveCount,
      doctorCount: doctorCount ?? this.doctorCount,
      dayTimeSeconds: dayTimeSeconds ?? this.dayTimeSeconds,
      nightTimeSeconds: nightTimeSeconds ?? this.nightTimeSeconds,
      voteTimeSeconds: voteTimeSeconds ?? this.voteTimeSeconds,
      players: players ?? this.players,
      phase: phase ?? this.phase,
      phaseEndTime: phaseEndTime ?? this.phaseEndTime,
      mafiaTarget: mafiaTarget ?? this.mafiaTarget,
      doctorTarget: doctorTarget ?? this.doctorTarget,
      detectiveTarget: detectiveTarget ?? this.detectiveTarget,
      votes: votes ?? this.votes,
    );
  }
}