import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import './customer_edit_page.dart';
import '../service/customer_service.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({Key? key}) : super(key: key);

  @override
  _CustomersPageState createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final CustomerService _customerService = CustomerService();

  Future<void> _deleteCustomer(String customerId) async {
    try {
      await _customerService.deleteCustomer(customerId);
      MotionToast.delete(
        description: const Text('Müşteri başarıyla silindi!'),
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
          content: const Text('Bu müşteriyi silmek istediğinizden emin misiniz?'),
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
    // MediaQuery kullanarak ekran genişliği ve yüksekliğini alıyoruz
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth > 600; // 600px üzeri ekranlar geniş ekran olarak kabul ediliyor

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Müşteriler',
          style: GoogleFonts.poppins(
            fontSize: isLargeScreen ? 28 : 24, // Geniş ekranlarda daha büyük başlık
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _customerService.getCustomersStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final customers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Slidable(
                  key: Key(customer.id),
                  startActionPane: ActionPane(
                    motion: const StretchMotion(),
                    dismissible: DismissiblePane(onDismissed: () {
                      _deleteCustomer(customer.id);
                    }),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          bool confirm = await _confirmDelete(context);
                          if (confirm) {
                            _deleteCustomer(customer.id);
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
                        onPressed: (context) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomerEditPage(customerId: customer.id),
                          ),
                        ),
                        backgroundColor: Colors.blue,
                        icon: Icons.edit,
                        label: 'Düzenle',
                      ),
                    ],
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0), // Geniş ekranda daha fazla padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    customer['name'],
                                    style: TextStyle(
                                      fontSize: isLargeScreen ? 22 : 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    customer['active'] ? Icons.check_circle : Icons.cancel,
                                    color: customer['active'] ? Colors.green : Colors.red,
                                    size: isLargeScreen ? 28 : 24, // Durum ikonunu belirginleştiriyoruz
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.email, size: isLargeScreen ? 18 : 16, color: Colors.grey[700]),
                                  const SizedBox(width: 8),
                                  Text(
                                    customer['email'],
                                    style: TextStyle(fontSize: isLargeScreen ? 18 : 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.phone, size: isLargeScreen ? 18 : 16, color: Colors.grey[700]),
                                  const SizedBox(width: 8),
                                  Text(
                                    customer['phone_number'],
                                    style: TextStyle(fontSize: isLargeScreen ? 18 : 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.account_balance, size: isLargeScreen ? 18 : 16, color: Colors.grey[700]),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Vergi Kimlik No: ${customer['vkn']}',
                                    style: TextStyle(fontSize: isLargeScreen ? 18 : 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.person, size: isLargeScreen ? 18 : 16, color: Colors.grey[700]),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Müşteri Tipi: ${customer['customer_type']}',
                                    style: TextStyle(fontSize: isLargeScreen ? 18 : 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(
                                    Icons.toggle_on,
                                    size: isLargeScreen ? 18 : 16,
                                    color: customer['active'] ? Colors.green : Colors.yellow[800],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Durum: ${customer['active'] ? 'Aktif' : 'Pasif'}',
                                    style: TextStyle(fontSize: isLargeScreen ? 18 : 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 4.0,
                          decoration: BoxDecoration(
                            color: customer['active'] ? Colors.green.shade600 : Colors.yellow.shade600,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(15.0),
                              bottomRight: Radius.circular(15.0),
                            ),
                          ),
                        ),
                      ],
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomerEditPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
