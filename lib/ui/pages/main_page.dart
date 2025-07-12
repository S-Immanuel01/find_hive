import 'package:find_hive/ui/pages/home_page.dart';
import 'package:find_hive/ui/pages/intro_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // FirebaseAuth.instance.signOut();
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return IntroPage();
          }
        },
      ),
    );
  }
}
