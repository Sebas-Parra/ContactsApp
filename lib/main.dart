import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pry_gestion_contactos_riverpod_ddd/presentation/views/detail_page.dart';
import 'presentation/views/contact_page.dart';
import 'presentation/views/detail_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) =>  const ContactsPage(),
        '/detail': (context) => const DetailPage(),
      },
    );
  }
}
