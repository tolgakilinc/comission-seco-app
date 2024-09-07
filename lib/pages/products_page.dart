import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../service/product_service.dart'; // ProductService dosyasını içe aktardık

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductService _productService = ProductService(); // ProductService instance

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _purchasePriceController = TextEditingController(); // Alış Fiyatı
  final TextEditingController _salePriceController = TextEditingController(); // Satış Fiyatı

  String? _selectedUnit; // Ürün birimi seçimi
  String? _selectedMoneyType; // Para birimi seçimi
  String? _selectedCategory; // Ürün grubu seçimi
  String _currencySymbol = '₺'; // Varsayılan para birimi sembolü

  List<String> _units = ['Adet', 'Kg', 'Litre']; // Ürün birim seçenekleri
  List<String> _moneyTypes = ['TRY', 'USD', 'EUR']; // Para birimi seçenekleri
  List<String> _categories = ['Sebze', 'Meyve']; // Ürün grubu seçenekleri
  Map<String, String> _currencySymbols = {
    'TRY': '₺',
    'USD': '\$',
    'EUR': '€',
  }; // Para birimi sembolleri

  @override
  void dispose() {
    _nameController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  Future<void> _addOrEditProduct(String? productId) async {
    String name = _nameController.text;
    double? purchasePrice = double.tryParse(_purchasePriceController.text); // Alış fiyatı
    double? salePrice = double.tryParse(_salePriceController.text); // Satış fiyatı

    if (name.isNotEmpty && purchasePrice != null && salePrice != null && _selectedUnit != null && _selectedMoneyType != null && _selectedCategory != null) {
      if (productId == null) {
        await _productService.addProduct(
          name: name,
          purchasePrice: purchasePrice, // Alış fiyatı
          salePrice: salePrice, // Satış fiyatı
          category: _selectedCategory!, // Ürün grubu
          unit: _selectedUnit!, // Birim bilgisi
          moneyType: _selectedMoneyType!, // Para birimi bilgisi
        );
        MotionToast.success(
          description: const Text('Ürün başarıyla eklendi!'),
          width: 300,
        ).show(context);
      } else {
        await _productService.updateProduct(
          productId: productId,
          name: name,
          purchasePrice: purchasePrice, // Alış fiyatı güncelleniyor
          salePrice: salePrice, // Satış fiyatı güncelleniyor
          category: _selectedCategory!, // Ürün grubu güncelleniyor
          unit: _selectedUnit!, // Birim bilgisi güncelleniyor
          moneyType: _selectedMoneyType!, // Para birimi bilgisi güncelleniyor
        );
        MotionToast.success(
          description: const Text('Ürün başarıyla güncellendi!'),
          width: 300,
        ).show(context);
      }
    } else {
      MotionToast.error(
        description: const Text('Lütfen tüm alanları doldurun ve geçerli seçimler yapın!'),
        width: 300,
      ).show(context);
    }
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _productService.deleteProduct(productId);
      MotionToast.delete(
        description: const Text('Ürün başarıyla silindi!'),
        width: 300,
      ).show(context);
    } catch (e) {
      MotionToast.error(
        description: Text('Silme işlemi başarısız oldu: $e'),
        width: 300,
      ).show(context);
    }
  }

  Future<void> _showAddEditDialog(BuildContext context, [DocumentSnapshot? product]) async {
    if (product != null) {
      _nameController.text = product['name'];
      _purchasePriceController.text = product['purchase_price']?.toString() ?? ''; // Alış fiyatı
      _salePriceController.text = product['price'].toString(); // Satış fiyatı
      _selectedUnit = product['unit']; // Birim bilgisi
      _selectedMoneyType = product['money_type']; // Para birimi bilgisi
      _selectedCategory = product['category']; // Ürün grubu
      _currencySymbol = _currencySymbols[_selectedMoneyType!] ?? '₺'; // Para birimi sembolü
    } else {
      _nameController.clear();
      _purchasePriceController.clear();
      _salePriceController.clear();
      _selectedUnit = null; // Birim sıfırlanıyor
      _selectedMoneyType = null; // Para birimi sıfırlanıyor
      _selectedCategory = null; // Ürün grubu sıfırlanıyor
      _currencySymbol = '₺'; // Varsayılan sembol sıfırlanıyor
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product == null ? 'Ürün Ekle' : 'Ürünü Düzenle'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8, // Genişlik ayarlandı
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Yazıları sola yasladık
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Ürün Adı'),
                    textAlign: TextAlign.left,
                    onChanged: (_) => setState(() {}), // Form verilerini dinleyerek anında güncelleme sağlıyor
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _purchasePriceController,
                    decoration: InputDecoration(labelText: 'Alış Fiyatı ($_currencySymbol)'),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.left,
                    onChanged: (_) => setState(() {}), // Form verilerini dinleyerek anında güncelleme sağlıyor
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _salePriceController,
                    decoration: InputDecoration(labelText: 'Satış Fiyatı ($_currencySymbol)'),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.left,
                    onChanged: (_) => setState(() {}), // Form verilerini dinleyerek anında güncelleme sağlıyor
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: _selectedUnit,
                    hint: const Text('Birim Seçin'),
                    items: _units.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUnit = value; // Anlık birim güncellemesi
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: _selectedMoneyType,
                    hint: const Text('Para Birimi Seçin'),
                    items: _moneyTypes.map((String moneyType) {
                      return DropdownMenuItem<String>(
                        value: moneyType,
                        child: Text(moneyType),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMoneyType = value; // Anlık para birimi güncellemesi
                        _currencySymbol = _currencySymbols[value!] ?? '₺'; // Para birimi sembolü güncelleniyor
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    hint: const Text('Ürün Grubu Seçin'),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value; // Anlık ürün grubu güncellemesi
                      });
                    },
                  ),
                ],
              ),
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
                _addOrEditProduct(product?.id);
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
          content: const Text('Bu ürünü silmek istediğinizden emin misiniz?'),
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
          'Ürünler',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _productService.getProductsStream(), // Ürünleri stream ile dinliyoruz
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data!.docs;

          return Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9, // Responsive genişlik
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  return Slidable(
                    key: Key(product.id),
                    startActionPane: ActionPane(
                      motion: const StretchMotion(),
                      dismissible: DismissiblePane(onDismissed: () {
                        _deleteProduct(product.id);
                      }),
                      children: [
                        SlidableAction(
                          onPressed: (context) async {
                            bool confirm = await _confirmDelete(context);
                            if (confirm) {
                              _deleteProduct(product.id);
                            }
                          },
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                          label: 'Sil',
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const StretchMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) => _showAddEditDialog(context, product),
                          backgroundColor: Colors.blue,
                          icon: Icons.edit,
                          label: 'Düzenle',
                        ),
                      ],
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text('Alış Fiyatı: $_currencySymbol${product['purchase_price']}'),
                            const SizedBox(height: 5),
                            Text('Satış Fiyatı: $_currencySymbol${product['price']}'),
                            const SizedBox(height: 5),
                            Text('Birim: ${product['unit']}'),
                            const SizedBox(height: 5),
                            Text('Para Birimi: ${product['money_type']}'),
                            const SizedBox(height: 5),
                            Text('Kategori: ${product['category']}'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEditDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
