import 'package:flutter/material.dart';
import 'package:pry_gestion_contactos_riverpod_ddd/domain/entities/contact.dart';


class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final contact = ModalRoute.of(context)!.settings.arguments as Contact;
    return Scaffold(
      appBar: AppBar(title: const Text("Detalles")),
      body: Center(
        child: Column(
          children: [
            Text(contact.photo),
            Text(contact.name),
            Text(contact.description),
            Text(contact.email),
            Text(contact.phoneNumber),
          ],
        ),
      ),
    );
  }
}