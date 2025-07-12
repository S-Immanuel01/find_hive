import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

Future<void> deleteChat({required String channelId}) async {
  final client = StreamChatClient(
    "7m3ztxqnkpxn",
    logLevel: Level.INFO,
    connectTimeout: const Duration(milliseconds: 12000),
    receiveTimeout: const Duration(milliseconds: 12000),
  );

  final user = User(
    id: FirebaseAuth.instance.currentUser?.uid ?? "John",
    extraData: {
      "name": FirebaseAuth.instance.currentUser?.displayName ?? "Johnny",
      "image":
          "https://th.bing.com/th/id/OIP.JNnZDMo_Nt_m35Kq-WBfxAHaLH?r=0&rs=1&pid=ImgDetMain&cb=idpwebp2&o=7&rm=3",
    },
    name: FirebaseAuth.instance.currentUser?.displayName ?? "Johnny",
  );

  try {
    await client.connectUser(
      user,
      client
          .devToken(FirebaseAuth.instance.currentUser?.uid ?? "John")
          .rawValue,
    );

    await client.deleteChannel(channelId, "messaging");
  } catch (e) {
    rethrow;
  }

  // use client to delete the chat
}
