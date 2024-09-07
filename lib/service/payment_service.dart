import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ürün ekleme
  Future<void> addProduct({
    required String name,
    required double price,
    required String category,
    required int stockQuantity,
    required String unit, // Yeni eklenen birim
  }) async {
    await _firestore.collection('products').add({
      'name': name,
      'price': price,
      'category': category,
      'stock_quantity': stockQuantity,
      'unit': unit, // Ürün birimi
      'sales': [], // Satış geçmişi için
    });
  }

  // Ürün güncelleme
  Future<void> updateProduct({
    required String productId,
    required String name,
    required double price,
    required String category,
    required int stockQuantity,
    required String unit, // Birim güncelleme
  }) async {
    await _firestore.collection('products').doc(productId).update({
      'name': name,
      'price': price,
      'category': category,
      'stock_quantity': stockQuantity,
      'unit': unit, // Birim güncelleme
    });
  }

  // Ürün silme
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  // Ürünleri listeleme (stream olarak)
  Stream<QuerySnapshot> getProductsStream() {
    return _firestore.collection('products').snapshots();
  }
}
