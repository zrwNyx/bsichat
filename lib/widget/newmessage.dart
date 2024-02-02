import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

class NewMessage extends StatelessWidget {
  NewMessage({super.key});
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Future<String?> _uploadImage() async {
      final provider = Provider.of<AuthService>(context, listen: false);
      final storageReference = FirebaseStorage.instance
          .ref()
          .child('chat_images/${DateTime.now()}.png');
      final uploadTask = storageReference.putFile(provider.imageFile!);
      await uploadTask.whenComplete(() => null);
      return storageReference.getDownloadURL();
    }

    void _submitMessage(BuildContext context) async {
      final provider = Provider.of<AuthService>(context, listen: false);
      final enteredMessage = _messageController.text;

      if (enteredMessage.trim().isEmpty && provider.imageFile == null) {
        return;
      }

      FocusScope.of(context).unfocus();
      _messageController.clear();

      final user = FirebaseAuth.instance.currentUser!;
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      FirebaseFirestore.instance.collection('chat').add({
        'text': enteredMessage,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'username': userData.data()!['username'],
        'userImage': userData.data()!['image_url'],
        'imageUrl': provider.imageFile != null ? await _uploadImage() : null,
      });

      provider.setNull();
    }

    return Consumer<AuthService>(
      builder: (context, prov, _) => Padding(
        padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (prov.imageFile != null)
                    Image.file(
                      prov.imageFile!,
                      height: 100,
                    )
                  else
                    Container(),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          textCapitalization: TextCapitalization.sentences,
                          autocorrect: true,
                          enableSuggestions: true,
                          decoration: const InputDecoration(
                              labelText: 'Send a message...'),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.image),
                            onPressed: () => prov.getImage(ImageSource.gallery),
                          ),
                          IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () => prov.getImage(ImageSource.camera),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              color: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.send),
              onPressed: () => _submitMessage(context),
            ),
          ],
        ),
      ),
    );
  }
}
