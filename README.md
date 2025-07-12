import 'package:find_hive/data/constants/categories.dart';
import 'package:find_hive/domain/models/found_item.dart';
import 'package:find_hive/ui/components/hItemPlaceHolderComponent.dart';
import 'package:find_hive/ui/components/horizontalItemComponent.dart';
import 'package:find_hive/ui/components/vItemComponentLoading.dart';
import 'package:find_hive/ui/components/verticalItemComponent.dart';
import 'package:find_hive/ui/components/vertical_spacer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showCategories = false;
  List<String> categoryList = [
    Category.documents,
    Category.belongings,
    Category.accessories,
    Category.electronics,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/report');
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            // Search and categories
            Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Search
                Expanded(
                  child: Search(
                    controller: _searchController,
                    hintText: "Search",
                  ),
                ),
                // Categories button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: Colors.white,
                    padding: const EdgeInsets.all(15),
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _showCategories = !_showCategories;
                    });
                  },
                  child: const Icon(Icons.category_outlined, size: 22),
                ),
              ],
            ),

            if (_showCategories)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                      categoryList
                          .map(
                            (category) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 5.0,
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  // Add category filter logic if needed
                                },
                                child: Text(category),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),

            verticalSpacer(spacing: 20),
            // Horizontal list (5 most recent items)
            Flexible(
              child: StreamBuilder<List<ReportedItem>>(
                stream: ReportedItem.getReportedItems(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final recentItems = snapshot.data!.take(5).toList();
                    return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: recentItems.length,
                      itemBuilder: (context, index) {
                        final item = recentItems[index];
                        return HorizontalItemComponent(
                          title: item.name,
                          description: item.description,
                          name: item.reporterName,
                          assetPath: item.imagePath ?? "",
                          callback: () {
                            Navigator.pushNamed(
                              context,
                              '/details',
                              arguments: item,
                            );
                          },
                        );
                      },
                    );
                  } else {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return HorizontalItemPlaceHolderComponent();
                      },
                    );
                  }
                },
              ),
            ),

            verticalSpacer(spacing: 10),
            // Vertical list (excluding the 5 most recent items)
            Expanded(
              flex: 2,
              child: StreamBuilder<List<ReportedItem>>(
                stream: ReportedItem.getReportedItems(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    // Skip the first 5 items
                    final otherItems =
                        snapshot.data!.length > 5
                            ? snapshot.data!.sublist(5)
                            : <ReportedItem>[];
                    if (otherItems.isNotEmpty) {
                      return ListView.builder(
                        itemCount: otherItems.length,
                        itemBuilder: (context, index) {
                          final item = otherItems[index];
                          return VerticalItemComponent(
                            title: item.name,
                            description: item.description,
                            profileName: item.reporterName,
                            assetPath: item.imagePath ?? "",
                            callback: () {
                              Navigator.pushNamed(
                                context,
                                '/details',
                                arguments: item,
                              );
                            },
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text("No additional items found"),
                      );
                    }
                  } else {
                    return ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return const VerticalItemPlaceHolderComponent();
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class Search extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  const Search({super.key, required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
      ),
      onChanged: (value) => controller.text = value,
    );
  }
}
