import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seco_app/service/transaction_service.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({Key? key}) : super(key: key);

  @override
  _AnnouncementsPageState createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final TransactionService _transactionService = TransactionService();

  @override
  Widget build(BuildContext context) {
    // MediaQuery ile ekran genişliğini ve yüksekliğini almak
    final mediaWidth = MediaQuery.of(context).size.width;
    final mediaHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duyurular'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: mediaWidth * 0.05, // Ekran genişliğine göre padding
            vertical: mediaHeight * 0.02, // Ekran yüksekliğine göre padding
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stokta olmayan ürünler
              StreamBuilder<QuerySnapshot>(
                stream: _transactionService.getZeroStockProducts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const ListTile(
                      title: Text('Stokta olmayan ürün bulunmamaktadır.'),
                    );
                  }

                  final products = snapshot.data!.docs;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: products.map((product) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          title: Text('Stokta olmayan ürün: ${product['name']}'),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const Divider(),
              // 1 gün içinde yaklaşan ödemeler
              StreamBuilder<QuerySnapshot>(
                stream: _transactionService.getUpcomingPayments(days: 1),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const ListTile(
                      title: Text('1 gün içinde yaklaşan ödeme bulunmamaktadır.'),
                    );
                  }

                  final payments = snapshot.data!.docs;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: payments.map((payment) {
                      final dueDate = (payment['collection_date'] as Timestamp).toDate();
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          title: Text('Yaklaşan ödeme: ${payment['total_price']} ₺'),
                          subtitle: Text(
                            'Ödeme tarihi: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
