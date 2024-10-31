import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import '../service/customer_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/register_button.dart'; // RegisterButton bileşeni import edildi.

class CustomerEditPage extends StatefulWidget {
  final String? customerId;

  const CustomerEditPage({Key? key, this.customerId}) : super(key: key);

  @override
  _CustomerEditPageState createState() => _CustomerEditPageState();
}

class _CustomerEditPageState extends State<CustomerEditPage> {
  final CustomerService _customerService = CustomerService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _vknController = TextEditingController(); // Vergi Kimlik Numarası
  String? _selectedCustomerType = 'Bireysel'; // Müşteri tipi varsayılan olarak bireysel
  bool _isActive = true;

  List<String> _customerTypes = ['Bireysel', 'Kurumsal'];

  @override
  void initState() {
    super.initState();
    if (widget.customerId != null) {
      _loadCustomerData();
    }
  }

  Future<void> _loadCustomerData() async {
    DocumentSnapshot customer = await _customerService.getCustomerById(widget.customerId!);
    setState(() {
      _nameController.text = customer['name'];
      _emailController.text = customer['email'];
      _phoneController.text = customer['phone_number'];
      _vknController.text = customer['vkn'];
      _selectedCustomerType = customer['customer_type'];
      _isActive = customer['active'];
    });
  }

  Future<void> _addOrEditCustomer() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String phone = _phoneController.text;
    String vkn = _vknController.text;

    if (name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty && vkn.isNotEmpty && _selectedCustomerType != null) {
      if (widget.customerId == null) {
        await _customerService.addCustomer(
          name: name,
          email: email,
          phoneNumber: phone,
          registrationDate: DateTime.now(),
          active: _isActive,
          vkn: vkn,
          customerType: _selectedCustomerType!,
        );
        MotionToast.success(
          description: const Text('Müşteri başarıyla eklendi!'),
          width: 300,
        ).show(context);
      } else {
        await _customerService.updateCustomer(
          customerId: widget.customerId!,
          name: name,
          email: email,
          phoneNumber: phone,
          active: _isActive,
          vkn: vkn,
          customerType: _selectedCustomerType!,
        );
        MotionToast.success(
          description: const Text('Müşteri başarıyla güncellendi!'),
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
    _emailController.dispose();
    _phoneController.dispose();
    _vknController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Müşteri Ekle/Düzenle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Ad'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-posta'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefon Numarası'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _vknController,
                decoration: const InputDecoration(labelText: 'Vergi Kimlik Numarası'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCustomerType,
                decoration: const InputDecoration(labelText: 'Müşteri Tipi'),
                items: _customerTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCustomerType = value;
                  });
                },
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 20),
              RegisterButton(
                onPressed: _addOrEditCustomer, // Ürünler sayfasındaki gibi RegisterButton bileşeni kullanıldı
              ),
            ],
          ),
        ),
      ),
    );
  }
}
