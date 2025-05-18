
<div align="center">
  <img src="https://github.com/user-attachments/assets/1a9873af-2b09-4b36-9844-aca31d7a1ec7" alt="Mafia Game Logo" width="100">
</div>

# 🎭 Mafia Party Game

[![Flutter Version](https://img.shields.io/badge/Flutter-≥3.0.0-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/github/license/officiallyutso/Mafia-game-flutter)](https://github.com/officiallyutso/Mafia-game-flutter/blob/main/LICENSE)
[![Contributions Welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg)](https://github.com/officiallyutso/Mafia-game-flutter/issues)


<div align="center">
  <img src="https://github.com/user-attachments/assets/7c9062c7-9d24-4b0e-8c0c-b176eadc4aee" alt="Mafia Game Feature Graphic" width="600">
</div>

<div align="center">
  <img src="https://github.com/user-attachments/assets/60a89473-98de-44b8-af5d-841b3c70a608" alt="Mafia Game Screenshots" width="800">
</div>

## Table of Contents

1. [Introduction](#-introduction)
2. [Features](#-features)
3. [Game Rules](#-game-rules)
4. [Technology Stack](#-technology-stack)
5. [Architecture](#-architecture)
6. [Database Structure](#-database-structure)
7. [Installation](#-installation)
8. [Usage](#-usage)
9. [Code Structure](#-code-structure)
10. [Implementation Details](#-implementation-details)
11. [Game Logic & Flow](#-game-logic--flow)
12. [State Management](#-state-management)
13. [Firebase Integration](#-firebase-integration)
14. [UI/UX Design](#-uiux-design)
15. [Performance Optimizations](#-performance-optimizations)
16. [Testing](#-testing)
17. [Deployment](#-deployment)
18. [Future Enhancements](#-future-enhancements)
19. [Contributing](#-contributing)
20. [License](#-license)
21. [Contact](#-contact)
22. [Acknowledgements](#-acknowledgements)

## Introduction

**Mafia Party Game** is a digital implementation of the classic social deduction party game "Mafia" (also known as "Werewolf"). It's designed for mobile platforms using Flutter and Firebase, allowing friends to play together remotely. The game features real-time multiplayer functionality, role assignment, day/night cycles, voting mechanisms, and chat communication.

This project demonstrates advanced Flutter development techniques, Firebase integration, real-time database usage, state management with providers and BLoC, and creating an engaging multiplayer experience.

## Features

- **Real-time multiplayer gameplay** - Play with friends from anywhere
- **Room-based system** - Create and join game rooms with unique codes
- **Role assignment** - Random distribution of special roles (Mafia, Detective, Doctor)
- **Day/Night cycles** - Alternating game phases for discussion and secret actions
- **Voting system** - Democratic elimination of suspected Mafia members
- **In-game chat** - Communicate with other players during discussion phases
- **Role-specific actions** - Special abilities for Mafia, Detective, and Doctor roles
- **Customizable game settings** - Adjust number of roles and phase durations
- **Authentication system** - User accounts and profiles
- **Responsive UI** - Works on various device sizes
- **Dark theme** - Sleek, modern interface with dark aesthetics

## Game Rules

### Overview
Mafia is a social deduction game where players are secretly assigned roles: Villagers, Mafia, Detective, and Doctor. The game alternates between day and night phases. During the night, the Mafia chooses someone to eliminate, while the Doctor can save someone, and the Detective can investigate a player's identity. During the day, all players discuss and vote to eliminate a suspected Mafia member.

### Roles
- **Villagers**: Regular citizens trying to identify and eliminate the Mafia
- **Mafia**: Know each other's identities and secretly eliminate one player each night
- **Detective**: Can investigate one player each night to learn their role
- **Doctor**: Can protect one player each night from being eliminated

### Game Phases
1. **Waiting Phase**: Players join the room before the game starts
2. **Night Phase**: Special roles perform their actions secretly
3. **Day Phase**: All players discuss to identify the Mafia
4. **Voting Phase**: Players vote to eliminate a suspected Mafia member
5. **Game Over**: When either all Mafia are eliminated (Villagers win) or Mafia outnumber Villagers (Mafia win)

### Win Conditions
- **Villagers win** when all Mafia members are eliminated
- **Mafia wins** when they equal or outnumber the Villagers

## Technology Stack

### Core Framework
- **Flutter** (≥3.0.0) - Google's UI toolkit for building natively compiled applications

### Backend & Real-time Database
- **Firebase**
  - **Cloud Firestore** - For real-time game state synchronization
  - **Firebase Authentication** - For user management
  - **Firebase Core** - Base Firebase functionality

### State Management
- **Provider** - For dependency injection and lightweight state management
- **Flutter BLoC** - For more complex state management scenarios

### Key Libraries
- **firebase_core** (v2.24.2) - Essential Firebase functionality
- **firebase_auth** (v4.15.3) - User authentication
- **cloud_firestore** (v4.13.6) - Real-time database
- **provider** (v6.1.1) - State management and dependency injection
- **flutter_bloc** (v8.1.3) - Advanced state management
- **cupertino_icons** (v1.0.6) - iOS-style icons
- **js** (v0.7.1) - JavaScript interoperability (used for web version)

### Development Tools
- **flutter_test** - Testing framework
- **flutter_lints** (v3.0.1) - Code quality and style enforcement

## Architecture

### High-Level Architecture

The Mafia Game follows a clean architecture approach with separation of concerns between UI, business logic, and data layers:

```
┌───────────────┐      ┌───────────────┐      ┌───────────────┐
│  Presentation │      │    Business   │      │     Data      │
│     Layer     │◄────►│     Layer     │◄────►│     Layer     │
└───────────────┘      └───────────────┘      └───────────────┘
       UI                Game Logic &           Firebase &
    Components          State Management       Local Storage
```

### Detailed Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                       Flutter App                           │
│                                                             │
│  ┌─────────────────┐  ┌────────────────┐  ┌────────────────┐│
│  │      Routes     │  │      Theme     │  │     Widgets    ││
│  └─────────────────┘  └────────────────┘  └────────────────┘│
│                                                             │
│  ┌─────────────────┐  ┌────────────────┐  ┌────────────────┐│
│  │     Screens     │  │     Models     │  │    Services    ││
│  │                 │  │                │  │                ││
│  │  - Auth Screens │  │  - Game Room   │  │ - Auth Service ││
│  │  - Home Screen  │  │  - Player      │  │ - Game Service ││
│  │  - Game Screens │  │  - Game Phase  │  │                ││
│  └─────────────────┘  └────────────────┘  └────────────────┘│
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                State Management (Provider/BLoC)         ││
│  └─────────────────────────────────────────────────────────┘│
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                   Firebase Integration                  ││
│  │                                                         ││
│  │   ┌─────────────┐    ┌──────────────┐    ┌───────────┐  ││
│  │   │ Firestore   │    │ Auth         │    │ Firebase  │  ││
│  │   │ Database    │    │ Service      │    │ Core      │  ││
│  │   └─────────────┘    └──────────────┘    └───────────┘  ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### Dependency Flow

```
┌───────────┐     ┌───────────┐     ┌────────────┐     ┌─────────────┐
│   Routes  │────►│  Screens  │────►│  Services  │────►│  Firebase   │
└───────────┘     └───────────┘     └────────────┘     └─────────────┘
                        │                 ▲                   ▲
                        ▼                 │                   │
                  ┌───────────┐     ┌────────────┐           │
                  │  Widgets  │────►│   Models   │───────────┘
                  └───────────┘     └────────────┘
```

## Database Structure

The game uses Firebase Firestore to maintain game state across multiple clients. Here's the detailed database schema:

### Collections

#### `rooms` Collection
Each document represents a game room:

```json
{
  "name": "Room Name",
  "hostId": "userId-12345",
  "mafiaCount": 2,
  "detectiveCount": 1,
  "doctorCount": 1,
  "dayTimeSeconds": 120,
  "nightTimeSeconds": 30,
  "voteTimeSeconds": 30,
  "phase": "waiting",
  "phaseEndTime": 1621234567890,
  "mafiaTarget": "userId-abc",
  "doctorTarget": "userId-def",
  "detectiveTarget": "userId-ghi",
  "votes": {
    "userId-123": "userId-456",
    "userId-789": "userId-456"
  },
  "players": [
    {
      "id": "userId-123",
      "name": "Player1",
      "role": "mafia",
      "status": "alive",
      "isHost": true
    },
    {
      "id": "userId-456",
      "name": "Player2",
      "role": "villager",
      "status": "alive",
      "isHost": false
    }
  ]
}
```

#### `messages` Collection
Chat messages for in-game communication:

```json
{
  "roomCode": "123456",
  "senderId": "userId-123",
  "senderName": "Player1",
  "message": "I think Player2 is suspicious",
  "timestamp": "2023-05-01T12:34:56Z"
}
```

### Database Schema Visualization

```
ROOMS COLLECTION
├── document (roomCode)
│   ├── name (string)
│   ├── hostId (string)
│   ├── mafiaCount (number)
│   ├── detectiveCount (number)
│   ├── doctorCount (number)
│   ├── dayTimeSeconds (number)
│   ├── nightTimeSeconds (number)
│   ├── voteTimeSeconds (number)
│   ├── phase (string)
│   ├── phaseEndTime (timestamp)
│   ├── mafiaTarget (string/null)
│   ├── doctorTarget (string/null)
│   ├── detectiveTarget (string/null)
│   ├── votes (map)
│   │   ├── userId1 -> targetId
│   │   └── userId2 -> targetId
│   └── players (array)
│       ├── player1 (map)
│       │   ├── id (string)
│       │   ├── name (string)
│       │   ├── role (string)
│       │   ├── status (string)
│       │   └── isHost (boolean)
│       └── player2 (map)
│           └── ...
│
MESSAGES COLLECTION
├── document1
│   ├── roomCode (string)
│   ├── senderId (string)
│   ├── senderName (string)
│   ├── message (string)
│   └── timestamp (timestamp)
└── document2
    └── ...
```

### Real-time Data Flow

The application uses Firestore's real-time listeners to stay synchronized across devices:

```
┌────────────┐    ┌───────────────┐    ┌────────────┐
│ Client 1   │◄──►│   Firestore   │◄──►│  Client 2  │
│ (Player 1) │    │   Database    │    │ (Player 2) │
└────────────┘    └───────────────┘    └────────────┘
       ▲                 ▲                   ▲
       │                 │                   │
       ▼                 ▼                   ▼
┌────────────┐    ┌───────────────┐    ┌────────────┐
│ Client 3   │◄──►│   Firebase    │◄──►│  Client 4  │
│ (Player 3) │    │    Auth       │    │ (Player 4) │
└────────────┘    └───────────────┘    └────────────┘
```

## Installation

### Prerequisites
- Flutter SDK (≥3.0.0)
- Dart SDK
- Android Studio / Xcode for emulators
- Firebase project (for backend)
- Git

### Step-by-Step Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/officiallyutso/Mafia-game-flutter.git
   cd Mafia-game-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a new Firebase project at [https://console.firebase.google.com/](https://console.firebase.google.com/)
   - Add Android/iOS apps to your Firebase project
   - Download and add the configuration files:
     - `google-services.json` (for Android)
     - `GoogleService-Info.plist` (for iOS)
   - Enable Authentication (Email/Password) and Firestore Database

4. **Create Firebase Options**
   ```bash
   flutterfire configure
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Usage

### Create Account
1. Launch the app
2. Register with email and password
3. Login to your account

### Create a Game
1. Go to the "Create Room" screen
2. Set game parameters (number of Mafia, Detectives, Doctors)
3. Set time parameters for day, night, and voting phases
4. Create the room and share the room code with friends

### Join a Game
1. Select "Join Room" option
2. Enter the 6-digit room code
3. Wait for the host to start the game

### Playing the Game
1. When the game starts, you'll be assigned a role
2. During night phases, perform your role's actions if applicable
3. During day phases, discuss with other players via the chat
4. Vote during the voting phase
5. Continue until one team wins

## Code Structure

The project follows a structured organization to maintain clarity and separation of concerns:

```
mafia/
├── android/
├── ios/
├── web/
├── lib/
│   ├── main.dart                # Entry point
│   ├── firebase_options.dart    # Firebase configuration
│   ├── src/
│   │   ├── app.dart             # Root app widget
│   │   ├── routes/
│   │   │   └── routes.dart      # Navigation routes
│   │   ├── models/
│   │   │   └── game_room.dart   # Data models
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   ├── home/
│   │   │   │   └── home_screen.dart
│   │   │   └── game/
│   │   │       ├── create_room_screen.dart
│   │   │       ├── join_room_screen.dart
│   │   │       ├── lobby_screen.dart
│   │   │       ├── game_screen.dart
│   │   │       └── widgets/
│   │   │           ├── role_reveal_widget.dart
│   │   │           ├── night_action_widget.dart
│   │   │           ├── day_discussion_widget.dart
│   │   │           ├── voting_widget.dart
│   │   │           ├── game_over_widget.dart
│   │   │           ├── player_list_widget.dart
│   │   │           ├── chat_widget.dart
│   │   │           └── timer_widget.dart
│   │   └── services/
│   │       ├── auth_service.dart    # Authentication
│   │       └── game_service.dart    # Game logic
├── test/
├── pubspec.yaml
└── README.md
```

### Key Files and Their Purposes

| File | Purpose |
|------|---------|
| `main.dart` | Entry point that initializes Firebase and sets up providers |
| `app.dart` | Root widget with theme, routes, and auth state management |
| `routes.dart` | Navigation route definitions for the entire app |
| `game_room.dart` | Data models for game state and player information |
| `auth_service.dart` | Firebase authentication wrapper |
| `game_service.dart` | Game logic and Firestore operations |
| `create_room_screen.dart` | UI for creating new game rooms |
| `join_room_screen.dart` | UI for joining existing game rooms |
| `lobby_screen.dart` | Pre-game waiting room |
| `game_screen.dart` | Main game screen that changes based on game phase |

## Implementation Details

### Authentication System

The authentication system uses Firebase Authentication with email/password sign-in. The implementation is encapsulated in the `AuthService` class, which provides methods for:

```dart
// From auth_service.dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    // Implementation...
  }

  // Register with email and password
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    // Implementation...
  }

  // Sign out
  Future<void> signOut() async {
    // Implementation...
  }
}
```

The app uses a `StreamBuilder` in `app.dart` to listen to authentication state changes and redirect users accordingly:

```dart
// From app.dart
StreamBuilder(
  stream: context.read<AuthService>().authStateChanges,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.active) {
      final user = snapshot.data;
      if (user != null) {
        return const HomeScreen();
      }
      return const LoginScreen();
    }
    
    // Show loading indicator while checking auth state
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  },
)
```

### Game Service Architecture

The core game logic is implemented in the `GameService` class, which handles all interactions with the Firestore database:

```dart
// From game_service.dart
class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  CollectionReference get _roomsCollection => _firestore.collection('rooms');
  CollectionReference get _messagesCollection => _firestore.collection('messages');
  
  // Game room management methods
  Future<String> createRoom(GameRoom room) async { /* ... */ }
  Future<GameRoom> joinRoom(String roomCode, Player player) async { /* ... */ }
  Future<void> leaveRoom(String roomCode, String playerId) async { /* ... */ }
  Future<void> startGame(String roomCode) async { /* ... */ }
  
  // Game action methods
  Future<void> submitNightAction(String roomCode, String playerId, 
      PlayerRole role, String targetId) async { /* ... */ }
  Future<void> submitVote(String roomCode, String voterId, 
      String targetId) async { /* ... */ }
  
  // Phase processing methods
  Future<void> processPhaseEnd(String roomCode) async { /* ... */ }
  Future<void> _processNightEnd(String roomCode, GameRoom room) async { /* ... */ }
  Future<void> _processDayEnd(String roomCode, GameRoom room) async { /* ... */ }
  Future<void> _processVotingEnd(String roomCode, GameRoom room) async { /* ... */ }
  Future<void> _checkGameOver(String roomCode, List<Player> players) async { /* ... */ }
  
  // Chat methods
  Future<void> sendMessage(String roomCode, String senderId, 
      String senderName, String message) async { /* ... */ }
  
  // Streams for real-time updates
  Stream<GameRoom> roomStream(String roomCode) { /* ... */ }
  Stream<QuerySnapshot> messagesStream(String roomCode) { /* ... */ }
}
```

### Model Classes

The game relies on several key data models:

```dart
// From game_room.dart
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
  
  // Implementation...
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
  
  // Implementation...
}
```

### UI Components

The game includes several specialized UI components for different gameplay phases:

- **RoleRevealWidget**: Shows the player's assigned role at the start of the game
- **NightActionWidget**: Interface for night-time role actions (Mafia, Detective, Doctor)
- **DayDiscussionWidget**: Discussion interface with chat during the day phase
- **VotingWidget**: Voting interface during the voting phase
- **GameOverWidget**: Shows the game results and winner
- **PlayerListWidget**: Displays all players and their status
- **ChatWidget**: Real-time chat functionality
- **TimerWidget**: Countdown timer for each phase

## Game Logic & Flow

### Game Lifecycle

The game follows a predictable lifecycle with state transitions triggered by player actions and timers:

```
┌────────────────┐
│  Waiting Room  │
│   (Lobby)      │
└───────┬────────┘
        │
        ▼
┌────────────────┐
│  Role Reveal   │
└───────┬────────┘
        │
        ▼
┌────────────────┐          ┌────────────────┐
│  Night Phase   │◄────────►│   Day Phase    │
└───────┬────────┘          └───────┬────────┘
        │                           │
        │                           │
        │                           ▼
        │                   ┌────────────────┐
        │                   │  Voting Phase  │
        │                   └───────┬────────┘
        │                           │
        │      ┌────────────────────┘
        │      │
        ▼      ▼
┌────────────────┐
│   Game Over    │
└────────────────┘
```

### Phase Processing Logic

The game automatically transitions between phases using a timer system:

```dart
// From game_screen.dart
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
```

When a phase ends, the `processPhaseEnd` method in `GameService` handles the appropriate game logic:

```dart
// From game_service.dart
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
```

### Role-Specific Actions

Special roles have unique actions they can perform during the night phase:

- **Mafia**: Select a player to eliminate
- **Detective**: Investigate a player's role
- **Doctor**: Protect a player from elimination

```dart
// From game_service.dart
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
```

### Voting System

During the voting phase, players can vote to eliminate a suspected Mafia member or skip voting:

```dart
// From game_service.dart
Future<void> submitVote(
  String roomCode,
  String voterId,
  String targetId,
) async {
  await _roomsCollection.doc(roomCode).update({
    'votes.$voterId': targetId,
  });
}
```

At the end of the voting phase, votes are tallied and the player with the most votes is eliminated:

```dart
// From game_service.dart
Future<void> _processVotingEnd(String roomCode, GameRoom room) async {
  final players = List<Player>.from(room.players);
  
  // Count votes
  final voteCounts = <String, int>{};
  room.votes.forEach((_, targetId) {
    voteCounts[targetId] = (voteCounts[targetId] ?? 0) + 1;
  });
  
  // Check for skip votes
  final skipVotes = voteCounts[skipVoteId] ?? 0;
  
  // Count total votes
  int totalVotes = room.votes.length;
  
  // Find the player with the most votes
  String? eliminatedId;
  int maxVotes = 0;
  
  // If half or more of the votes are to skip, then skip elimination
  if (skipVotes >= totalVotes / 2) {
    eliminatedId = null; // Skip elimination
  } else {
    // Process normal votes (excluding skip votes)
    voteCounts.forEach((playerId, count) {
      if (playerId != skipVoteId && count > maxVotes) {
        maxVotes = count;
        eliminatedId = playerId;
      } else if (playerId != skipVoteId && count == maxVotes) {
        // Tie - no elimination
        eliminatedId = null;
      }
    });
  }
  
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
```

### Win Condition Logic

After each elimination (via Mafia at night or voting during the day), the game checks if either side has won:

```dart
// From game_service.dart
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
```

## State Management

The app uses a combination of Provider and BLoC patterns for state management:

### Provider Pattern

Provider is used for dependency injection and simpler state management needs:

```dart
// From main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<GameService>(
          create: (_) => GameService(),
        ),
      ],
      child: const MafiaApp(),
    ),
  );
}
```

### BLoC Pattern

For more complex states like game room management, the BLoC pattern is used:

```dart
// From game_room_bloc.dart
class GameRoomBloc extends Bloc<GameRoomEvent, GameRoomState> {
  final GameService _gameService;
  
  StreamSubscription? _roomSubscription;
  StreamSubscription? _messagesSubscription;
  
  GameRoomBloc(this._gameService) : super(GameRoomInitial()) {
    on<JoinRoom>(_onJoinRoom);
    on<CreateRoom>(_onCreateRoom);
    on<LeaveRoom>(_onLeaveRoom);
    on<StartGame>(_onStartGame);
    on<SubmitNightAction>(_onSubmitNightAction);
    on<SubmitVote>(_onSubmitVote);
    on<SendMessage>(_onSendMessage);
    on<RoomUpdated>(_onRoomUpdated);
    on<MessagesUpdated>(_onMessagesUpdated);
  }
  
  void _onJoinRoom(JoinRoom event, Emitter<GameRoomState> emit) async {
    emit(GameRoomLoading());
    
    try {
      final room = await _gameService.joinRoom(event.roomCode, event.player);
      
      _subscribeToRoom(event.roomCode);
      _subscribeToMessages(event.roomCode);
      
      emit(GameRoomLoaded(room: room, messages: []));
    } catch (e) {
      emit(GameRoomError(message: e.toString()));
    }
  }
  
  // Additional event handlers...
  
  void _subscribeToRoom(String roomCode) {
    _roomSubscription?.cancel();
    _roomSubscription = _gameService.roomStream(roomCode).listen(
      (room) {
        add(RoomUpdated(room: room));
      },
      onError: (error) {
        add(GameRoomErrorEvent(message: error.toString()));
      },
    );
  }
  
  // Additional methods...
  
  @override
  Future<void> close() {
    _roomSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}
```

## Firebase Integration

The app leverages Firebase for all backend functionality:

### Firebase Initialization

```dart
// From main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Rest of initialization...
}
```

### Firestore Real-time Updates

The app uses Firestore's real-time listeners to sync game state across devices:

```dart
// From game_service.dart
Stream<GameRoom> roomStream(String roomCode) {
  return _roomsCollection.doc(roomCode).snapshots().map(
    (snapshot) => GameRoom.fromDocument(snapshot),
  );
}

Stream<QuerySnapshot> messagesStream(String roomCode) {
  return _messagesCollection
      .where('roomCode', isEqualTo: roomCode)
      .orderBy('timestamp', descending: false)
      .snapshots();
}
```

### Firebase Authentication

User authentication is managed through Firebase Auth:

```dart
// From auth_service.dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Authentication methods...
}
```

## UI/UX Design

### Color Scheme

The app uses a dark theme with red accents to create a mysterious and suspenseful atmosphere fitting for the Mafia game:

```dart
// From app.dart
ThemeData(
  primarySwatch: Colors.red,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  // Additional theme configuration...
)
```

### Responsive Design

The UI is designed to work across different device sizes:

```dart
// From responsive_builder.dart
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, ScreenSize) builder;
  
  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        ScreenSize screenSize;
        
        if (constraints.maxWidth < 600) {
          screenSize = ScreenSize.small;
        } else if (constraints.maxWidth < 900) {
          screenSize = ScreenSize.medium;
        } else {
          screenSize = ScreenSize.large;
        }
        
        return builder(context, screenSize);
      },
    );
  }
}
```

### Animation and Transitions

The app includes animations for phase changes and role reveals:

```dart
// From role_reveal_widget.dart
class RoleRevealWidget extends StatefulWidget {
  final PlayerRole role;
  
  const RoleRevealWidget({
    Key? key,
    required this.role,
  }) : super(key: key);
  
  @override
  _RoleRevealWidgetState createState() => _RoleRevealWidgetState();
}

class _RoleRevealWidgetState extends State<RoleRevealWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        child: _buildRoleCard(),
      ),
    );
  }
  
  Widget _buildRoleCard() {
    // Build role-specific UI...
  }
}
```

## Performance Optimizations

### Data Caching

To minimize database reads, the app implements caching strategies:

```dart
// From game_repository.dart
class GameRepository {
  final GameService _gameService;
  final _roomCache = <String, GameRoom>{};
  
  GameRepository(this._gameService);
  
  Future<GameRoom> getRoom(String roomCode) async {
    // Check cache first
    if (_roomCache.containsKey(roomCode)) {
      return _roomCache[roomCode]!;
    }
    
    // Fetch from Firestore if not in cache
    final roomDoc = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomCode)
        .get();
    
    if (!roomDoc.exists) {
      throw Exception('Room not found');
    }
    
    final room = GameRoom.fromDocument(roomDoc);
    _roomCache[roomCode] = room;
    
    return room;
  }
  
  // Additional methods...
}
```

### UI Optimization

To ensure smooth UI rendering, the app employs several optimization techniques:

1. **Lazy Loading**: Lists of players and messages are loaded using `ListView.builder` for efficient rendering
2. **Const Constructors**: Widgets use const constructors when possible to optimize rebuilds
3. **Minimal Rebuilds**: BLoC and Provider are used to minimize unnecessary widget rebuilds

```dart
// From player_list_widget.dart
class PlayerListWidget extends StatelessWidget {
  final List<Player> players;
  final String currentPlayerId;
  
  const PlayerListWidget({
    Key? key,
    required this.players,
    required this.currentPlayerId,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return PlayerCard(
          player: player,
          isCurrentPlayer: player.id == currentPlayerId,
        );
      },
    );
  }
}
```

## Testing

The project includes unit, widget, and integration tests:

### Unit Tests

```dart
// From game_service_test.dart
void main() {
  group('GameService', () {
    late FirebaseFirestore firestore;
    late GameService gameService;
    
    setUp(() {
      firestore = FakeFirebaseFirestore();
      gameService = GameService();
    });
    
    test('create room generates unique code', () async {
      final room = GameRoom(
        name: 'Test Room',
        hostId: 'user123',
        mafiaCount: 1,
        detectiveCount: 1,
        doctorCount: 1,
        dayTimeSeconds: 120,
        nightTimeSeconds: 30,
        voteTimeSeconds: 30,
        players: [
          Player(
            id: 'user123',
            name: 'Host',
            status: PlayerStatus.alive,
            isHost: true,
          ),
        ],
        phase: GamePhase.waiting,
        votes: {},
      );
      
      final roomCode = await gameService.createRoom(room);
      
      expect(roomCode.length, 6);
      expect(int.tryParse(roomCode), isNotNull);
    });
    
    // Additional tests...
  });
}
```

### Widget Tests

```dart
// From game_screen_test.dart
void main() {
  testWidgets('GameScreen displays correct UI for night phase', (WidgetTester tester) async {
    // Create a mock GameRoom
    final room = GameRoom(
      id: '123456',
      name: 'Test Room',
      hostId: 'user123',
      mafiaCount: 1,
      detectiveCount: 1,
      doctorCount: 1,
      dayTimeSeconds: 120,
      nightTimeSeconds: 30,
      voteTimeSeconds: 30,
      players: [
        Player(
          id: 'user123',
          name: 'Player 1',
          role: PlayerRole.mafia,
          status: PlayerStatus.alive,
          isHost: true,
        ),
        Player(
          id: 'user456',
          name: 'Player 2',
          role: PlayerRole.villager,
          status: PlayerStatus.alive,
          isHost: false,
        ),
      ],
      phase: GamePhase.night,
      phaseEndTime: DateTime.now().millisecondsSinceEpoch + 30000,
      votes: {},
    );
    
    // Build the GameScreen with the mock room
    await tester.pumpWidget(
      MaterialApp(
        home: MockGameScreen(room: room, currentPlayerId: 'user123'),
      ),
    );
    
    // Verify that the night phase UI is displayed
    expect(find.text('Night Phase'), findsOneWidget);
    expect(find.text('Choose a player to eliminate'), findsOneWidget);
    expect(find.byType(TimerWidget), findsOneWidget);
  });
  
  // Additional test cases...
}
```

### Integration Tests

```dart
// From app_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('End-to-end test', () {
    testWidgets('Complete game flow test', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      
      // Login
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      
      // Create a room
      await tester.tap(find.text('Create Room'));
      await tester.pumpAndSettle();
      
      // Configure room settings
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      
      // Wait for room creation and verify
      expect(find.text('Waiting for players...'), findsOneWidget);
      
      // Additional steps to simulate full game flow...
    });
  });
}
```

## Deployment

### Building for Production

To build and deploy the app for production, follow these steps:

#### Android
```bash
flutter build apk --release
```

The APK will be created at `build/app/outputs/apk/release/app-release.apk`.

#### iOS
```bash
flutter build ios --release
```

Then use Xcode to archive and upload to the App Store.

#### Web
```bash
flutter build web --release
```

The web build will be created in the `build/web` directory.

### Continuous Integration/Deployment (CI/CD)

The project uses GitHub Actions for CI/CD:

```yaml
# .github/workflows/ci.yml
name: CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: app-release
          path: build/app/outputs/apk/release/app-release.apk
