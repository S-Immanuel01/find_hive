import 'package:find_hive/data/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HorizontalItemComponent extends StatelessWidget {
  final String title;
  final String description;
  final String name;
  final String assetPath;
  final Function callback;
  final bool isFound;
  // image also

  const HorizontalItemComponent({
    super.key,
    required this.title,
    required this.description,
    required this.name,
    required this.callback,
    this.assetPath = "",
    required this.isFound,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => callback(),
      child: Stack(
        children: [
          Container(
            width: 250,

            margin: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    height: double.maxFinite,
                    width: double.maxFinite,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.network(
                      assetPath,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Image.asset("assets/images/splash-icon.png");
                      },
                      errorBuilder:
                          (context, error, stackTrace) =>
                              Image.asset("assets/images/splash-icon.png"),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                description,
                                maxLines: 3,
                                style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                          child: Row(
                            spacing: 10,
                            children: [
                              Image.asset(
                                'assets/icons/person.png',
                                height: 20,
                              ),
                              Text(name),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isFound)
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colours.blue,

                borderRadius: BorderRadius.circular(15),
              ),
              child: Text("Found", style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
