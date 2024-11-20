import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

searchBar(onQueryChanged) {
  return Container(
    padding: EdgeInsets.all(16),
    child: TextField(
      onChanged: onQueryChanged,
      decoration: InputDecoration(
        labelText: 'Search',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.search),
      ),
    ),
  );
}
