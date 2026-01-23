import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pry_gestion_contactos_riverpod_ddd/presentation/views/pages/detail_page.dart';
import 'presentation/views/pages/contact_page.dart';
import 'presentation/views/pages/detail_page.dart';
import 'presentation/views/widgets/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) =>  const ContactsPage(),
        '/detail': (context) => const DetailPage(),
      },
    );
  }
}
