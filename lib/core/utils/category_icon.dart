import 'package:flutter/material.dart';

class CategoryIcon {
  static IconData getIcon(String iconName) {
    switch (iconName) {
      case 'science':
        return Icons.science;
      case 'geography':
        return Icons.public;
      case 'history':
        return Icons.history_edu;
      case 'art':
        return Icons.palette;
      case 'technology':
        return Icons.computer;
      default:
        return Icons.quiz;
    }
  }
}