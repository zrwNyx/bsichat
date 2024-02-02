import 'package:firebase/presentation/authscreen.dart';
import 'package:firebase/widget/chatmessage.dart';
import 'package:firebase/widget/newmessage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    print(FirebaseAuth.instance.currentUser.toString());
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterChat'),
        actions: [
          GestureDetector(
              child: Icon(
                Icons.logout,
                color: Colors.black,
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                print(FirebaseAuth.instance.currentUser.toString() + ' 2');
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const AuthScreen()));
              })
        ],
      ),
      body: const Column(children: const [
        Expanded(
          child: ChatMessages(),
        ),
        NewMessage()
      ]),
    );
  }
}
