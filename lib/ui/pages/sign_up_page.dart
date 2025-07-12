import 'package:find_hive/domain/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/constants/colors.dart';
import '../components/horizontal_spacer.dart';
import '../components/text_input_field.dart';
import '../components/vertical_spacer.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _regNoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _obscureText = true;
  String errMessage = 'Successful';
  bool loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _regNoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void signUp(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _regNoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All Fields should be properly filled")),
      );
      return;
    }
    setState(() {
      loading = true;
    });

    final UserModel user = UserModel(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      regNo: _regNoController.text.trim(),
      password: _passwordController.text.trim(),
    );

    await user.signUp();

    errMessage = user.error;

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   showDialog(
    //     context: context,
    //     builder:
    //         (context) => AlertDialog(
    //           content: Text(errMessage),
    //           actions: [
    //             TextButton(
    //               onPressed: () {
    //                 Navigator.pop(context);
    //               },
    //               child: Text("Close"),
    //             ),
    //           ],
    //         ),
    //   );
    // });

    setState(() {
      loading = false;
    });

    if (FirebaseAuth.instance.currentUser != null) {
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
                verticalSpacer(spacing: screenParam.height * .05),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create account',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      Text(
                        'step in to get fast and efficient attendance',
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
                // Staff registeration number format: BU21CSC1071
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 20,
                  children: [
                    TextInputField(
                      controller: _nameController,
                      label: 'Name',
                      hintText: 'JohnDoe',
                    ),
                    TextInputField(
                      controller: _regNoController,
                      label: 'Reg No',
                      hintText: 'BU20CSC****',
                      autoCapitalizeLetters: true,
                    ),
                    TextInputField(
                      controller: _emailController,
                      label: 'Email',
                      hintText: 'johndoe@email.com',
                      autoCapitalizeLetters: false,
                    ),
                    TextInputField(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: '********',
                      autoCapitalizeLetters: false,
                      obscureText: _obscureText,
                      isPassword: true,
                      setObscure:
                          () => setState(() => _obscureText = !_obscureText),
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
                          "Sign Up",
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
                      'or sign Up with',
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
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Coming Soon")));
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
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'Sign In',
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
