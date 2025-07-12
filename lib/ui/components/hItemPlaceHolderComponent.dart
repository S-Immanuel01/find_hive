import 'package:flutter/material.dart';

class HorizontalItemPlaceHolderComponent extends StatelessWidget {
  final Color placeHolderColor = Colors.grey.shade200;

  HorizontalItemPlaceHolderComponent({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Image.asset("assets/images/splash-icon.png"),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(color: placeHolderColor),
                  ),
                  Container(
                    height: 10,
                    decoration: BoxDecoration(color: placeHolderColor),
                  ),
                  Spacer(),
                  Row(
                    spacing: 10,
                    children: [
                      Container(
                        height: 5,
                        width: 10,
                        decoration: BoxDecoration(color: placeHolderColor),
                      ),
                      Container(
                        height: 5,
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
