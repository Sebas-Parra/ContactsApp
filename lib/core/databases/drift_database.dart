import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// Parte generada por build_runner - se creará automáticamente
part 'drift_database.g.dart';

// Definición de la tabla usando clases de Dart
class Contacts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get photo => text()();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get phoneNumber => text().withDefault(const Constant(''))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
}

// Esta anotación define qué tablas incluir en la base de datos
@DriftDatabase(tables: [Contacts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        // Agregar columna isFavorite si no existe
        await migrator.addColumn(contacts, contacts.isFavorite);
      }
    },
  );

  // Conexión a la base de datos usando drift_flutter
  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'contacts');
  }

  // --- OPERACIONES CRUD ---

  // Obtener todos los contactos
  Future<List<Contact>> getAllContacts() => select(contacts).get();

  // Obtener un contacto por ID
  Future<Contact?> getContactById(int id) =>
      (select(contacts)..where((t) => t.id.equals(id))).getSingleOrNull();

  // Insertar un contacto
  Future<int> insertContact(ContactsCompanion contact) =>
      into(contacts).insert(contact);

  // Actualizar un contacto
  Future<bool> updateContact(Contact contact) =>
      update(contacts).replace(contact);

  // Eliminar un contacto
  Future<int> deleteContact(int id) =>
      (delete(contacts)..where((t) => t.id.equals(id))).go();

  // Stream de todos los contactos (actualización en tiempo real)
  Stream<List<Contact>> watchAllContacts() => select(contacts).watch();
}
