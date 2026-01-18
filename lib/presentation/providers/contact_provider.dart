import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/databases/drift_database.dart';
import '../../data/datasource/contact_local_datasource.dart';
import '../../data/repositories/contact_repository_impl.dart';
import '../../application/usescases/manage_contacts.dart';
import '../../domain/entities/contact.dart' as domain;

//definir el provider
final contactProvider = StateNotifierProvider<ContactNotifier, AsyncValue<List<domain.Contact>>>(
    (ref)=>ContactNotifier(),
);

//esta clase maneja el estado de los contactos
//es decir, la lista de contactos
class ContactNotifier extends StateNotifier<AsyncValue<List<domain.Contact>>> {
    //Esto es el constructor
    ContactNotifier() : super(const AsyncLoading()) {
        load();
    } //super.state es el estado inicial

    late ManageContacts usescases;

    //Esto es un metodo para cargar los contactos usando Drift
    Future <void> load() async {
        final db = AppDatabase(); // Inicializar la base de datos con Drift
        usescases = ManageContacts(
            ContactRepositoryImpl(
                ContactLocalDataSource(db),
            ),
        );
        state = AsyncData(await usescases.listContacts());
    }

    Future<void> add(domain.Contact c) async {
        await usescases.addContact(c);
        load();
    }

    Future<void> delete(int id) async {
        await usescases.deleteContact(id);
        load();
    }

    Future<void> update(domain.Contact c) async {
        await usescases.updateContact(c);
        load();
    }

}
//El gestor de estado está aqui jajajajajajaaajajajajajjajajaaa

//Lo que hace este codigo es definir un provider llamado contactProvider
//que maneja el estado de una lista de contactos usando Riverpod.
//El estado inicial es AsyncLoading, lo que indica que los contactos
//estan siendo cargados. Cuando se crea una instancia de ContactNotifier,
//se llama al metodo load() para cargar los contactos desde la base de datos SQLite
//usando la clase SqliteService. Una vez que los contactos se cargan,
//el estado se actualiza para reflejar la lista de contactos obtenida
