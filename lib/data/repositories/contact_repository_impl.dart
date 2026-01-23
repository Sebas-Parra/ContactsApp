import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasource/contact_local_datasource.dart';
//Esto es para implementar la interfaz del repositorio de contactos, es decir, para definir las operaciones que se pueden realizar con los contactos
//se pone @override para indicar que se esta implementando un metodo de la interfaz
//del archivo contact_repository.dart
class ContactRepositoryImpl implements ContactRepository {
  final ContactLocalDataSource local;
  ContactRepositoryImpl(this.local);
  //el riverpod es el manejador de estados que se usa en este proyecto para manejar el estado de la aplicacion, es decir
  // para manejar los datos que se muestran en la interfaz de usuario 
  @override
  Future<List<Contact>> getContacts() =>
    local.getContacts();

  @override
  Future<void> addContact(Contact contact) =>
    local.insertContact(contact);

  @override
  Future<void> deleteContact(int id) =>
    local.deleteContact(id);
  
  @override
  Future<void> updateContact(Contact contact) =>
    local.updateContact(contact);
}