import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pry_gestion_contactos_riverpod_ddd/presentation/views/widgets/search_bar_widget.dart';
import '../../providers/contact_provider.dart';
import 'dart:io'; //esto para manejar archivos de imagen

class FavoriteContactPage extends ConsumerStatefulWidget {
  const FavoriteContactPage({super.key});

  @override
  ConsumerState<FavoriteContactPage> createState() => _FavoriteContactPageState();
}

class _FavoriteContactPageState extends ConsumerState<FavoriteContactPage> {
  int _selectedIndex = 1;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(contactProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Contacts'),),
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
                final favoriteContacts = list.where((c) => c.isFavorite).toList();
                final filteredList = favoriteContacts.where((contact) {
                  return contact.name.toLowerCase().contains(_searchQuery) ||
                         contact.email.toLowerCase().contains(_searchQuery) ||
                         contact.phoneNumber.contains(_searchQuery);
                }).toList();
                
                return ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final contact = filteredList[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: contact.photo.isNotEmpty
                            ? FileImage(File(contact.photo)) as ImageProvider
                            : const AssetImage('assets/images/default_avatar.png'),
                      ),
                      title: Text(contact.name),
                      subtitle: Text(contact.phoneNumber),
                      onTap: () {
                        Navigator.pushNamed(context, '/detail', arguments: contact);
                      },
                    );
                  },
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
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/groups');
          } else if (index == 1) {
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