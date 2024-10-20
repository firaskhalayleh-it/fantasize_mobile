import 'package:flutter/material.dart';

class BuildListTile {
  Widget buildListTile(String title, IconData icon, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing,
      onTap: () {
        // Handle tile tap if needed
      },
    );
  }
}