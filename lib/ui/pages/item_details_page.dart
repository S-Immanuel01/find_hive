import 'package:find_hive/domain/models/user_model.dart';
import 'package:find_hive/ui/components/vertical_spacer.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:intl/intl.dart';
import '../../data/constants/colors.dart';
import '../../domain/models/found_item.dart';

class ItemDetailsPage extends StatefulWidget {
  const ItemDetailsPage({super.key});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  final user = FirebaseAuth.instance.currentUser!;
  UserModel? userDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      final details = await UserModel.getUserDetails();
      if (mounted) {
        setState(() {
          userDetails = details;
          isLoading = false;
        });
      }
      print('User details loaded: ${userDetails?.regNo}');
    } catch (e) {
      print('Error loading user details: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> addMembersToChannel({
    required String channelID,
    required String memberID,
    required ReportedItem item,
  }) async {
    final client = StreamChatClient(
      "7m3ztxqnkpxn",
      logLevel: Level.INFO,
      connectTimeout: Duration(milliseconds: 9000),
      receiveTimeout: Duration(milliseconds: 9000),
    );

    final streamUser = User(
      id: user.uid, // Use Firebase user ID
      extraData: {
        'name': userDetails?.name ?? 'Unknown User',
        'image': user.photoURL ?? '',
      },
    );

    try {
      await client.connectUser(streamUser, client.devToken(user.uid).rawValue);
      final response = await client.addChannelMembers(channelID, "messaging", [
        memberID,
      ]);
      print(
        "Members in channel: ${response.members.map((m) => m.userId).join(', ')}",
      );
      final userInList = response.members.any(
        (Member member) => member.userId == memberID,
      );
      if (userInList) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Successfully added you to the channel")),
        );
        Navigator.pushNamed(context, '/chat', arguments: item);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Couldn't add you to the group at this moment"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  String getDateTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.isNegative) {
      return DateFormat('d MMMM yyyy').format(date);
    }

    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      }
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (date.day == yesterday.day &&
        date.month == yesterday.month &&
        date.year == yesterday.year) {
      return 'Yesterday';
    }

    return DateFormat('d MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    ReportedItem item =
        ModalRoute.of(context)!.settings.arguments as ReportedItem;
    final Size screenParams = MediaQuery.of(context).size;
    final date = DateTime.fromMicrosecondsSinceEpoch(
      item.createdAt.microsecondsSinceEpoch,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  // Image
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child:
                            item.imagePath != ""
                                ? Image.network(
                                  item.imagePath!,
                                  fit: BoxFit.fitWidth,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          Image.asset(
                                            "assets/images/splash-icon.png",
                                          ),
                                  width: screenParams.width,
                                )
                                : Container(
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                        'assets/images/splash-icon.png',
                                      ),
                                    ),
                                  ),
                                ),
                      ),
                      Spacer(),
                    ],
                  ),
                  // Details container
                  Container(
                    height: screenParams.height * 0.6,
                    width: screenParams.width,
                    margin: EdgeInsets.fromLTRB(
                      0,
                      screenParams.height * 0.3,
                      0,
                      0,
                    ),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 350,
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        verticalSpacer(spacing: 20),
                        Text(
                          item.description,
                          style: const TextStyle(fontSize: 15),
                        ),
                        verticalSpacer(spacing: 30),
                        Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/icons/person.png',
                                  color: Colours.blue,
                                  height: 30,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.personName ?? 'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(item.id, style: const TextStyle()),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/icons/calender.png',
                                  color: Colours.blue,
                                  height: 30,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  getDateTime(date),
                                  style: const TextStyle(),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Found item button
                        ElevatedButton(
                          onPressed: () {
                            if (userDetails == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("User details not loaded"),
                                ),
                              );
                              return;
                            }
                            if (item.id != userDetails!.regNo) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "You can only mark this item as found if you reported it",
                                  ),
                                ),
                              );
                              return;
                            }
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: Text(
                                      "Confirm that Item '${item.name}' has been found",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    actions: [
                                      MaterialButton(
                                        onPressed: () {
                                          final newItem = ReportedItem(
                                            id: item.id,
                                            name: item.name,
                                            description: item.description,
                                            category: item.category,
                                            location: item.location,
                                            phoneNumber: item.phoneNumber,
                                            firestoreID: item.firestoreID,
                                            createdAt: item.createdAt,
                                            isFound: true,
                                            deleteUrl: item.deleteUrl,
                                            imagePath: item.imagePath,
                                          );
                                          newItem.updateReportedItem();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Yes"),
                                      ),
                                      MaterialButton(
                                        onPressed:
                                            () => Navigator.of(context).pop(),
                                        child: const Text(
                                          "No",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colours.blue,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person),
                              SizedBox(width: 10),
                              Text("Found this Item?"),
                            ],
                          ),
                        ),
                        verticalSpacer(spacing: 20),
                        // Join chat button
                        ElevatedButton(
                          onPressed: () {
                            addMembersToChannel(
                              channelID: item.firestoreID,
                              memberID: user.uid,
                              item: item,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colours.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_outlined),
                              SizedBox(width: 10),
                              Text("Join Chat"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
