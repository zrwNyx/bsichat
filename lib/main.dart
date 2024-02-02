//main.dart

import 'package:firebase/presentation/authscreen.dart';
import 'package:firebase/presentation/chatpage.dart';
// import 'package:firebase/provider/userprovider.dart';
import 'package:firebase/provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: MaterialApp(
        title: 'FlutterChat',
        theme: ThemeData().copyWith(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 63, 17, 177)),
        ),
        home: Consumer<AuthService>(
          builder: (ctx, authService, _) => StreamBuilder(
            stream: authService.check,
            builder: (ctx, userSnapshot) {
              if (userSnapshot.hasData) {
                return const ChatPage();
              }
              return const AuthScreen();
            },
          ),
        ),
      ),
    );
  }
}
