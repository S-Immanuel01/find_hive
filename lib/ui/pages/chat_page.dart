import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../domain/models/found_item.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late StreamChatClient client;
  late Channel channel;
  bool isChannelInitialized = false;
  String? errorMessage;
  final ScrollController controller = ScrollController();
  late ReportedItem item;

  @override
  void initState() {
    super.initState();
    client = StreamChatClient(
      "7m3ztxqnkpxn",
      logLevel: Level.INFO,
      connectTimeout: const Duration(milliseconds: 12000),
      receiveTimeout: const Duration(milliseconds: 12000),
    );

    // Defer accessing ModalRoute until after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        item = ModalRoute.of(context)!.settings.arguments as ReportedItem;
        connectClient();
      }
    });
  }

  Future<void> connectClient() async {
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
      // Connect the user
      await client.connectUser(
        user,
        client
            .devToken(FirebaseAuth.instance.currentUser?.uid ?? "John")
            .rawValue,
      );
      print("User connected: ${user.id}");

      // Create channel using ReportedItem's firestoreID
      channel = client.channel('messaging', id: item.firestoreID);
      // await channel.create();
      await channel.watch();
      setState(() => isChannelInitialized = true);
      // await channel.addMembers([
      //   FirebaseAuth.instance.currentUser?.uid ?? "John",
      // ]);

      // Add the current user as a member
      print("Added user ${user.id} to channel ${item.firestoreID}");
    } catch (e) {
      setState(() => errorMessage = "Error: $e");
    }
  }

  Future<void> disposeClient() async {
    if (isChannelInitialized) await channel.stopWatching();
    await client.disconnectUser();
  }

  @override
  void dispose() {
    controller.dispose();
    disposeClient();
    super.dispose();
  }

  Widget chatUI() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StreamChannelHeader(title: Text(item.name)),
      body: Column(
        children: [
          Expanded(child: StreamMessageListView(shrinkWrap: true)),
          const StreamMessageInput(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }
    return isChannelInitialized
        ? StreamChat(
          client: client,
          child: StreamChannel(channel: channel, child: chatUI()),
        )
        : const Center(child: CircularProgressIndicator());
  }
}
