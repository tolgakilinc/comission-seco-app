import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import '../service/product_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/custom_imput_field.dart'; // Custom input bileşeni
import '../components/register_button.dart'; // Register butonu bileşeni

class ProductEditPage extends StatefulWidget {
  final String? productId;

  const ProductEditPage({Key? key, this.productId}) : super(key: key);

  @override
  _ProductEditPageState createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final ProductService _productService = ProductService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _purchasePriceController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _stockQuantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedUnit;
  String? _selectedCategory;
  String? _selectedMoneyType;

  List<String> _units = ['Adet', 'Kg', 'Litre']; // Örnek birim seçenekleri
  List<String> _categories = ['Sebze', 'Meyve']; // Örnek kategori seçenekleri
  List<String> _moneyTypes = ['TRY', 'USD', 'EUR']; // Örnek para birimi seçenekleri

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProductData();
    }
  }

  Future<void> _loadProductData() async {
    DocumentSnapshot product = await _productService.getProductById(widget.productId!);
    setState(() {
      _nameController.text = product['name'];
      _purchasePriceController.text = product['purchase_price'].toString();
      _salePriceController.text = product['price'].toString();
      _stockQuantityController.text = product['stock_quantity'].toString();
      _notesController.text = product['notes'] ?? '';
      _selectedUnit = product['unit'];
      _selectedCategory = product['category'];
      _selectedMoneyType = product['money_type'];
    });
  }

  Future<void> _addOrEditProduct() async {
    String name = _nameController.text;
    double? purchasePrice = double.tryParse(_purchasePriceController.text);
    double? salePrice = double.tryParse(_salePriceController.text);
    double? stockQuantity = double.tryParse(_stockQuantityController.text);
    String notes = _notesController.text;

    if (name.isNotEmpty &&
        purchasePrice != null &&
        salePrice != null &&
        stockQuantity != null &&
        _selectedUnit != null &&
        _selectedMoneyType != null &&
        _selectedCategory != null) {
      if (widget.productId == null) {
        await _productService.addProduct(
          name: name,
          purchasePrice: purchasePrice,
          salePrice: salePrice,
          category: _selectedCategory!,
          unit: _selectedUnit!,
          moneyType: _selectedMoneyType!,
          stockQuantity: stockQuantity,
          notes: notes,
        );
        MotionToast.success(
          description: const Text('Ürün başarıyla eklendi!'),
          width: 300,
        ).show(context);
      } else {
        await _productService.updateProduct(
          productId: widget.productId!,
          name: name,
          purchasePrice: purchasePrice,
          salePrice: salePrice,
          category: _selectedCategory!,
          unit: _selectedUnit!,
          moneyType: _selectedMoneyType!,
          stockQuantity: stockQuantity,
          notes: notes,
        );
        MotionToast.success(
          description: const Text('Ürün başarıyla güncellendi!'),
          width: 300,
        ).show(context);
      }

      Navigator.pop(context);
    } else {
      MotionToast.error(
        description: const Text('Lütfen tüm alanları doldurun!'),
        width: 300,
      ).show(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _stockQuantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürün Ekle | Düzenle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomInputField(
                controller: _nameController,
                label: 'Ürün Adı',
              ),
              CustomInputField(
                controller: _purchasePriceController,
                label: 'Alış Fiyatı',
                keyboardType: TextInputType.number,
              ),
              CustomInputField(
                controller: _salePriceController,
                label: 'Satış Fiyatı',
                keyboardType: TextInputType.number,
              ),
              CustomInputField(
                controller: _stockQuantityController,
                label: 'Stok Miktarı',
                keyboardType: TextInputType.number,
              ),
              CustomInputField(
                controller: _notesController,
                label: 'Notlar',
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                decoration: const InputDecoration(labelText: 'Birim Seçin'),
                items: _units.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori Seçin'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedMoneyType,
                decoration: const InputDecoration(labelText: 'Para Birimi Seçin'),
                items: _moneyTypes.map((String moneyType) {
                  return DropdownMenuItem<String>(
                    value: moneyType,
                    child: Text(moneyType),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMoneyType = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              RegisterButton(
                onPressed: _addOrEditProduct, // Register butonuna tıklanınca ürün eklenecek veya güncellenecek
              ),
            ],
          ),
        ),
      ),
    );
  }
}
