import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Category {
  final int index;
  final String name;
  final IconData? icon;
  final Color color;
  final String description;

  Category({this.index = -1, this.name = '', this.icon, this.color = Colors.white, this.description = ''});
}

List<Category> categories = [
  Category(index: 0, name: 'General', icon: FontAwesomeIcons.receipt, color: Colors.grey[200]!, description: ''),
  Category(
      index: 1, name: 'Food & drink', icon: FontAwesomeIcons.pizzaSlice, color: Colors.yellow[200]!, description: 'groceries, restaurants, liquor'),
  Category(index: 2, name: 'Entertainment', icon: FontAwesomeIcons.film, color: Colors.blue[200]!, description: 'games, sports, movies'),
  Category(index: 3, name: 'Home', icon: FontAwesomeIcons.houseChimney, color: Colors.green[200]!, description: 'repairs, furniture, utilities'),
  Category(index: 4, name: 'Life', icon: FontAwesomeIcons.gift, color: Colors.pink[200]!, description: 'clothes, insurance, gifts'),
  Category(index: 5, name: 'Transportation', icon: FontAwesomeIcons.car, color: Colors.brown[200]!, description: 'car, commute, parking'),
];
