import 'package:find_hive/domain/models/found_item.dart';
import 'package:find_hive/ui/components/verticalItemComponent.dart';
import 'package:find_hive/ui/pages/admin/domain/usecases/delete_chat.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Administrator")),
      body: StreamBuilder(
        stream: ReportedItem.getReportedItems(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final List<ReportedItem> items = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Slidable(
                    dragStartBehavior: DragStartBehavior.down,
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            item.deleteReportedItem();
                            deleteChat(channelId: item.firestoreID);
                          },
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                        ),
                      ],
                    ),
                    child: VerticalItemComponent(
                      index: index,
                      isFound: item.isFound,
                      key: ValueKey(item.firestoreID), // Ensure unique keys
                      title: item.name,
                      description: item.description,
                      profileName: item.personName ?? "",
                      assetPath: item.imagePath ?? "",
                      callback: () {
                        Navigator.pushNamed(
                          context,
                          '/details',
                          arguments: item,
                        );
                      },
                    ),
                  );
                },
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
