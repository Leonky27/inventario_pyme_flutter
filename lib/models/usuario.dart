class Usuario {
  int id;
  String nombre;
  String apellido;
  String nombreUsuario;
  String documentoIdentidad;
  String numeroCelular;
  String email;
  String contrasena;
  String rol;
  bool estado;
  DateTime? ultimaConexion;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.nombreUsuario,
    required this.documentoIdentidad,
    required this.numeroCelular,
    required this.email,
    required this.contrasena,
    required this.rol,
    this.estado = true,
    this.ultimaConexion,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nombre: json['Nombre'] ?? json['nombre'] ?? '',
      apellido: json['Apellido'] ?? json['apellido'] ?? '',
      nombreUsuario: json['Nombre_Usuario'] ?? json['nombre_usuario'] ?? '',
      documentoIdentidad: json['Documento_identidad'] ?? json['documento_identidad'] ?? '',
      numeroCelular: json['numero_celular'] ?? '',
      email: json['email'] ?? '',
      contrasena: json['Contraseña'] ?? json['contrasena'] ?? '',
      rol: json['rol'] ?? '',
      estado: json['estado'] == true || json['estado'] == 'true',
      ultimaConexion: json['ultima_conexion'] != null 
          ? DateTime.tryParse(json['ultima_conexion'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Nombre': nombre,
      'Apellido': apellido,
      'Nombre_Usuario': nombreUsuario,
      'Documento_identidad': documentoIdentidad,
      'numero_celular': numeroCelular,
      'email': email,
      'Contraseña': contrasena,
      'rol': rol,
      'estado': estado,
      'ultima_conexion': ultimaConexion?.toIso8601String(),
    };
  }
}
