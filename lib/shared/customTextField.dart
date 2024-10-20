import 'package:flutter/material.dart';

customTextField(String hint, TextEditingController controller,
    TextInputType? textInputType, int minLines, bool isObscure,
    {Function()? onClick}) {
  return TextField(
    obscureText: isObscure,
    onTap: onClick,
    maxLines: textInputType == TextInputType.multiline ? null : 1,
    minLines: minLines,
    keyboardType: textInputType,
    controller: controller,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          fontWeight: FontWeight.w600, color: Colors.black.withOpacity(0.4)),
      filled: true,
      fillColor: Color(0xFFD9D9D9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(
          width: 0,
          style: BorderStyle.none,
        ),
      ),
    ),
  );
}