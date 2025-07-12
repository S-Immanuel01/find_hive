import 'package:flutter/material.dart';

import '../../data/constants/colors.dart';

class NextIntroPage extends StatefulWidget {
  const NextIntroPage({super.key});

  @override
  State<NextIntroPage> createState() => _NextIntroPageState();
}

class _NextIntroPageState extends State<NextIntroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Quick ",
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w800,
                      color: Colours.blue,
                    ),
                  ),
                  Text(
                    "Notice",
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              // Lost something
              Flexible(
                child: Text(
                  "Immediately get notified once your item is found by the community",
                  style: TextStyle(),
                  textAlign: TextAlign.center,
                ),
              ),
              Spacer(),
              // picture
              Expanded(
                flex: 4,
                child: Image.asset("assets/images/Webinar-amico.png"),
              ),

              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colours.blue,
                    shadowColor: Colours.blue,
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 22),

                        child: Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
