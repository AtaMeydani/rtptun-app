import 'package:flutter/material.dart';

class Destination {
  const Destination(this.index, this.title, this.icon, this.page);
  final int index;
  final String title;
  final IconData icon;
  final Widget page;
}
