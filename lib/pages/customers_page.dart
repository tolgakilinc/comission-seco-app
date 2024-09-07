import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../service/customer_service.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({Key? key}) : super(key: key);

  @override
  _CustomersPageState createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final CustomerService _customerService = CustomerService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isActive = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _addOrEditCustomer(String? customerId) async {
    String name = _nameController.text;
    String email = _emailController.text;
    String phone = _phoneController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      MotionToast.error(
        description: const Text('Lütfen ad, e-posta ve telefon bilgilerini doldurun.'),
        width: 300,
      ).show(context);
      return;
    }

    try {
      if (customerId == null) {
        await _customerService.addCustomer(
          name: name,
          email: email,
          phoneNumber: phone,
          registrationDate: DateTime.now(),
          active: _isActive,
        );
        MotionToast.success(description: const Text('Müşteri başarıyla eklendi!'), width: 300).show(context);
      } else {
        await _customerService.updateCustomer(
          customerId: customerId,
          name: name,
          email: email,
          phoneNumber: phone,
          active: _isActive,
        );
        MotionToast.success(description: const Text('Müşteri başarıyla güncellendi!'), width: 300).show(context);
      }
    } catch (e) {
      MotionToast.error(description: Text('Bir hata oluştu: $e'), width: 300).show(context);
    }
  }

  Future<void> _showAddEditDialog(BuildContext context, [DocumentSnapshot? customer]) async {
    if (customer != null) {
      _nameController.text = customer['name'];
      _emailController.text = customer['email'];
      _phoneController.text = customer['phone_number'];
      setState(() {
        _isActive = customer['active'];
      });
    } else {
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      setState(() {
        _isActive = true;
      });
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(customer == null ? 'Müşteri Ekle' : 'Müşteriyi Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Aktif Müşteri', style: TextStyle(fontSize: 14)),
                    Switch(
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Ad'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-posta'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Telefon Numarası'),
                  keyboardType: TextInputType.phone,
                ),
              ],
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
                _addOrEditCustomer(customer?.id);
                Navigator.pop(context);
              },
              child: const Text('Kaydet'),
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
        title: Text('Müşteriler', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
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
              final bool isActive = customer['active'];

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
                        onPressed: (context) => _showAddEditDialog(context, customer),
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
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(customer['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              Text('E-posta: ${customer['email']}'),
                              const SizedBox(height: 5),
                              Text('Telefon: ${customer['phone_number']}'),
                              const SizedBox(height: 5),
                              Text('Durum: ${isActive ? 'Aktif' : 'Pasif'}'),
                            ],
                          ),
                        ),
                        Container(
                          height: 4.0,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green.shade600 : Colors.yellow.shade600,
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
          _showAddEditDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteCustomer(String customerId) async {
    try {
      await _customerService.deleteCustomer(customerId);
      MotionToast.delete(description: const Text('Müşteri başarıyla silindi!'), width: 300).show(context);
    } catch (e) {
      MotionToast.error(description: Text('Silme işlemi başarısız oldu: $e'), width: 300).show(context);
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
}
