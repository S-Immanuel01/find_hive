import 'package:flutter/material.dart';

class TextInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool autoCapitalizeLetters;
  final bool obscureText;
  final bool isPassword;
  final Function()? setObscure;

  const TextInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.autoCapitalizeLetters = false,
    this.obscureText = false,
    this.isPassword = false,
    this.setObscure,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        suffixIcon:
            isPassword
                ? IconButton(
                  onPressed: () {
                    setObscure!();
                  },
                  icon:
                      obscureText
                          ? Icon(Icons.remove_red_eye)
                          : Icon(Icons.remove_red_eye_outlined),
                )
                : Text(""),
      ),
      onChanged: (value) => controller.text = value,
      obscureText: obscureText,
      textCapitalization:
          autoCapitalizeLetters
              ? TextCapitalization.characters
              : TextCapitalization.none,
    );
  }
}
