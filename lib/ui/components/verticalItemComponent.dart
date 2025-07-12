import 'package:find_hive/data/constants/colors.dart';
import 'package:find_hive/ui/components/vertical_spacer.dart';
import 'package:flutter/material.dart';

class VerticalItemComponent extends StatelessWidget {
  final String title;
  final String description;
  final String profileName;
  final String assetPath;
  final Function callback;
  final int? index;
  final bool isFound;

  const VerticalItemComponent({
    super.key,
    required this.title,
    required this.description,
    this.assetPath = "",
    required this.profileName,
    required this.callback,
    this.index,
    required this.isFound,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => callback(),
      child: Stack(
        children: [
          AnimatedContainer(
            // changed this
            height: 140,
            width: double.maxFinite,
            margin: EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            duration: Duration(microseconds: 100 * index!), // changed this
            child: Row(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    // padding: EdgeInsets.all(5),
                    margin: EdgeInsets.fromLTRB(10, 10, 0, 10),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child:
                        (assetPath == "")
                            ? Image.asset("assets/images/splash-icon.png")
                            : Image.network(
                              assetPath,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null)
                                  return child;
                                else
                                  return Image.asset(
                                    "assets/images/splash-icon.png",
                                  );
                              },
                              errorBuilder:
                                  (context, error, stacktrace) => Image.asset(
                                    "assets/images/splash-icon.png",
                                  ),
                              height: 120,
                            ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        verticalSpacer(spacing: 5),
                        Text(
                          description,
                          style: TextStyle(overflow: TextOverflow.ellipsis),
                          maxLines: 2,
                        ),
                        Spacer(),
                        Row(
                          spacing: 10,
                          children: [Icon(Icons.person), Text(profileName)],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isFound)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colours.blue,

                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text("Found", style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
