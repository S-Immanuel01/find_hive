import 'package:find_hive/data/constants/categories.dart';
import 'package:find_hive/domain/models/found_item.dart';
import 'package:find_hive/ui/components/hItemPlaceHolderComponent.dart';
import 'package:find_hive/ui/components/horizontalItemComponent.dart';
import 'package:find_hive/ui/components/vItemComponentLoading.dart';
import 'package:find_hive/ui/components/verticalItemComponent.dart';
import 'package:find_hive/ui/components/vertical_spacer.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showCategories = false;
  String? _selectedCategory; // Track the selected category
  List<String> categoryList = [
    'All', // Added "All" to reset category filter
    Category.documents,
    Category.belongings,
    Category.accessories,
    Category.electronics,
  ];
  int isAdminIntent = 0;

  String get searchFilterText => _searchController.text.trim().toLowerCase();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF1F1F1),
        title: GestureDetector(
          onTap: () {
            isAdminIntent += 1;
            if (isAdminIntent == 7) {
              isAdminIntent = 0;
              Navigator.pushNamed(context, '/adminSignin');
            }
          },
          child: const Text(
            'Home',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search and categories
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 10,
                  children: [
                    Expanded(
                      child: Search(
                        controller: _searchController,
                        hintText: "Search",
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: Colors.white,
                        padding: const EdgeInsets.all(15),
                        fixedSize: const Size(50, 50),
                        backgroundColor: Colors.white,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          _selectedCategory == category
                                              ? Colors
                                                  .blue // Highlight selected category
                                              : Colors.grey.shade200,
                                      foregroundColor:
                                          _selectedCategory == category
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        // Toggle category: if same category is clicked, clear it
                                        _selectedCategory =
                                            _selectedCategory == category
                                                ? null
                                                : category;
                                        if (_selectedCategory == 'All') {
                                          _selectedCategory =
                                              null; // Treat 'All' as no filter
                                        }
                                      });
                                    },
                                    child: Text(category),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),

                verticalSpacer(spacing: 10),
                Text(
                  "Most Recent",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.grey,
                  ),
                ),
                verticalSpacer(spacing: 10),
                SizedBox(
                  height: 200,
                  child: StreamBuilder<List<ReportedItem>>(
                    stream: ReportedItem.getReportedItems(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active &&
                          snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
                        final items = snapshot.data!;

                        final recentItems =
                            items
                                .where(
                                  (item) =>
                                      // Search filter
                                      (item.name.toLowerCase().contains(
                                            searchFilterText,
                                          ) ||
                                          item.description
                                              .toLowerCase()
                                              .contains(searchFilterText)) &&
                                      // Category filter
                                      (_selectedCategory == null ||
                                          item.category == _selectedCategory),
                                )
                                .take(5)
                                .toList();
                        if (recentItems.isNotEmpty) {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recentItems.length,
                            itemBuilder: (context, index) {
                              final item = recentItems[index];
                              return HorizontalItemComponent(
                                title: item.name,
                                description: item.description,
                                name: item.personName!,
                                assetPath: item.imagePath ?? "",
                                isFound: item.isFound,
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
                            child: Text("No matching recent items"),
                          );
                        }
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
                Text(
                  "Other Items",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.grey,
                  ),
                ),
                verticalSpacer(spacing: 10),
                StreamBuilder<List<ReportedItem>>(
                  stream: ReportedItem.getReportedItems(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final items = snapshot.data!;

                      // Filter items and skip the first 5 for "Other Items"
                      final filteredItems =
                          items
                              .where(
                                (item) =>
                                    // Search filter
                                    (item.name.toLowerCase().contains(
                                          searchFilterText,
                                        ) ||
                                        item.description.toLowerCase().contains(
                                          searchFilterText,
                                        )) &&
                                    // Category filter
                                    (_selectedCategory == null ||
                                        item.category == _selectedCategory),
                              )
                              .toList();

                      final otherItems =
                          filteredItems.length > 5
                              ? filteredItems.sublist(5)
                              : <ReportedItem>[];
                      if (otherItems.isNotEmpty) {
                        return Column(
                          children:
                              otherItems.asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                return VerticalItemComponent(
                                  key: ValueKey(item.firestoreID),
                                  index: index,
                                  isFound: item.isFound,
                                  title: item.name,
                                  description: item.description,
                                  profileName: item.personName!,
                                  assetPath: item.imagePath ?? "",
                                  callback: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/details',
                                      arguments: item,
                                    );
                                  },
                                );
                              }).toList(),
                        );
                      } else {
                        return const SizedBox();
                      }
                    } else {
                      return Column(
                        children: List.generate(
                          5,
                          (index) => const VerticalItemPlaceHolderComponent(),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
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
      onChanged: (value) {
        controller.text = value;
      },
    );
  }
}
