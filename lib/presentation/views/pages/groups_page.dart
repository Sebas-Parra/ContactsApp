import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/contact_provider.dart';
import '../../../domain/entities/contact.dart';
import '../widgets/app_colors.dart';
import '../widgets/app_text_styles.dart';
import 'dart:io';

class GroupsPage extends ConsumerStatefulWidget {
  const GroupsPage({super.key});

  @override
  ConsumerState<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends ConsumerState<GroupsPage> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(contactProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      body: contacts.when(
        data: (list) {
          // Agrupar contactos por la primera letra del nombre
          final grouped = <String, List<Contact>>{};
          for (var contact in list) {
            final firstLetter = contact.name.isNotEmpty
                ? contact.name[0].toUpperCase()
                : '#';
            grouped.putIfAbsent(firstLetter, () => []).add(contact);
          }

          // Ordenar las letras
          final sortedKeys = grouped.keys.toList()..sort();

          return ListView.builder(
            itemCount: sortedKeys.length,
            itemBuilder: (context, index) {
              final letter = sortedKeys[index];
              final contactsInGroup = grouped[letter]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      letter,
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  ...contactsInGroup.map((contact) => ListTile(
                        leading: contact.photo.isNotEmpty
                            ? CircleAvatar(
                                backgroundImage: FileImage(File(contact.photo)),
                              )
                            : const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(contact.name),
                        subtitle: Text(contact.phoneNumber),
                        trailing: contact.isFavorite
                            ? const Icon(Icons.star, color: AppColors.warning)
                            : null,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/detail',
                            arguments: contact,
                          );
                        },
                      )),
                  const Divider(height: 1),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/favorites');
          } else if (index == 2) {
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
