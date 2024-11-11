import 'package:flutter/material.dart';

class BuildSection {
  Widget buildSection(String title, List<Widget> children) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontFamily: 'Jost',
            fontWeight: FontWeight.bold),
      ),
      children: children.isNotEmpty
          ? children
          : [ListTile(title: Text('No information available'))],
    );
  }
}
