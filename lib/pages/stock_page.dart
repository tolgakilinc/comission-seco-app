import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:google_fonts/google_fonts.dart';

class StockPage extends StatefulWidget {
  const StockPage({Key? key}) : super(key: key);

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final TextEditingController _productIdController = TextEditingController();
  final TextEditingController _stockInController = TextEditingController();
  final TextEditingController _stockOutController = TextEditingController();

  Future<void> _addOrEditStock(String? stockId) async {
    String productId = _productIdController.text;
    int? stockIn = int.tryParse(_stockInController.text);
    int? stockOut = int.tryParse(_stockOutController.text);

    if (productId.isNotEmpty && stockIn != null && stockOut != null) {
      if (stockId == null) {
        await FirebaseFirestore.instance.collection('stock').add({
          'product_id': productId,
          'stock_in': stockIn,
          'stock_out': stockOut,
        });
        MotionToast.success(
          description: const Text('Stok başarıyla eklendi!'),
          width: 300,
        ).show(context);
      } else {
        await FirebaseFirestore.instance.collection('stock').doc(stockId).update({
          'product_id': productId,
          'stock_in': stockIn,
          'stock_out': stockOut,
        });
        MotionToast.success(
          description: const Text('Stok başarıyla güncellendi!'),
          width: 300,
        ).show(context);
      }
    }
  }

  Future<void> _deleteStock(String stockId) async {
    await FirebaseFirestore.instance.collection('stock').doc(stockId).delete();
    MotionToast.delete(
      description: const Text('Stok başarıyla silindi!'),
      width: 300,
    ).show(context);
  }

  Future<void> _showAddEditDialog(BuildContext context, [DocumentSnapshot? stock]) async {
    if (stock != null) {
      _productIdController.text = stock['product_id'];
      _stockInController.text = stock['stock_in'].toString();
      _stockOutController.text = stock['stock_out'].toString();
    } else {
      _productIdController.clear();
      _stockInController.clear();
      _stockOutController.clear();
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(stock == null ? 'Stok Ekle' : 'Stoku Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _productIdController,
                  decoration: const InputDecoration(labelText: 'Ürün ID'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _stockInController,
                  decoration: const InputDecoration(labelText: 'Stok Giriş'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _stockOutController,
                  decoration: const InputDecoration(labelText: 'Stok Çıkış'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                _addOrEditStock(stock?.id);
                Navigator.pop(context);
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Silme Onayı'),
          content: const Text('Bu stoğu silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stoklar',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('stock').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final stockItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: stockItems.length,
            itemBuilder: (context, index) {
              final stockItem = stockItems[index];

              return Dismissible(
                key: Key(stockItem.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.blue,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    bool confirm = await _confirmDelete(context);
                    if (confirm) {
                      _deleteStock(stockItem.id);
                      return true;
                    }
                    return false;
                  } else if (direction == DismissDirection.endToStart) {
                    _showAddEditDialog(context, stockItem);
                    return false;
                  }
                  return false;
                },
                child: ListTile(
                  title: Text('Ürün ID: ${stockItem['product_id']}'),
                  subtitle: Text('Stok Giriş: ${stockItem['stock_in']} - Stok Çıkış: ${stockItem['stock_out']}'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEditDialog(context); // Yeni stok eklemek için dialog aç
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
