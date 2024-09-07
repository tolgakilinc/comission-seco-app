import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ürün ekleme
  Future<void> addProduct({
    required String name,
    required double purchasePrice,
    required double salePrice,
    required String category, // Ürün grubu (Sebze, Meyve)
    required String unit, // Birim bilgisi
    required String moneyType, // Para birimi bilgisi
  }) async {
    await _firestore.collection('products').add({
      'name': name,
      'purchase_price': purchasePrice,
      'price': salePrice,
      'category': category, // Ürün grubu kaydediliyor
      'unit': unit, // Birim bilgisi
      'money_type': moneyType, // Para birimi bilgisi
      'stock_quantity': 0.0, // Başlangıçta sıfır stok
      'purchases': [], // Alış geçmişi
      'sales': [], // Satış geçmişi
    });
  }

  // Ürün güncelleme
  Future<void> updateProduct({
    required String productId,
    required String name,
    required double purchasePrice,
    required double salePrice,
    required String category, // Ürün grubu (Sebze, Meyve)
    required String unit, // Birim bilgisi
    required String moneyType, // Para birimi bilgisi
  }) async {
    await _firestore.collection('products').doc(productId).update({
      'name': name,
      'purchase_price': purchasePrice,
      'price': salePrice,
      'category': category, // Ürün grubu güncelleniyor
      'unit': unit, // Birim bilgisi güncelleniyor
      'money_type': moneyType, // Para birimi bilgisi güncelleniyor
    });
  }

  // Ürünleri listeleme (stream olarak)
  Stream<QuerySnapshot> getProductsStream() {
    return _firestore.collection('products').snapshots();
  }

  // Ürün silme
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  // Ürünün fiyatlarını getir (alış ve satış)
  Future<Map<String, double>> getProductPrices(String productId) async {
    DocumentSnapshot productSnapshot = await _firestore.collection('products').doc(productId).get();
    return {
      'purchase_price': productSnapshot['purchase_price'],
      'sale_price': productSnapshot['price'], // Satış fiyatı 'price' alanında tutuluyor
    };
  }

  // Ürünün tüm bilgilerini almak için
  Future<DocumentSnapshot> getProductById(String productId) async {
    return await _firestore.collection('products').doc(productId).get();
  }

  // Ürünleri getirme
  Future<List<Map<String, dynamic>>> getProducts() async {
    QuerySnapshot snapshot = await _firestore.collection('products').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}
