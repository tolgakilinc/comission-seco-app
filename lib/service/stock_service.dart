import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_service.dart';  // Ürün işlemleri için ProductService ekleniyor

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductService _productService = ProductService();  // Ürün servisinden yararlanıyoruz

  // İşlem ekleme
  Future<String?> addTransaction({
    required String productId,
    required String customerId,
    required double amount,
    required String transactionType,
    required String paymentType,
    required String status,
    required DateTime date,
    required double totalPrice, // Toplam tutar
    required double price, // Alış veya Satış fiyatı
  }) async {
    // Satış işlemi sırasında yeterli stok var mı kontrol et
    if (transactionType == 'Satış') {
      bool isStockAvailable = await _productService.decreaseProductStock(productId, amount);
      if (!isStockAvailable) {
        return 'Yetersiz stok!';  // Yetersiz stok uyarısı
      }
    } else {
      // Alış işlemi, stoğu arttır
      await _productService.increaseProductStock(productId, amount);
    }

    // İşlemi kaydet
    await _firestore.collection('transactions').add({
      'product_id': productId,
      'customer_id': customerId,
      'amount': amount,
      'transaction_type': transactionType,
      'payment_type': paymentType,
      'status': status,
      'date': date,
      'total_price': totalPrice, // Toplam tutar kaydediliyor
      'price': price, // Alış veya Satış fiyatı kaydediliyor
    });

    return null;  // Hata yoksa null döndürüyoruz
  }

  // İşlem güncelleme
  Future<String?> updateTransaction({
    required String transactionId,
    required String productId,
    required String customerId,
    required double amount,
    required String transactionType,
    required String paymentType,
    required String status,
    required DateTime date,
    required double totalPrice, // Toplam tutar
    required double price, // Alış veya Satış fiyatı
  }) async {
    // Satış işlemi sırasında yeterli stok var mı kontrol et
    if (transactionType == 'Satış') {
      bool isStockAvailable = await _productService.decreaseProductStock(productId, amount);
      if (!isStockAvailable) {
        return 'Yetersiz stok!';  // Yetersiz stok uyarısı
      }
    } else {
      // Alış işlemi, stoğu arttır
      await _productService.increaseProductStock(productId, amount);
    }

    // İşlemi güncelle
    await _firestore.collection('transactions').doc(transactionId).update({
      'product_id': productId,
      'customer_id': customerId,
      'amount': amount,
      'transaction_type': transactionType,
      'payment_type': paymentType,
      'status': status,
      'date': date,
      'total_price': totalPrice, // Toplam tutar kaydediliyor
      'price': price, // Alış veya Satış fiyatı kaydediliyor
    });

    return null;  // Hata yoksa null döndürüyoruz
  }

  // İşlem silme
  Future<void> deleteTransaction(String transactionId) async {
    await _firestore.collection('transactions').doc(transactionId).delete();
  }

  // Tüm işlemleri stream olarak getirme
  Stream<QuerySnapshot> getTransactionsStream() {
    return _firestore.collection('transactions').snapshots();
  }

  // Müşteri listesini stream olarak getirme (formdaki dropdown için)
  Stream<QuerySnapshot> getCustomersStream() {
    return _firestore.collection('customers').snapshots();
  }

  // Ürün listesini stream olarak getirme (formdaki dropdown için)
  Stream<QuerySnapshot> getProductsStream() {
    return _firestore.collection('products').snapshots();
  }

  // Ürün stoklarını güncelleme (satış veya alış işlemleri için)
  Future<void> _updateProductStock(String productId, double amount, bool isSale) async {
    try {
      if (isSale) {
        // Satış işlemi, stoğu azalt
        await _productService.decreaseProductStock(productId, amount);
      } else {
        // Alış işlemi, stoğu arttır
        await _productService.increaseProductStock(productId, amount);
      }
    } catch (e) {
      print("Stok güncelleme hatası: $e");
    }
  }

  // İşlem verilerini almak için (düzenleme modunda formu doldurmak amacıyla)
  Future<DocumentSnapshot> getTransactionById(String transactionId) async {
    return await _firestore.collection('transactions').doc(transactionId).get();
  }

  // Müşterilerin adlarını almak için
  Future<String> getCustomerName(String customerId) async {
    DocumentSnapshot customerSnapshot = await _firestore.collection('customers').doc(customerId).get();
    return customerSnapshot['name'];
  }

  // Ürünlerin adlarını almak için
  Future<String> getProductName(String productId) async {
    DocumentSnapshot productSnapshot = await _firestore.collection('products').doc(productId).get();
    return productSnapshot['name'];
  }

  // Ürünlerin fiyatlarını almak için
  Future<Map<String, double>> getProductPrices(String productId) async {
    DocumentSnapshot productSnapshot = await _firestore.collection('products').doc(productId).get();
    return {
      'purchase_price': productSnapshot['purchase_price'],
      'sale_price': productSnapshot['price'], // Satış fiyatı 'price' alanında tutuluyor
    };
  }
}
