import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Müşterileri stream olarak getirme
  Stream<QuerySnapshot> getCustomersStream() {
    return _firestore.collection('customers').snapshots();
  }

  // Müşteri ekleme
  Future<void> addCustomer({
    required String name,
    required String email,
    required String phoneNumber,
    required DateTime registrationDate,
    required bool active,
    required String vkn, // Vergi Kimlik Numarası
    required String customerType, // Müşteri tipi (bireysel/kurumsal)
  }) async {
    await _firestore.collection('customers').add({
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'registration_date': registrationDate,
      'active': active,
      'vkn': vkn, // VKN alanı
      'customer_type': customerType, // Müşteri tipi
    });
  }

  // Müşteri güncelleme
  Future<void> updateCustomer({
    required String customerId,
    required String name,
    required String email,
    required String phoneNumber,
    required bool active,
    required String vkn, // Vergi Kimlik Numarası
    required String customerType, // Müşteri tipi (bireysel/kurumsal)
  }) async {
    await _firestore.collection('customers').doc(customerId).update({
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'active': active,
      'vkn': vkn, // VKN güncelleniyor
      'customer_type': customerType, // Müşteri tipi güncelleniyor
    });
  }

  // Müşteri silme
  Future<void> deleteCustomer(String customerId) async {
    await _firestore.collection('customers').doc(customerId).delete();
  }

  // Müşteriyi customerId ile getirme
  Future<DocumentSnapshot> getCustomerById(String customerId) async {
    return await _firestore.collection('customers').doc(customerId).get();
  }
}
