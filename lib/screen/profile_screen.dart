import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          const Text(
            'Guest User',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'guest@example.com',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Menu Items
          _buildMenuItem(
            context,
            icon: Icons.shopping_bag_outlined,
            title: 'My Orders',
            onTap: () {
              // Navigate to orders
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.favorite_border,
            title: 'Wishlist',
            onTap: () {
              // Navigate to wishlist
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.location_on_outlined,
            title: 'Shipping Addresses',
            onTap: () {
              // Navigate to addresses
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            onTap: () {
              // Navigate to payment methods
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              // Navigate to notifications
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              // Navigate to help
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              // Handle logout
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