```

## Future Enhancements

Here are some planned improvements for future versions:

### Gameplay Enhancements
- **Additional Roles**: Add new special roles like Jester, Sheriff, and Bodyguard
- **Custom Role Creation**: Allow hosts to create custom roles with unique abilities
- **Game History**: Record and display statistics for players across multiple games
- **Achievements System**: Unlock achievements for completing specific game milestones

### Technical Enhancements
- **Offline Mode**: Support for playing locally on a single device
- **Push Notifications**: Alert players when it's their turn or when a game is about to start
- **Voice Chat**: Optional voice communication during day phases
- **Advanced Analytics**: Track player behavior and game balance
- **Cross-platform Sync**: Seamless gameplay across different devices

### UI/UX Improvements
- **Customizable Themes**: Allow players to personalize the app's appearance
- **Animated Transitions**: Enhance transitions between game phases
- **Custom Avatars**: Let players choose or upload profile pictures
- **Sound Effects**: Add immersive audio cues for different game events

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### How to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

Please follow the [Flutter style guide](https://flutter.dev/docs/development/tools/formatting) and run the following before submitting PRs:

```bash
flutter format .
flutter analyze
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

Utso Sarkar - [@officiallyutso](https://utso.netlify.app) - utsosarkar1@gmail.com

Project Link: [https://github.com/officiallyutso/Mafia-game-flutter](https://github.com/officiallyutso/Mafia-game-flutter)

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Provider](https://pub.dev/packages/provider)
- [Flutter BLoC](https://pub.dev/packages/flutter_bloc)
- [Dart](https://dart.dev/)
- All the open-source libraries used in this project
- The Mafia/Werewolf game community for inspiration
