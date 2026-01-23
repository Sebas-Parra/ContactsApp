import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pry_gestion_contactos_riverpod_ddd/presentation/views/widgets/search_bar_widget.dart';
import '../providers/contact_provider.dart';
import '../../domain/entities/contact.dart';
import 'widgets/text_field_widget.dart';
import 'widgets/buttons.dart';
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
    final TextEditingController subjectCtrl = TextEditingController();
    final TextEditingController photoCtrl = TextEditingController();

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

    void _goDetails(List<Contact> contact) {
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

    Future<void> _enviarEmail(String email, String subject) async {
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
                  onTap: () => _goDetails(list[i] as List<Contact>), 
                  //() {
                  //   showDialog(
                  //     context: context,
                  //     builder: (_) => AlertDialog(
                  //       title: const Text('Opciones'),
                  //       content: const Text(
                  //         '¿Qué deseas hacer con este contacto?',
                  //       ),
                  //       actions: [
                  //         TextButton(
                  //           onPressed: () => Navigator.pop(context),
                  //           child: const Text('Cancelar'),
                  //         ),
                  //         Buttons(
                  //           onPressed: () => _goDetails(list[i].id),
                            
                  //           //() {
                  //             // Navigator.pop(context);
                  //             // // Mostrar diálogo de edición
                  //             // final editNameCtrl = TextEditingController(
                  //             //   text: list[i].name,
                  //             // );
                  //             // final editDescCtrl = TextEditingController(
                  //             //   text: list[i].description,
                  //             // );
                  //             // final editEmailCtrl = TextEditingController(
                  //             //   text: list[i].email,
                  //             // );
                  //             // final editPhoneCtrl = TextEditingController(
                  //             //   text: list[i].phoneNumber,
                  //             // );

                  //             // showDialog(
                  //             //   context: context,
                  //             //   builder: (_) => AlertDialog(
                  //             //     title: const Text('Editar Contacto'),
                  //             //     content: SingleChildScrollView(
                  //             //       child: Column(
                  //             //         mainAxisSize: MainAxisSize.min,
                  //             //         children: [
                  //             //           InputsText(
                  //             //             controller: editNameCtrl,
                  //             //             decoration: const InputDecoration(
                  //             //               labelText: 'Name',
                  //             //             ),
                  //             //           ),
                  //             //           const SizedBox(height: 19),
                  //             //           InputsText(
                  //             //             controller: editDescCtrl,
                  //             //             decoration: const InputDecoration(
                  //             //               labelText: 'Description',
                  //             //             ),
                  //             //           ),
                  //             //           const SizedBox(height: 19),
                  //             //           InputsText(
                  //             //             controller: editEmailCtrl,
                  //             //             decoration: const InputDecoration(
                  //             //               labelText: 'Email',
                  //             //             ),
                  //             //           ),
                  //             //           const SizedBox(height: 19),
                  //             //           InputsText(
                  //             //             controller: editPhoneCtrl,
                  //             //             decoration: const InputDecoration(
                  //             //               labelText: 'Phone',
                  //             //             ),
                  //             //             keyboardType:
                  //             //                 TextInputType.numberWithOptions(),
                  //             //           ),
                  //             //           const SizedBox(height: 19),
                  //             //           Buttons(
                  //             //             onPressed: _pickImage,
                  //             //             label: 'Editar imagen',
                  //             //           ),
                  //             //         ],
                  //             //       ),
                  //             //     ),
                  //             //     actions: [
                  //             //       TextButton(
                  //             //         onPressed: () => Navigator.pop(context),
                  //             //         child: const Text('Cancelar'),
                  //             //       ),
                  //             //       ElevatedButton(
                  //             //         onPressed: () async {
                  //             //           if (editNameCtrl.text.isEmpty ||
                  //             //               editDescCtrl.text.isEmpty)
                  //             //             return;

                  //             //           await ref
                  //             //               .read(contactProvider.notifier)
                  //             //               .update(
                  //             //                 Contact(
                  //             //                   id: list[i].id,
                  //             //                   name: editNameCtrl.text,
                  //             //                   description: editDescCtrl.text,
                  //             //                   photo:
                  //             //                       _image?.path ??
                  //             //                       list[i].photo,
                  //             //                   email: editEmailCtrl.text,
                  //             //                   phoneNumber: editPhoneCtrl.text,
                  //             //                 ),
                  //             //               );

                  //             //           Navigator.pop(context);
                  //             //         },
                  //             //         child: const Text('Guardar'),
                  //             //       ),
                  //             //     ],
                  //             //   ),
                  //             // );
                  //           // },
                  //           // child: const Text('Editar'),
                  //         ),
                  //         TextButton(
                  //           onPressed: () {
                  //             Navigator.pop(context);
                  //             final emailNameCtrl = TextEditingController(
                  //               text: list[i].name,
                  //             );
                  //             final emailEmailCtrl = TextEditingController(
                  //               text: list[i].email,
                  //             );

                  //             showDialog(
                  //               context: context,
                  //               builder: (_) => AlertDialog(
                  //                 title: const Text('Enviar email'),
                  //                 content: Column(
                  //                   mainAxisSize: MainAxisSize.min,
                  //                   children: [
                  //                     Text(
                  //                       'Nombre del destinatario: ${list[i].email}',
                  //                     ),
                  //                     Text('Enviar email a ${list[i].email}'),
                  //                     InputsText(
                  //                       controller: subjectCtrl,
                  //                       decoration: InputDecoration(
                  //                         labelText: 'Subject',
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //                 actions: [
                  //                   TextButton(
                  //                     onPressed: () => Navigator.pop(context),
                  //                     child: const Text('Cancelar'),
                  //                   ),
                  //                   Buttons(
                  //                     onPressed: () async {
                  //                       _enviarEmail(
                  //                         emailEmailCtrl.text,
                  //                         subjectCtrl.text,
                  //                       );
                  //                     },
                  //                     label: 'Enviar',
                  //                   ),
                  //                 ],
                  //               ),
                  //             );
                  //           },

                  //           child: const Text('Enviar Email'),
                  //         ),
                  //         TextButton(
                  //           onPressed: () async {
                  //             Navigator.pop(context);
                  //             // Confirmar eliminación
                  //             final confirm = await showDialog<bool>(
                  //               context: context,
                  //               builder: (_) => AlertDialog(
                  //                 title: const Text('Confirmar'),
                  //                 content: Text(
                  //                   '¿Estás seguro de eliminar a ${list[i].name}?',
                  //                 ),
                  //                 actions: [
                  //                   TextButton(
                  //                     onPressed: () =>
                  //                         Navigator.pop(context, false),
                  //                     child: const Text('No'),
                  //                   ),
                  //                   ElevatedButton(
                  //                     onPressed: () =>
                  //                         Navigator.pop(context, true),
                  //                     style: ElevatedButton.styleFrom(
                  //                       backgroundColor: Colors.red,
                  //                     ),
                  //                     child: const Text('Sí, eliminar'),
                  //                   ),
                  //                 ],
                  //               ),
                  //             );

                  //             if (confirm == true && list[i].id != null) {
                  //               await ref
                  //                   .read(contactProvider.notifier)
                  //                   .delete(list[i].id!);
                  //             }
                  //           },
                  //           style: TextButton.styleFrom(
                  //             foregroundColor: Colors.red,
                  //           ),
                  //           child: const Text('Eliminar'),
                  //         ),
                  //         Buttons(
                  //           onPressed: () => _llamar(list[i].phoneNumber),
                  //           label: 'Llamar',
                  //         ),
                  //       ],
                  //     ),
                  //   );
                  // },
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
