import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes/app_router.dart'; // Route yapısının bulunduğu dosya
import 'firebase_options.dart'; // Firebase yapılandırma dosyası
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  
  // Firebase başlatma işlemi
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // onGenerateRoute ile merkezi route yönetimi
      onGenerateRoute: AppRouter.generateRoute, // AppRouter yapısını kullanıyoruz
      initialRoute: '/', // Başlangıç rotası login sayfası olacak
    );
  }
}
