import 'package:flutter/material.dart';

primaryButton(title, onClick) {
  return SizedBox(
    width: 140,
    height: 40,
    child: ElevatedButton(
      onPressed: onClick,
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: Color(0xFF3A7CA5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),
    ),
  );
}
