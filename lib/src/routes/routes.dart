import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/game/create_room_screen.dart';
import '../screens/game/join_room_screen.dart';
import '../screens/game/lobby_screen.dart';
import '../screens/game/game_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/home': (context) => const HomeScreen(),
  '/create-room': (context) => const CreateRoomScreen(),
  '/join-room': (context) => const JoinRoomScreen(),
  '/lobby': (context) => const LobbyScreen(),
  '/game': (context) => const GameScreen(),
};