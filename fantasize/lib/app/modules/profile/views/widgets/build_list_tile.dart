import 'package:flutter/material.dart';

class BuildListTile {
  Widget buildListTile(String title, Widget icon, {Widget? trailing}) {
    return ListTile(
      leading: icon,
      title: Text(title),
      trailing: trailing,
      onTap: () {
        // Handle tile tap if needed
      },
    );
  }
}