//auth.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/presentation/chatpage.dart';
import 'package:firebase/provider/provider.dart';
import 'package:firebase/widget/userwidgetpicker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();

  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  File? _selectedImage;

  void _submit() async {
    final isValid = _form.currentState!.validate();
    final authProvider = Provider.of<AuthService>(context, listen: false);

    if (!isValid || !authProvider.isLogin && _selectedImage == null) {
      print('error');
      return;
    }

    _form.currentState!.save();

    try {
      if (authProvider.isLogin) {
        final userCredentials = await authProvider.signInWithEmailAndPassword(
            _enteredEmail, _enteredPassword);

        if (authProvider.user!.user!.email != null) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const ChatPage()));
        }
      } else {
        final userSign = await authProvider.registerWithEmailAndPassword(
                _enteredUsername, _enteredEmail, _enteredPassword)
            as UserCredential;

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${authProvider.user!.user!.uid}.jpg');

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(authProvider.user!.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageUrl,
        });

        authProvider.setLog(true);

        if (authProvider.user!.user!.email != null) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const ChatPage()));
        }
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        // ...
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Consumer<AuthService>(
            builder: (context, auth, _) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    top: 30,
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  width: 200,
                  child: Image.asset('assets/images/untitled.png'),
                ),
                Card(
                  margin: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!auth.isLogin)
                              UserImagePicker(
                                onPickImage: (pickedImage) {
                                  _selectedImage = pickedImage;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Email Address'),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter a valid email address.';
                                }

                                return null;
                              },
                              onSaved: (value) {
                                _enteredEmail = value!;
                              },
                            ),
                            if (!auth.isLogin)
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Username'),
                                enableSuggestions: false,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim().length < 4) {
                                    return 'Please enter at least 4 characters.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredUsername = value!;
                                },
                              ),
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Password'),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Password must be at least 6 characters long.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredPassword = value!;
                              },
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Text(auth.isLogin ? 'Login' : 'Signup'),
                            ),
                            TextButton(
                              onPressed: () {
                                auth.setAuth();
                              },
                              child: Text(auth.isLogin
                                  ? 'Create an account'
                                  : 'I already have an account'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
