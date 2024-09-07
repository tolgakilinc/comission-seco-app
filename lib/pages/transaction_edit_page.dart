import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seco_app/service/transaction_service.dart';
import 'package:seco_app/service/product_service.dart';

class TransactionEditPage extends StatefulWidget {
  final String? transactionId;

  const TransactionEditPage({Key? key, this.transactionId}) : super(key: key);

  @override
  _TransactionEditPageState createState() => _TransactionEditPageState();
}

class _TransactionEditPageState extends State<TransactionEditPage> {
  final TransactionService _transactionService = TransactionService();
  final ProductService _productService = ProductService();

  String? selectedCustomerId;
  String? selectedProductId;
  String? transactionType;
  String? paymentType;
  String? status;
  String? unit;
  double? transactionAmount;
  double? price;
  double totalPrice = 0.0;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) {
      _loadTransactionData();
    }
  }

  // Düzenleme modundaysa işlem verilerini getir ve formu doldur
  Future<void> _loadTransactionData() async {
    try {
      DocumentSnapshot transaction = await _transactionService.getTransactionById(widget.transactionId!);
      
      if (transaction.exists) {
        setState(() {
          selectedCustomerId = transaction['customer_id'];
          selectedProductId = transaction['product_id'];
          transactionType = transaction['transaction_type'];
          paymentType = transaction['payment_type'];
          status = transaction['status'];
          transactionAmount = transaction['amount'];
          price = transaction['price'];
          totalPrice = transaction['total_price'];

          amountController.text = transactionAmount?.toString() ?? '';
          priceController.text = price?.toString() ?? '';

          // Ürün birimini al
          _fetchProductUnit(selectedProductId!);
        });
      }
    } catch (e) {
      print("Hata: $e");
    }
  }

  // Ürün birimi ve diğer detayları getir
  Future<void> _fetchProductUnit(String productId) async {
    try {
      final productDetails = await _productService.getProductById(productId);
      setState(() {
        unit = productDetails['unit'];
      });
    } catch (e) {
      print("Ürün birimi alırken hata: $e");
    }
  }

  // Ürün seçildiğinde fiyatları getir
  Future<void> _onProductSelected(String productId) async {
    try {
      final productPrices = await _productService.getProductPrices(productId);
      setState(() {
        selectedProductId = productId;
        if (transactionType == 'Satış') {
          price = productPrices['sale_price'];
        } else {
          price = productPrices['purchase_price'];
        }
        priceController.text = price!.toStringAsFixed(2);
        _calculateTotalPrice();

        // Ürün birimini al
        _fetchProductUnit(productId);
      });
    } catch (e) {
      print("Ürün verilerini alırken hata: $e");
    }
  }

  // Toplam fiyatı hesapla
  void _calculateTotalPrice() {
    if (transactionAmount != null && price != null) {
      setState(() {
        totalPrice = price! * transactionAmount!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transactionId == null ? 'Yeni İşlem Ekle' : 'İşlem Düzenle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerDropdown(),
              const SizedBox(height: 10),
              _buildProductDropdown(),
              const SizedBox(height: 10),
              _buildDropdown(
                items: ['Alış', 'Satış'],
                value: transactionType,
                label: 'İşlem Türü',
                onChanged: (value) {
                  setState(() {
                    transactionType = value;
                    if (selectedProductId != null) {
                      _onProductSelected(selectedProductId!);
                    }
                  });
                },
              ),
              const SizedBox(height: 10),
              _buildDropdown(
                items: ['Nakit', 'Kart', 'Havale'],
                value: paymentType,
                label: 'Ödeme Tipi',
                onChanged: (value) => setState(() => paymentType = value),
              ),
              const SizedBox(height: 10),
              _buildDropdown(
                items: ['Beklemede', 'Ödeme Alındı'],
                value: status,
                label: 'Ödeme Durumu',
                onChanged: (value) => setState(() => status = value),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Fiyat (${unit ?? ''})'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    price = double.tryParse(value) ?? 0.0;
                    _calculateTotalPrice();
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'İşlem Miktarı'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    transactionAmount = double.tryParse(value);
                    _calculateTotalPrice();
                  });
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Toplam Tutar: ${totalPrice.toStringAsFixed(2)} ₺',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTransaction,
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Müşteri dropdown
  Widget _buildCustomerDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: _transactionService.getCustomersStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final items = snapshot.data!.docs.map((doc) {
          return DropdownMenuItem<String>(
            value: doc.id,
            child: Text(doc['name']),
          );
        }).toList();

        return DropdownButtonFormField<String>(
          value: selectedCustomerId,
          items: items,
          onChanged: (value) => setState(() => selectedCustomerId = value),
          decoration: const InputDecoration(labelText: 'Müşteri Seç'),
        );
      },
    );
  }

  // Ürün dropdown
  Widget _buildProductDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: _transactionService.getProductsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final items = snapshot.data!.docs.map((doc) {
          return DropdownMenuItem<String>(
            value: doc.id,
            child: Text(doc['name']),
          );
        }).toList();

        return DropdownButtonFormField<String>(
          value: selectedProductId,
          items: items,
          onChanged: (value) => _onProductSelected(value!),
          decoration: const InputDecoration(labelText: 'Ürün Seç'),
        );
      },
    );
  }

  // Statik Dropdown
  Widget _buildDropdown({
    required List<String> items,
    required String? value,
    required String label,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }

  // İşlemi kaydet
  void _saveTransaction() {
    if (selectedCustomerId != null &&
        selectedProductId != null &&
        transactionType != null &&
        paymentType != null &&
        status != null &&
        transactionAmount != null &&
        price != null) {
      if (widget.transactionId == null) {
        _transactionService.addTransaction(
          productId: selectedProductId!,
          customerId: selectedCustomerId!,
          amount: transactionAmount!,
          transactionType: transactionType!,
          paymentType: paymentType!,
          status: status!,
          date: DateTime.now(),
          totalPrice: totalPrice,
          price: price!,  // Fiyat kaydediliyor
        );
      } else {
        _transactionService.updateTransaction(
          transactionId: widget.transactionId!,
          productId: selectedProductId!,
          customerId: selectedCustomerId!,
          amount: transactionAmount!,
          transactionType: transactionType!,
          paymentType: paymentType!,
          status: status!,
          date: DateTime.now(),
          totalPrice: totalPrice,
          price: price!,  // Fiyat güncelleniyor
        );
      }
      Navigator.pop(context);
    }
  }

  // İşlemi silmeden önce onay sor
  void _confirmDeleteTransaction() async {
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

    if (confirmed == true && widget.transactionId != null) {
      _transactionService.deleteTransaction(widget.transactionId!);
      Navigator.pop(context);
    }
  }
}
