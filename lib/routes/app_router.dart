import 'package:flutter/material.dart';
import 'package:seco_app/pages/customers_page.dart';
import 'package:seco_app/pages/login_register_page.dart';
import 'package:seco_app/pages/payments_page.dart';
import 'package:seco_app/pages/products_page.dart';
import 'package:seco_app/pages/product_edit_page.dart'; // Ürün ekleme/düzenleme sayfası
import 'package:seco_app/pages/stock_page.dart';
import 'package:seco_app/pages/transactions_page.dart';
import 'package:seco_app/pages/transaction_edit_page.dart'; // İşlem ekleme/düzenleme sayfası
import 'package:seco_app/pages/announcements_page.dart'; // Duyurular sayfası
import '../pages/home_page.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginRegisterPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/products':
        return MaterialPageRoute(builder: (_) => const ProductsPage());
      case '/stock':
        return MaterialPageRoute(builder: (_) => const StockPage());
      case '/customers':
        return MaterialPageRoute(builder: (_) => const CustomersPage());
      case '/transactions':
        return MaterialPageRoute(builder: (_) => const TransactionsPage());
      case '/payments':
        return MaterialPageRoute(builder: (_) => const PaymentPage());

      // Duyurular sayfası rotası
      case '/announcements':
        return MaterialPageRoute(builder: (_) => const AnnouncementsPage());
      
      // Ürün ekleme/düzenleme rotası
      case '/products/edit': 
        final args = settings.arguments as Map<String, dynamic>?; 
        return MaterialPageRoute(
          builder: (_) => ProductEditPage(
            productId: args != null ? args['productId'] : null,
          ),
        );

      case '/transactions/edit': // İşlem ekleme/düzenleme rotası
        final args = settings.arguments as Map<String, dynamic>?; 
        return MaterialPageRoute(
          builder: (_) => TransactionEditPage(
            transactionId: args != null ? args['transactionId'] : null,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
