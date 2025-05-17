import 'package:cloud_firestore/cloud_firestore.dart';

enum GamePhase {
  waiting,
  night,
  day,
  voting,
  gameOver,
}

enum PlayerRole {
  villager,
  mafia,
  detective,
  doctor,
}

enum PlayerStatus {
  alive,
  dead,
}

class Player {
  final String id;
  final String name;
  PlayerRole? role;
  PlayerStatus status;
  bool isHost;
  
  Player({
    required this.id,
    required this.name,
    this.role,
    this.status = PlayerStatus.alive,
    this.isHost = false,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role?.toString().split('.').last,
      'status': status.toString().split('.').last,
      'isHost': isHost,
    };
  }
  
  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      name: map['name'],
      role: map['role'] != null 
          ? PlayerRole.values.firstWhere(
              (e) => e.toString() == 'PlayerRole.${map['role']}',
              orElse: () => PlayerRole.villager,
            )
          : null,
      status: PlayerStatus.values.firstWhere(
        (e) => e.toString() == 'PlayerStatus.${map['status']}',
        orElse: () => PlayerStatus.alive,
      ),
      isHost: map['isHost'] ?? false,
    );
  }
}

class GameRoom {
  final String? id;
  final String name;
  final String hostId;
  final int mafiaCount;
  final int detectiveCount;
  final int doctorCount;
  final int dayTimeSeconds;
  final int nightTimeSeconds;
  final int voteTimeSeconds;
  final List<Player> players;
  GamePhase phase;
  int? phaseEndTime;
  String? mafiaTarget;
  String? doctorTarget;
  String? detectiveTarget;
  Map<String, String> votes;
  
  GameRoom({
    this.id,
    required this.name,
    required this.hostId,
    required this.mafiaCount,
    required this.detectiveCount,
    required this.doctorCount,
    required this.dayTimeSeconds,
    required this.nightTimeSeconds,
    required this.voteTimeSeconds,
    required this.players,
    this.phase = GamePhase.waiting,
    this.phaseEndTime,
    this.mafiaTarget,
    this.doctorTarget,
    this.detectiveTarget,
    Map<String, String>? votes,
  }) : votes = votes ?? {};
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'hostId': hostId,
      'mafiaCount': mafiaCount,
      'detectiveCount': detectiveCount,
      'doctorCount': doctorCount,
      'dayTimeSeconds': dayTimeSeconds,
      'nightTimeSeconds': nightTimeSeconds,
      'voteTimeSeconds': voteTimeSeconds,
      'players': players.map((p) => p.toMap()).toList(),
      'phase': phase.toString().split('.').last,
      'phaseEndTime': phaseEndTime,
      'mafiaTarget': mafiaTarget,
      'doctorTarget': doctorTarget,
      'detectiveTarget': detectiveTarget,
      'votes': votes,
    };
  }
  
  factory GameRoom.fromMap(Map<String, dynamic> map, String id) {
    return GameRoom(
      id: id,
      name: map['name'],
      hostId: map['hostId'],
      mafiaCount: map['mafiaCount'],
      detectiveCount: map['detectiveCount'],
      doctorCount: map['doctorCount'],
      dayTimeSeconds: map['dayTimeSeconds'],
      nightTimeSeconds: map['nightTimeSeconds'],
      voteTimeSeconds: map['voteTimeSeconds'],
      players: (map['players'] as List)
          .map((p) => Player.fromMap(p))
          .toList(),
      phase: GamePhase.values.firstWhere(
        (e) => e.toString() == 'GamePhase.${map['phase']}',
        orElse: () => GamePhase.waiting,
      ),
      phaseEndTime: map['phaseEndTime'],
      mafiaTarget: map['mafiaTarget'],
      doctorTarget: map['doctorTarget'],
      detectiveTarget: map['detectiveTarget'],
      votes: Map<String, String>.from(map['votes'] ?? {}),
    );
  }
  
  factory GameRoom.fromDocument(DocumentSnapshot doc) {
    return GameRoom.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}