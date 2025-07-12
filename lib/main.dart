import 'package:camera/camera.dart';
import 'package:find_hive/data/constants/colors.dart';
import 'package:find_hive/firebase_options.dart';
import 'package:find_hive/ui/pages/admin/ui/admin_page.dart';
import 'package:find_hive/ui/pages/admin/ui/admin_sign_in_page.dart';
import 'package:find_hive/ui/pages/detection/ui/camera_page.dart';
import 'package:find_hive/ui/pages/chat_page.dart';
import 'package:find_hive/ui/pages/home_page.dart';
import 'package:find_hive/ui/pages/intro_page.dart';
import 'package:find_hive/ui/pages/item_details_page.dart';
import 'package:find_hive/ui/pages/main_page.dart';
import 'package:find_hive/ui/pages/next_intro_page.dart';
import 'package:find_hive/ui/pages/report_items_page.dart';
import 'package:find_hive/ui/pages/sign_in_page.dart';
import 'package:find_hive/ui/pages/sign_up_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await availableCameras();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find Hive',
      theme: ThemeData(
        fontFamily: 'poppins',
        splashColor: Colours.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colours.blue),
      ),

      builder:
          (context, child) =>
              StreamChatTheme(data: StreamChatThemeData(), child: child!),
      initialRoute: '/',
      routes: {
        '/': (context) => MainPage(),
        '/intro': (context) => IntroPage(),
        '/introII': (context) => NextIntroPage(),
        '/login': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        '/camera': (context) => CameraPage(),
        '/details': (context) => ItemDetailsPage(),
        '/report': (context) => ReportItemsPage(),
        '/chat': (context) => ChatPage(),
        '/admin': (context) => AdminPage(),
        '/adminSignin': (context) => AdminSignInPage(),
      },
    );
  }
}
