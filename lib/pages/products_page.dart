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
    // MediaQuery kullanarak ekran boyutlarını alıyoruz
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Sağ ve soldan boşluk ekledik
                child: Slidable(
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
                        onPressed: (context) {
                          Navigator.pushNamed(
                            context,
                            '/products/edit', // Düzenleme sayfasına yönlendirme
                            arguments: {'productId': product.id},
                          );
                        },
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
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ekran genişliğine göre dinamik olarak font boyutu ayarlıyoruz
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                product['name'],
                                style: TextStyle(
                                  fontSize: screenWidth > 600 ? 26 : 20, // Geniş ekranlarda büyük yazı
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.local_grocery_store,
                                color: Colors.green,
                                size: screenWidth > 600 ? 26 : 20, // İkon ekledik, boyut ekran genişliğine göre
                              ),
                            ],
                          ),
                          const SizedBox(height: 10), // Yükseklik ayarı
                          Text(
                            'Alış Fiyatı: ${product['purchase_price']} ₺',
                            style: TextStyle(
                              fontSize: screenWidth > 600 ? 20 : 16,
                              color: Colors.grey[700], // Gri tonlarında stil
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Satış Fiyatı: ${product['price']} ₺',
                            style: TextStyle(
                              fontSize: screenWidth > 600 ? 20 : 16,
                              color: Colors.orange[800], // Satış fiyatını vurguladık
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Birim: ${product['unit']}',
                                style: TextStyle(
                                  fontSize: screenWidth > 600 ? 20 : 16, // Ekran genişliğine göre boyut
                                ),
                              ),
                              Text(
                                'Kategori: ${product['category']}',
                                style: TextStyle(
                                  fontSize: screenWidth > 600 ? 20 : 16, // Ekran genişliğine göre boyut
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Stok Miktarı: ${product['stock_quantity']}',
                            style: TextStyle(
                              fontSize: screenWidth > 600 ? 20 : 16,
                              color: Colors.blue[700], // Stok miktarını vurguladık
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/products/edit', // Yeni ürün ekleme sayfasına yönlendirme
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
