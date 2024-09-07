import 'package:flutter/material.dart';
import 'package:seco_app/pages/customers_page.dart';
import 'package:seco_app/pages/login_register_page.dart';
import 'package:seco_app/pages/products_page.dart';
import 'package:seco_app/pages/stock_page.dart';
import 'package:seco_app/pages/transactions_page.dart';
import 'package:seco_app/pages/transaction_edit_page.dart'; // İşlem ekleme/düzenleme sayfası
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
      case '/transactions/edit': // İşlem ekleme/düzenleme rotası
        final args = settings.arguments as Map<String, dynamic>?; // ID ya da diğer parametreler buradan alınabilir
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
