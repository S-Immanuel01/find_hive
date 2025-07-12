import 'package:find_hive/ui/components/vertical_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VerticalItemPlaceHolderComponent extends StatelessWidget {
  const VerticalItemPlaceHolderComponent({super.key});
  @override
  Widget build(BuildContext context) {
    Color placeHolderColor = Colors.grey.shade200;
    return Container(
      height: 150,
      width: 300,
      margin: EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(child: Image.asset("assets/images/splash-icon.png")),
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
                  Container(
                    height: 10,
                    decoration: BoxDecoration(color: placeHolderColor),
                  ),
                  verticalSpacer(spacing: 10),
                  Column(
                    spacing: 3,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 10,
                        decoration: BoxDecoration(color: placeHolderColor),
                      ),
                      Container(
                        height: 10,
                        decoration: BoxDecoration(color: placeHolderColor),
                      ),
                      Container(
                        height: 10,
                        width: 100,
                        decoration: BoxDecoration(color: placeHolderColor),
                      ),
                    ],
                  ),
                  Spacer(),
                  Row(
                    spacing: 10,
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(color: placeHolderColor),
                      ),
                      Container(
                        height: 10,
                        width: 50,
                        decoration: BoxDecoration(color: placeHolderColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
