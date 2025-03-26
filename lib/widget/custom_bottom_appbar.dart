import 'package:flutter/material.dart';

class CustomBottomAppbar extends StatefulWidget {
  const CustomBottomAppbar({super.key});

  @override
  _CustomBottomAppbarState createState() => _CustomBottomAppbarState();
}

class _CustomBottomAppbarState extends State<CustomBottomAppbar> {
  int selectedIndex = -1;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 6.0,
      color: Colors.blue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.shopping_cart, 'Cart', 1),
          _buildNavItem(Icons.settings, 'Settings', 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selectedIndex == index ? Colors.yellow : Colors.white,
          ),
          Text(
            label,
            style: TextStyle(
              color: selectedIndex == index ? Colors.yellow : Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
