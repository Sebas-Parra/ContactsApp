//Este archivo define la interfaz para el repositorio de contactos
//es decir, las operaciones que se pueden realizar con los contactos

import '../entities/contact.dart';
abstract class ContactRepository {
  Future<List<Contact>> getContacts(); //EL Future es porque es una operacion asincrona, es decir, que puede tardar un tiempo en completarse
  Future<void> addContact(Contact contact);
  Future<void> deleteContact(int id);
  Future<void> updateContact(Contact contact);
  
}