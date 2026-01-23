class Contact {
  final int? id; //el ? es para que pueda ser nulo
  final String name;
  final String description;
  final String photo;
  final String email;
  final String phoneNumber;

  Contact({
    this.id, //No se usa required porque puede ser nulo y no es obligatorio al crear el objeto
    required this.name,
    required this.description,
    required this.photo,
    required this.email,
    required this.phoneNumber,
  });

  
}