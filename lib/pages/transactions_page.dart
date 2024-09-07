import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:seco_app/service/transaction_service.dart';
import 'package:google_fonts/google_fonts.dart';
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TransactionService _transactionService = TransactionService();

  // Filtreleme için gerekli değişken
  String? _selectedFilter =
      'Hepsi'; // Varsayılan olarak tüm işlemleri gösterir.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'İşlemler',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Filtreleme için DropdownButton
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<String>(
              value: _selectedFilter,
              icon: const Icon(Icons.filter_list, color: Colors.white),
              dropdownColor: Colors.white,
              items: <String>['Hepsi', 'Alış', 'Satış']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFilter = newValue;
                });
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _transactionService.getTransactionsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final transactions = snapshot.data!.docs;

          // Filtreleme işlemi
          final filteredTransactions = transactions.where((transaction) {
            if (_selectedFilter == 'Hepsi') {
              return true;
            } else {
              return transaction['transaction_type'] == _selectedFilter;
            }
          }).toList();

          return ListView.builder(
            itemCount: filteredTransactions.length,
            itemBuilder: (context, index) {
              final transaction = filteredTransactions[index];

              return FutureBuilder(
                future: Future.wait([
                  _transactionService
                      .getCustomerName(transaction['customer_id']),
                  _transactionService.getProductName(transaction['product_id']),
                ]),
                builder: (context, AsyncSnapshot<List<String>> namesSnapshot) {
                  if (!namesSnapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final customerName = namesSnapshot.data![0];
                  final productName = namesSnapshot.data![1];

                  final transactionType = transaction['transaction_type'];
                  final double amount = transaction['amount'];
                  final Color statusColor = transactionType == 'Alış'
                      ? Colors.blue.shade100
                      : Colors.green.shade100;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Slidable(
                      key: Key(transaction.id),
                      startActionPane: ActionPane(
                        motion: const StretchMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) =>
                                _confirmDeleteTransaction(transaction.id),
                            backgroundColor: Colors.red,
                            icon: Icons.delete,
                            label: 'Sil',
                          ),
                        ],
                      ),
                      endActionPane: ActionPane(
                        motion: const StretchMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              Navigator.pushNamed(
                                context,
                                '/transactions/edit',
                                arguments: {'transactionId': transaction.id},
                              );
                            },
                            backgroundColor: Colors.blue,
                            icon: Icons.edit,
                            label: 'Düzenle',
                          ),
                        ],
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Müşteri: $customerName',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text('Ürün: $productName'),
                                  const SizedBox(height: 5),
                                  Text('İşlem Türü: $transactionType'),
                                  const SizedBox(height: 5),
                                  Text('İşlem Miktarı: $amount'),
                                  const SizedBox(height: 5),
                                  Text(
                                      'Tutar: ${(amount * transaction['price']).toStringAsFixed(2)} ₺'),
                                  const SizedBox(height: 5),
                                  Text(
                                      'Ödeme Durumu: ${transaction['status']}'),
                                  const SizedBox(height: 5),
                                  Text(
                                      'Ödeme Tipi: ${transaction['payment_type']}'),
                                ],
                              ),
                            ),
                            Container(
                              height: 4.0,
                              color: statusColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context,
              '/transactions/edit'); // Yeni işlem eklemek için yönlendirme
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Silme işleminden önce onay soran fonksiyon
  void _confirmDeleteTransaction(String transactionId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Silme İşlemi'),
        content: const Text('Bu işlemi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            child: const Text('Hayır'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text('Evet'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _transactionService.deleteTransaction(transactionId);
    }
  }
}
