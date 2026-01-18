//Este archivo define los casos de uso relacionados con la gestion de contactos
//es decir, las operaciones que se pueden realizar en la capa de aplicacion
//utilizando el repositorio de contactos
import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';

class ManageContacts {
  //intanciamos
  final ContactRepository repository;

  ManageContacts(this.repository);

  //metodos
  Future<List<Contact>> listContacts() => repository.getContacts(); 
  Future<void> addContact(Contact contact) => repository.addContact(contact);
  Future<void> deleteContact(int id) => repository.deleteContact(id);
  Future<void> updateContact(Contact contact) => repository.updateContact(contact);


}