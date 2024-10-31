import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seco_app/service/transaction_service.dart'; // TransactionService'i içe aktarın
import 'package:seco_app/service/product_service.dart'; // Ürün adı çekmek için ProductService'i içe aktarın

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TransactionService _transactionService = TransactionService();
  final ProductService _productService = ProductService();

  String? _selectedFilter = 'Hepsi'; // Filtreleme için dropdown değeri

  // Stream seçilen filtreye göre güncelleniyor
  Stream<QuerySnapshot> _getFilteredPayments() {
    if (_selectedFilter == '1 Gün') {
      return _transactionService.getUpcomingPayments(days: 1);
    } else if (_selectedFilter == '7 Gün') {
      return _transactionService.getUpcomingPayments(days: 7);
    } else if (_selectedFilter == '10 Gün') {
      return _transactionService.getUpcomingPayments(days: 10);
    } else {
      // Hepsi seçiliyse, tüm bekleyen ödemeleri getir
      return _transactionService.getUpcomingPayments(days: 365); // Bir yıl içindeki tüm ödemeleri getirir
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Yaklaşan Ödemeler',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Filtreleme Dropdown
          DropdownButton<String>(
            value: _selectedFilter,
            icon: const Icon(Icons.filter_list, color: Colors.white),
            dropdownColor: Colors.white,
            items: <String>['Hepsi', '1 Gün', '7 Gün', '10 Gün'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedFilter = newValue; // Seçili filtre güncellenir
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getFilteredPayments(), // Seçilen filtreye göre ödemeleri getiren stream
        builder: (context, snapshot) {
          // Veriler yüklenirken ilerleme göstergesi
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Eğer veri boşsa
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Bekleyen ödeme yok.',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final transactions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final double totalAmount = transaction['total_price'];
              final String productId = transaction['product_id']; // İlgili ürün ID'si
              final DateTime dueDate = (transaction['collection_date'] as Timestamp).toDate();
              final String paymentType = transaction['payment_type'];

              // Tarihe göre renk belirleme
              final Color backgroundColor = (DateTime.now().isBefore(dueDate))
                  ? Colors.orangeAccent.shade100
                  : Colors.redAccent.shade100;

              return FutureBuilder<DocumentSnapshot>(
                future: _productService.getProductById(productId), // Ürün adını almak için
                builder: (context, productSnapshot) {
                  if (!productSnapshot.hasData) {
                    return const CircularProgressIndicator(); // Ürün bilgileri yüklenirken
                  }

                  final productName = productSnapshot.data!['name'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: backgroundColor,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          'Ürün: $productName',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              'Ödeme Tutarı: ${totalAmount.toStringAsFixed(2)} ₺',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Ödeme Tarihi: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Ödeme Tipi: $paymentType',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
                            ),
                          ],
                        ),
                        leading: const Icon(
                          Icons.payment,
                          size: 40,
                          color: Colors.blueAccent,
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
    );
  }
}
