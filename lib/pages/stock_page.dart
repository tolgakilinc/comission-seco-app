import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class StockPage extends StatefulWidget {
  const StockPage({Key? key}) : super(key: key);

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  @override
  Widget build(BuildContext context) {
    // Ekran genişliğine göre duyarlı düzenlemeler yapmak için MediaQuery kullanıyoruz
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600; // Büyük ekranları belirlemek için kullanılan eşik

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stoklar',
          style: GoogleFonts.poppins(
            fontSize: isLargeScreen ? 28 : 24, // Büyük ekranlarda başlık boyutu artıyor
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final stockItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: stockItems.length,
            itemBuilder: (context, index) {
              final stockItem = stockItems[index];
              final String productName = stockItem['name'];
              final double stockQuantity = stockItem['stock_quantity'];
              final String unit = stockItem['unit'];

              // Stok miktarına göre arka plan rengi ayarlanıyor
              final Color backgroundColor = stockQuantity > 0
                  ? Colors.greenAccent.shade100
                  : Colors.redAccent.shade100;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0), // Kartın köşeleri daha yuvarlatıldı
                  ),
                  color: backgroundColor, // Stok durumuna göre arka plan rengi
                  child: ListTile(
                    contentPadding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
                    leading: Icon(
                      Icons.storage,
                      size: isLargeScreen ? 48 : 40, // Ekran genişliğine göre simge boyutu ayarlandı
                      color: Colors.black87,
                    ),
                    title: Text(
                      productName,
                      style: GoogleFonts.poppins(
                        fontSize: isLargeScreen ? 24 : 20, // Büyük ekranlarda daha büyük yazı
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'Stok Miktarı: $stockQuantity $unit',
                      style: GoogleFonts.poppins(
                        fontSize: isLargeScreen ? 20 : 16, // Ekran genişliğine göre yazı boyutu
                        color: Colors.black54,
                      ),
                    ),
                    trailing: stockQuantity > 0
                        ? Icon(Icons.check_circle, color: Colors.green[700], size: isLargeScreen ? 30 : 24)
                        : Icon(Icons.warning, color: Colors.red[700], size: isLargeScreen ? 30 : 24),
                    // Stok durumuna göre sağ tarafta bir simge ekledik
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
