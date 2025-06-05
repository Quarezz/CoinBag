import 'package:flutter/material.dart';

class AppDecorations {
  static const Map<String, IconData> icons = {
    'Shopping': Icons.shopping_cart,
    'Food': Icons.fastfood,
    'Car': Icons.directions_car,
    'Home': Icons.home,
    'Movie': Icons.movie,
    'Medical': Icons.local_hospital,
    'Travel': Icons.flight,
    'Work': Icons.work,
    'Fitness': Icons.fitness_center,
    'Education': Icons.school,
    'Pets': Icons.pets,
    'Gifts': Icons.card_giftcard,
    'Other': Icons.category,
  };

  static const Map<String, Color> displayColors = {
    'Red': Colors.red,
    'Green': Colors.green,
    'Blue': Colors.blue,
    'Orange': Colors.orange,
    'Purple': Colors.purple,
    'Pink': Colors.pink,
    'Teal': Colors.teal,
    'Yellow': Colors.yellow,
    'Brown': Colors.brown,
    'Grey': Colors.grey,
    'Cyan': Colors.cyan,
    'Lime': Colors.lime,
  };

  static String colorToHex(Color color) {
    return color.value
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2)
        .toUpperCase();
  }

  static Color hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) {
      return Colors.grey; // Default color
    }
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey; // Default on error
    }
  }
}
