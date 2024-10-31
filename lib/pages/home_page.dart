import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Çıkış işlemi için
import '../service/transaction_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double totalIncome = 0;
  double totalExpense = 0;
  double totalProfit = 0;
  bool hasAnnouncements = false; // Duyuru var mı kontrolü için

  final TransactionService _transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    _fetchTransactionData();
    _checkForAnnouncements(); // Duyuru var mı kontrol et
  }

  // Firestore'dan verileri dinamik olarak çekme
  Future<void> _fetchTransactionData() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('transactions').get();
      final transactions = snapshot.docs;

      double income = 0;
      double expense = 0;

      for (var transaction in transactions) {
        final transactionType = transaction['transaction_type'];
        final amount = transaction['total_price'];

        // Gelir ve gider hesaplaması
        if (transactionType == 'Satış') {
          income += amount;
        } else if (transactionType == 'Alış') {
          expense += amount;
        }
      }

      // Kar hesaplaması (Gelir - Gider)
      double profit = income - expense;

      setState(() {
        totalIncome = income;
        totalExpense = expense;
        totalProfit = profit;
      });
    } catch (e) {
      print('Veri çekme hatası: $e');
    }
  }

  // Duyuru kontrolü: Stokta olmayan ürünler ve 1 gün içinde ödemeler
  Future<void> _checkForAnnouncements() async {
    final zeroStockProducts = await _transactionService.getZeroStockProducts().first;
    final upcomingPayments = await _transactionService.getUpcomingPayments(days: 1).first;

    if (zeroStockProducts.docs.isNotEmpty || upcomingPayments.docs.isNotEmpty) {
      setState(() {
        hasAnnouncements = true; // Duyuru varsa true yap
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ana Sayfa',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          // Çıkış butonu
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
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.pushNamed(context, '/announcements');
                },
              ),
              if (hasAnnouncements)
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gelir, Gider ve Kar/Zarar Kutucukları
              _buildSummaryCards(),
              const SizedBox(height: 20),
              // Menü Butonları
              _buildMenuButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            _buildSummaryCard('Gelir', totalIncome, Colors.purple.shade100, Colors.purple, Icons.arrow_downward),
            const SizedBox(width: 10),
            _buildSummaryCard('Gider', totalExpense, Colors.orange.shade100, Colors.orange, Icons.arrow_upward),
          ],
        ),
        const SizedBox(height: 20),
        // Gelir Kartı
        _buildProfitCard(),
      ],
    );
  }

  // Kar ve Gelir kutucuğu
  Widget _buildProfitCard() {
    Color cardColor;
    Color textColor;

    if (totalProfit > 0) {
      cardColor = Colors.green.shade100;
      textColor = Colors.green;
    } else if (totalProfit < 0) {
      cardColor = Colors.red.shade100;
      textColor = Colors.red;
    } else {
      cardColor = Colors.yellow.shade100;
      textColor = Colors.yellow.shade700;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: textColor),
              const SizedBox(width: 10),
              Text('Bakiye', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '₺${NumberFormat.currency(locale: 'tr_TR', symbol: '').format(totalProfit)}',
            style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Gelir ve Gider kutucukları için özet kartı
  Widget _buildSummaryCard(String title, double amount, Color backgroundColor, Color iconColor, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '₺${NumberFormat.currency(locale: 'tr_TR', symbol: '').format(amount)}',
              style: TextStyle(color: iconColor, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Menüler için butonlar
  Widget _buildMenuButtons(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMenuButton(context, 'Ürünler', Icons.category, '/products'),
        _buildMenuButton(context, 'Stok', Icons.storage, '/stock'),
        _buildMenuButton(context, 'Müşteriler', Icons.people, '/customers'),
        _buildMenuButton(context, 'Ödemeler', Icons.payment, '/payments'),
        _buildMenuButton(context, 'İşlemler', Icons.swap_horiz, '/transactions'),
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

  // Çıkış onayı için dialog
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
}
