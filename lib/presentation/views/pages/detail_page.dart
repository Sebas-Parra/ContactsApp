import 'package:flutter/material.dart';
import 'package:pry_gestion_contactos_riverpod_ddd/domain/entities/contact.dart';
import 'package:pry_gestion_contactos_riverpod_ddd/presentation/providers/contact_provider.dart';
import 'dart:io'; //esto para manejar archivos de imagen
import 'package:pry_gestion_contactos_riverpod_ddd/presentation/views/widgets/buttons.dart';
import 'package:pry_gestion_contactos_riverpod_ddd/presentation/views/widgets/text_field_widget.dart';
import 'package:pry_gestion_contactos_riverpod_ddd/presentation/views/widgets/app_text_styles.dart';
import 'package:pry_gestion_contactos_riverpod_ddd/presentation/views/widgets/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailPage extends ConsumerWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contact = ModalRoute.of(context)!.settings.arguments as Contact;
    final subjectCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    File? _image;

    Future<void> _pickImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
      if (photo != null) {
        _image = File(photo.path);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image Selected!!'),
              duration: Duration(seconds: 1),
            ),
          );
        }
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

    Future<void> _addFavorite(Contact contact) async {
      final updatedContact = Contact(
        id: contact.id,
        name: contact.name,
        description: contact.description,
        photo: contact.photo,
        email: contact.email,
        phoneNumber: contact.phoneNumber,
        isFavorite: !contact.isFavorite, // Alternar el estado de favorito
      );

      await ref.read(contactProvider.notifier).update(updatedContact);
    }

    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map(
            (MapEntry<String, String> e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');
    }

    Future<void> _sendEmail(String email, String subject, String body) async {
      final uri = Uri(
        scheme: 'mailto',
        path: email,
        query: encodeQueryParameters(<String, String>{'subject': subject,
        //Agregar body si se desea
        'body': body,
        }),
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
      appBar: AppBar(
        title: const Text("Details"),
        actions: [
          IconButton(
            icon: Icon(
              contact.isFavorite ? Icons.star : Icons.star_border,
              color: contact.isFavorite ? AppColors.warning : null,
            ),
            onPressed: () async {
              await _addFavorite(contact);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      contact.isFavorite
                          ? 'Removed from Favorites!!'
                          : 'Added to Favorites!!',
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: contact.isFavorite ? AppColors.textSecondary : AppColors.warning,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete Contact'),
                  content: Text(
                    'Are you sure you want to delete ${contact.name}?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(contactProvider.notifier)
                            .delete(contact.id!);
                        if (context.mounted) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Contact Deleted!!'),
                              duration: Duration(seconds: 2),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Contact Updated!!'),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: AppColors.info,
                                ),
                              );
                            }
                          },
                          label: 'Save',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: contact.photo.isNotEmpty
                    ? FileImage(File(contact.photo))
                    : null,
                child: contact.photo.isEmpty
                    ? Icon(Icons.person, size: 60, color: AppColors.primary)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(contact.name, style: AppTextStyles.h3),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _llamar(contact.phoneNumber),
                  icon: const Icon(Icons.phone, size: 20),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Row(
                          children: [
                            Icon(Icons.email, color: AppColors.accent),
                            const SizedBox(width: 8),
                            const Text('Send Email'),
                          ],
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'To: ${contact.email}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              InputsText(
                                controller: subjectCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Subject',
                                ),
                              ),
                              const SizedBox(height: 16),
                              InputsText(
                                controller: bodyCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Message',
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 5,
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Buttons(
                                onPressed: () => Navigator.pop(context),
                                label: 'Cancel',
                                isOutlined: true,
                                isSmall: true,
                              ),
                              const SizedBox(width: 12),
                              Buttons(
                                onPressed: () {
                                  _sendEmail(
                                    contact.email,
                                    subjectCtrl.text,
                                    bodyCtrl.text,
                                  );
                                  Navigator.pop(context);
                                },
                                label: 'Send',
                                isSmall: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.email, size: 20),
                  label: const Text('Email'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: 340,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contact Info', style: AppTextStyles.h5),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.email, color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              contact.email,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.phone, color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            contact.phoneNumber,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: 340,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description', style: AppTextStyles.h5),
                      const SizedBox(height: 12),
                      Text(
                        contact.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
