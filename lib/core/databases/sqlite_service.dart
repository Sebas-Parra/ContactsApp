// Este archivo ya no se usa - migrado a Drift
// La aplicación ahora usa Drift en lugar de sqflite directo
// Consulta drift_database.dart para la nueva implementación

// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// //Crear, abrir y configurar la base de datos sqlite
// class SqliteService {
//   static Future<Database> init() async { //static es para que no sea necesario instanciar la clase para usar el metodo
//     final path = join(await getDatabasesPath(), 'contacts.db'); //Esto es para obtener la ruta donde se guardara la base de datos

//     return openDatabase(
//       path,
//       version: 1,

//       onCreate: (db,_) async{ //Se usa comillas simples triples para escribir sentencias SQL multilinea
//       //el await es porque es una operacion asincrona y puede tardar un tiempo en completarse, es decir, 
//       //que no se bloquea la ejecucion del programa mientras se completa la operacion
//         await db.execute('''
//           CREATE TABLE contacts(
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             name TEXT,
//             description TEXT,
//             photo TEXT
//           )
//         ''');//Si no quisiera escribir en texto plano la sentencia SQL, podria usar algun paquete como moor o drift
//       }
//       );

//   }
// }
