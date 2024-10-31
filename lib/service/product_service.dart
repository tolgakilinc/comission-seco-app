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
    required double stockQuantity, // Stok miktarı
    required String notes, // Notlar
  }) async {
    await _firestore.collection('products').add({
      'name': name,
      'purchase_price': purchasePrice,
      'price': salePrice,
      'category': category,
      'unit': unit,
      'money_type': moneyType,
      'stock_quantity': stockQuantity,
      'purchases': [],
      'sales': [],
      'notes': notes,
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
    required double stockQuantity, // Stok miktarı
    required String notes, // Notlar
  }) async {
    await _firestore.collection('products').doc(productId).update({
      'name': name,
      'purchase_price': purchasePrice,
      'price': salePrice,
      'category': category,
      'unit': unit,
      'money_type': moneyType,
      'stock_quantity': stockQuantity,
      'notes': notes,
    });
  }

 // Ürün stoklarını artırma (Alış işlemi)
  Future<void> increaseProductStock(String productId, double amount) async {
    DocumentSnapshot productSnapshot = await _firestore.collection('products').doc(productId).get();
    
    // Stok miktarının doğru şekilde alındığından emin olun (int -> double dönüştürmesi gerekebilir)
    double currentStock = (productSnapshot['stock_quantity'] as num).toDouble(); 
    double updatedStock = currentStock + amount;

    await _firestore.collection('products').doc(productId).update({
      'stock_quantity': updatedStock,
    });
  }

  // Ürün stoklarını azaltma (Satış işlemi) ve stok kontrolü
  Future<bool> decreaseProductStock(String productId, double amount) async {
    DocumentSnapshot productSnapshot = await _firestore.collection('products').doc(productId).get();

    // Stok miktarının doğru şekilde alındığından emin olun (int -> double dönüştürmesi gerekebilir)
    double currentStock = (productSnapshot['stock_quantity'] as num).toDouble();

    if (currentStock < amount) {
      // Eğer stok miktarı yetersizse işlem yapılamaz
      return false;
    }

    double updatedStock = currentStock - amount;

    await _firestore.collection('products').doc(productId).update({
      'stock_quantity': updatedStock,
    });

    return true;
  }

  // Ürünü id'ye göre almak için
  Future<DocumentSnapshot> getProductById(String productId) async {
    return await _firestore.collection('products').doc(productId).get();
  }

  // Ürünleri stream olarak almak için
  Stream<QuerySnapshot> getProductsStream() {
    return _firestore.collection('products').snapshots();
  }

  // Ürün silme
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  // Ürün fiyatlarını alma metodu (alış ve satış fiyatlarını döner)
  Future<Map<String, double>> getProductPrices(String productId) async {
    try {
      DocumentSnapshot productSnapshot = await _firestore.collection('products').doc(productId).get();

      // Eğer ürün bulunursa alış ve satış fiyatlarını döndür
      if (productSnapshot.exists) {
        double purchasePrice = (productSnapshot['purchase_price'] as num).toDouble(); // Alış fiyatı
        double salePrice = (productSnapshot['price'] as num).toDouble(); // Satış fiyatı

        return {
          'purchase_price': purchasePrice,
          'sale_price': salePrice,
        };
      } else {
        throw Exception('Ürün bulunamadı');
      }
    } catch (e) {
      print("Ürün fiyatları alınırken hata: $e");
      rethrow;
    }
  }
}