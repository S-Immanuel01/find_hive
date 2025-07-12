import 'package:find_hive/data/constants/colors.dart';
import 'package:find_hive/domain/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/horizontal_spacer.dart';
import '../components/text_input_field.dart';
import '../components/vertical_spacer.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String errMessage = 'Successful';
  bool loading = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _passwordController.dispose();

    _emailController.dispose();
    super.dispose();
  }

  void signUp(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All Fields should be properly filled")),
      );
      return;
    }
    setState(() {
      loading = true;
    });

    final UserModel user = UserModel(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    await user.signInUser();

    errMessage = user.error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              content: Text(
                "Email or password incorrect, are you sure this account exist?",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Close"),
                ),
              ],
            ),
      );
    });

    setState(() {
      loading = false;
    });

    if (FirebaseAuth.instance.currentUser != null &&
        FirebaseAuth.instance.currentUser!.email!.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenParam = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                verticalSpacer(spacing: screenParam.height * .1),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Let's sign you in",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      Text(
                        'step in to make an impact today',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40),

                // DETAILS INPUT
                // registration number format: RUN/REG/SS/PF/1079
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 20,
                  children: [
                    TextInputField(
                      controller: _emailController,
                      label: 'Email',
                      hintText: 'johndoe@email.com',
                      autoCapitalizeLetters: false,
                    ),
                    TextInputField(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: '',
                      autoCapitalizeLetters: false,
                      obscureText: _obscureText,
                      isPassword: true,
                      setObscure: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ],
                ),

                verticalSpacer(spacing: 25),

                // SIGN IN BUTTON
                Stack(
                  alignment: Alignment.center,
                  children: [
                    MaterialButton(
                      onPressed: () {
                        signUp(context);
                      },
                      minWidth: screenParam.width,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: loading ? Colors.grey : Colours.blue,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            fontFamily: 'poppins',
                            color: loading ? Colors.grey[300] : Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),

                    // Loading
                    loading
                        ? Center(
                          child: CircularProgressIndicator(color: Colours.blue),
                        )
                        : SizedBox(),
                  ],
                ),

                verticalSpacer(spacing: 65),

                // OR SIGN Up WITH
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(thickness: 1, color: Colors.grey[300]),
                    ),
                    horizontalSpacer(spacing: 10),
                    Text(
                      'or Login with',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    horizontalSpacer(spacing: 10),
                    Expanded(
                      child: Divider(color: Colors.grey.shade300, height: 1),
                    ),
                  ],
                ),

                verticalSpacer(spacing: 25),
                // BUTTON
                MaterialButton(
                  color: Colors.blue.shade50,
                  elevation: 0,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("This feature is Coming Soon")),
                    );
                  },
                  padding: EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Image.asset('assets/icons/google.png', width: 20),
                      Text(
                        "continue with Google",
                        style: TextStyle(fontFamily: 'poppins'),
                      ),
                    ],
                  ),
                ),

                verticalSpacer(spacing: 50),

                // ALREADY HAVE AN ACCOUNT? SIGNIN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  spacing: 5,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(fontFamily: 'poppins'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colours.blue,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
