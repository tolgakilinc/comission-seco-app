import 'package:cloud_firestore/cloud_firestore.dart';

class StockService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stok ekleme
  Future<void> addStock({
    required String productId,
    required int stockIn,
    required int stockOut,
    required DateTime date,
    String? note,
  }) async {
    await _firestore.collection('stock').add({
      'product_id': productId,
      'stock_in': stockIn,
      'stock_out': stockOut,
      'date': date,
      'note': note ?? '',
    });
  }

  // Stok listeleme
  Future<List<Map<String, dynamic>>> getStocks() async {
    QuerySnapshot snapshot = await _firestore.collection('stock').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Stok güncelleme
  Future<void> updateStock({
    required String stockId,
    required int stockIn,
    required int stockOut,
    required DateTime date,
    String? note,
  }) async {
    await _firestore.collection('stock').doc(stockId).update({
      'stock_in': stockIn,
      'stock_out': stockOut,
      'date': date,
      'note': note ?? '',
    });
  }

  // Stok silme
  Future<void> deleteStock(String stockId) async {
    await _firestore.collection('stock').doc(stockId).delete();
  }
}
