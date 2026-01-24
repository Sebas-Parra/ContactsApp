import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pry_gestion_contactos_riverpod_ddd/presentation/views/widgets/search_bar_widget.dart';
import '../../providers/contact_provider.dart';
import '../../../domain/entities/contact.dart';
import '../widgets/text_field_widget.dart';
import '../widgets/buttons.dart';
import '../widgets/app_colors.dart';
import 'dart:io'; //esto para manejar archivos de imagen
import 'package:image_picker/image_picker.dart'; //para seleccionar imágenes

class ContactsPage extends ConsumerStatefulWidget {
  const ContactsPage({super.key});

  @override
  ConsumerState<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends ConsumerState<ContactsPage> {
  int _selectedIndex = 0;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
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



    void _goDetails(Contact contact) {
        Navigator.pushNamed(context, '/detail', arguments: contact);
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

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Contact Saved!!'),
                          duration: Duration(seconds: 2),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
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
          SearchBarWidget(
            onSearch: (query) {
              setState(() {
                _searchQuery = query.toLowerCase();
              });
            },
          ),
          Expanded(
            child: contacts.when(
              data: (list) {
                final filteredList = list.where((contact) {
                  return contact.name.toLowerCase().contains(_searchQuery) ||
                         contact.email.toLowerCase().contains(_searchQuery) ||
                         contact.phoneNumber.contains(_searchQuery);
                }).toList();
                
                return ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (_, i) => ListTile(
                    leading: filteredList[i].photo.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: FileImage(File(filteredList[i].photo)),
                          )
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(filteredList[i].name),
                    subtitle: Text(filteredList[i].description),
                    onTap: () => _goDetails(filteredList[i]),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(e.toString()),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/favorites');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/groups');
          } else if (index == 0) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groups',
          ),
        ],
      ),
    );
  }
}
