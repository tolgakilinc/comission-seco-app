import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // Firestore'dan verileri toplu olarak çekme
  Future<Map<String, int>> _getDashboardData() async {
    int productsCount = (await FirebaseFirestore.instance.collection('products').get()).size;
    int stockCount = (await FirebaseFirestore.instance.collection('stock').get()).size;
    int customersCount = (await FirebaseFirestore.instance.collection('customers').get()).size;
    int paymentsCount = (await FirebaseFirestore.instance.collection('payments').get()).size;
    int transactionsCount = (await FirebaseFirestore.instance.collection('transactions').get()).size;

    return {
      'products': productsCount,
      'stock': stockCount,
      'customers': customersCount,
      'payments': paymentsCount,
      'transactions': transactionsCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              bool confirm = await _showLogoutConfirmationDialog(context);
              if (confirm) {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<Map<String, int>>(
            future: _getDashboardData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading data'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No data available'));
              } else {
                final data = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDashboardSummary(context, data),
                    const SizedBox(height: 20),
                    _buildMenuButtons(context),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Hayır'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Evet'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDashboardSummary(BuildContext context, Map<String, int> data) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      alignment: WrapAlignment.center,
      children: [
        _buildSummaryCard('Total Products', data['products']!, Colors.blue.shade100, Colors.blue, screenWidth),
        _buildSummaryCard('Total Stock', data['stock']!, Colors.green.shade100, Colors.green, screenWidth),
        _buildSummaryCard('Total Customers', data['customers']!, Colors.red.shade100, Colors.red, screenWidth),
        _buildSummaryCard('Total Payments', data['payments']!, Colors.orange.shade100, Colors.orange, screenWidth),
        _buildSummaryCard('Total Transactions', data['transactions']!, Colors.purple.shade100, Colors.purple, screenWidth),
      ],
    );
  }

  Widget _buildSummaryCard(String title, int count, Color backgroundColor, Color textColor, double screenWidth) {
    double cardWidth = screenWidth > 600 ? (screenWidth / 3 - 24) : screenWidth * 0.9;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(12),
        width: cardWidth,
        height: 120,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButtons(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMenuButton(context, 'Products', Icons.category, '/products'),
        _buildMenuButton(context, 'Stock', Icons.storage, '/stock'),
        _buildMenuButton(context, 'Customers', Icons.people, '/customers'),
        _buildMenuButton(context, 'Payments', Icons.payment, '/payments'),
        _buildMenuButton(context, 'Transactions', Icons.swap_horiz, '/transactions'),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, String route) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
