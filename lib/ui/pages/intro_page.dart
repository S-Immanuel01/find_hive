import 'package:find_hive/data/constants/colors.dart';
import 'package:flutter/material.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
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
                    "Lost ",
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w800,
                      color: Colours.red,
                    ),
                  ),
                  Text(
                    "Something?",
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              // Lost something
              Flexible(
                child: Text(
                  "Create an add of your lost item and let your friend know",
                  style: TextStyle(),
                  textAlign: TextAlign.center,
                ),
              ),
              Spacer(),
              // picture
              Expanded(
                flex: 4,
                child: Image.asset("assets/images/Lost-rafiki.png"),
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
                    Navigator.pushReplacementNamed(context, '/introII');
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
