import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pry_gestion_contactos_riverpod_ddd/presentation/views/widgets/search_bar_widget.dart';
import '../../providers/contact_provider.dart';
import '../../../domain/entities/contact.dart';
import '../widgets/text_field_widget.dart';
import '../widgets/buttons.dart';
import 'dart:io'; //esto para manejar archivos de imagen
import 'package:image_picker/image_picker.dart'; //para seleccionar imágenes

class ContactsPage extends ConsumerWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactProvider);

    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController descriptionCtrl = TextEditingController();
    final TextEditingController emailCtrl = TextEditingController();
    final TextEditingController phoneCtrl = TextEditingController();

    File? _image;

    Future<void> _pickImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
      if (photo != null) {
        _image = File(photo.path);
      }
    }


    void _goDetails(Contact contact) {
        Navigator.pushNamed(context, '/detail', arguments: contact);
    }

    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map(
            (MapEntry<String, String> e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('New Contact'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputsText(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 19),
                    InputsText(
                      controller: descriptionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 19),
                    InputsText(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 19),
                    InputsText(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.numberWithOptions(),
                    ),
                    const SizedBox(height: 19),
                    Buttons(onPressed: _pickImage, label: 'Seleccionar imagen'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty || descriptionCtrl.text.isEmpty)
                      return;

                    await ref
                        .read(contactProvider.notifier)
                        .add(
                          Contact(
                            name: nameCtrl.text,
                            description: descriptionCtrl.text,
                            photo: _image?.path ?? '',
                            email: emailCtrl.text,
                            phoneNumber: phoneCtrl.text,
                          ),
                        );

                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          );
        },
      ),
      body: Column(
        children: [
          const SearchBarWidget(),
          Expanded(
            child: contacts.when(
              data: (list) => ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) => ListTile(
                  leading: list[i].photo.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: FileImage(File(list[i].photo)),
                        )
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(list[i].name),
                  subtitle: Text(list[i].description),
                  onTap: () => _goDetails(list[i]), 
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(e.toString()),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'),
        ],
      ),
    );
  }
}
