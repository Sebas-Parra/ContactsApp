import 'package:flutter/material.dart';
import 'package:pry_gestion_contactos_riverpod_ddd/domain/entities/contact.dart';
import 'package:pry_gestion_contactos_riverpod_ddd/presentation/providers/contact_provider.dart';
import 'dart:io'; //esto para manejar archivos de imagen
import 'package:pry_gestion_contactos_riverpod_ddd/presentation/views/widgets/buttons.dart';
import 'package:pry_gestion_contactos_riverpod_ddd/presentation/views/widgets/text_field_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailPage extends ConsumerWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contact = ModalRoute.of(context)!.settings.arguments as Contact;
    final subjectCtrl = TextEditingController();

    File? _image;

    Future<void> _pickImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
      if (photo != null) {
        _image = File(photo.path);
      }
    }

    Future<void> _llamar(String phoneNumber) async {
      final uri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se puede realizar la llamada')),
          );
        }
      }
    }

    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map(
            (MapEntry<String, String> e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');
    }

    Future<void> _sendEmail(String email, String subject) async {
      final uri = Uri(
        scheme: 'mailto',
        path: email,
        query: encodeQueryParameters(<String, String>{'subject': subject}),
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se puede enviar el email')),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Details")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () {
          //Mostrar diálogo de edición
          final editNameCtrl = TextEditingController(text: contact.name);
          final editDescCtrl = TextEditingController(text: contact.description);
          final editEmailCtrl = TextEditingController(text: contact.email);
          final editPhoneCtrl = TextEditingController(
            text: contact.phoneNumber,
          );

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Contact Edit'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputsText(
                      controller: editNameCtrl,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 19),
                    InputsText(
                      controller: editDescCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 19),
                    InputsText(
                      controller: editEmailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 19),
                    InputsText(
                      controller: editPhoneCtrl,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    const SizedBox(height: 19),
                    Buttons(onPressed: _pickImage, label: 'Edit image'),
                    const SizedBox(height: 19),
                    Buttons(
                      onPressed: () => Navigator.pop(context),
                      label: 'Cancel',
                    ),
                    const SizedBox(height: 19),
                    Buttons(
                      onPressed: () async {
                        if (editNameCtrl.text.isEmpty ||
                            editDescCtrl.text.isEmpty ||
                            editEmailCtrl.text.isEmpty ||
                            editPhoneCtrl.text.isEmpty)
                          return;

                        await ref
                            .read(contactProvider.notifier)
                            .update(
                              Contact(
                                id: contact.id,
                                name: editNameCtrl.text,
                                description: editDescCtrl.text,
                                photo: _image?.path ?? contact.photo,
                                email: editEmailCtrl.text,
                                phoneNumber: editPhoneCtrl.text,
                              ),
                            );

                        if (context.mounted) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      },
                      label: 'Save',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      body: Center(
        child: Column(
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: contact.photo.isNotEmpty
                  ? FileImage(File(contact.photo))
                  : null,
            ),
            Text(contact.name),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => _llamar(contact.phoneNumber),
                  child: Icon(Icons.phone),
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Send Email to ${contact.email}'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InputsText(
                              controller: subjectCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Subject',
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          Row(
                            children: [
                              Buttons(
                                onPressed: () => Navigator.pop(context),
                                label: 'Cancel',
                              ),
                              SizedBox(width: 20),
                              Buttons(
                                onPressed: () =>
                                    _sendEmail(contact.email, subjectCtrl.text),
                                label: 'Send Email',
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  child: Icon(Icons.email),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              margin: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contact Info'),
                  Row(children: [Icon(Icons.email), Text(contact.email)]),
                  Row(children: [Icon(Icons.phone), Text(contact.phoneNumber)]),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${contact.name}\'s Description'),
                  Text(contact.description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
