//En la capa de data ahora usamos Drift en lugar de sqflite
import 'package:drift/drift.dart' as drift;
import '../../core/databases/drift_database.dart';
import '../../domain/entities/contact.dart' as domain;

class ContactLocalDataSource {
  final AppDatabase db;

  ContactLocalDataSource(this.db);

  //metodos para acceder a la base de datos usando Drift
  Future<List<domain.Contact>> getContacts() async {
    final result = await db.getAllContacts();

    // Convertir de Contact (Drift) a domain.Contact (entidad de dominio)
    return result.map((e) => domain.Contact(
      id: e.id,
      name: e.name,
      description: e.description,
      photo: e.photo,
      email: e.email, // Agregar campos adicionales si es necesario
      phoneNumber: e.phoneNumber,
      isFavorite: e.isFavorite,
    )).toList();
  }

  Future<void> insertContact(domain.Contact contact) async {
    await db.insertContact(
      ContactsCompanion(
        name: drift.Value(contact.name),
        description: drift.Value(contact.description),
        photo: drift.Value(contact.photo),
        email: drift.Value(contact.email),
        phoneNumber: drift.Value(contact.phoneNumber),
        isFavorite: drift.Value(contact.isFavorite),
      ),
    );
  }

  Future<void> deleteContact(int id) async {
    await db.deleteContact(id);
  }

  Future<void> updateContact(domain.Contact contact) async {
    await db.updateContact(
      Contact(
        id: contact.id!,
        name: contact.name,
        description: contact.description,
        photo: contact.photo,
        email: contact.email,
        phoneNumber: contact.phoneNumber,
        isFavorite: contact.isFavorite,
      ),
    );
  }

}