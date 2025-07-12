import 'package:find_hive/data/constants/colors.dart';
import 'package:find_hive/ui/components/vertical_spacer.dart';
import 'package:flutter/material.dart';

class AdminSignInPage extends StatefulWidget {
  const AdminSignInPage({super.key});

  @override
  State<AdminSignInPage> createState() => _AdminSignInPageState();
}

class _AdminSignInPageState extends State<AdminSignInPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size screenParam = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colours.blue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              verticalSpacer(spacing: screenParam.height * .3),
              Text(
                "Enter Admin Credentials",
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
              verticalSpacer(spacing: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: InputBorder.none,
                  hintText: "Name",
                ),
              ),
              verticalSpacer(spacing: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: InputBorder.none,
                  hintText: "Password",
                ),
                obscureText: true,
              ),

              verticalSpacer(spacing: 50),

              MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.white),
                ),
                padding: EdgeInsets.symmetric(horizontal: 15),
                onPressed: () {
                  if (!_nameController.text.trim().isNotEmpty &&
                      !_passwordController.text.trim().isNotEmpty) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Please fill all fields before clicking the button",
                        ),
                      ),
                    );
                    return;
                  }
                  if (_nameController.text.trim().toLowerCase() == 'admin' &&
                      _passwordController.text.trim().toLowerCase() ==
                          'admin') {
                    Navigator.pushReplacementNamed(context, '/admin');
                  }
                },
                child: Text(
                  "Login Me In!",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
