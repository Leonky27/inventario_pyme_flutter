import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController nombreUsuarioController = TextEditingController();
  final TextEditingController documentoController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService authService = AuthService();
  bool isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      final nuevoUsuario = Usuario(
        id: 0, // El ID se generará en la base de datos
        nombre: nombreController.text.trim(),
        apellido: apellidoController.text.trim(),
        nombreUsuario: nombreUsuarioController.text.trim(),
        documentoIdentidad: documentoController.text.trim(),
        numeroCelular: celularController.text.trim(),
        email: emailController.text.trim(),
        contrasena: passwordController.text.trim(),
        rol: 'usuario', // Rol por defecto
        estado: true,
      );

      final success = await authService.register(nuevoUsuario);

      setState(() => isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registro exitoso. Por favor, inicia sesión.'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Regresa al login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar usuario'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro de Usuario')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text('Crear Cuenta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 24),
                      TextFormField(
                        controller: nombreController,
                        decoration: InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                        validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: apellidoController,
                        decoration: InputDecoration(labelText: 'Apellido', border: OutlineInputBorder()),
                        validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: nombreUsuarioController,
                        decoration: InputDecoration(labelText: 'Nombre de Usuario', border: OutlineInputBorder()),
                        validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: documentoController,
                        decoration: InputDecoration(labelText: 'Documento de Identidad', border: OutlineInputBorder()),
                        validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: celularController,
                        decoration: InputDecoration(labelText: 'Número de Celular', border: OutlineInputBorder()),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.isEmpty || !v.contains('@') ? 'Email inválido' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                        obscureText: true,
                        validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                      ),
                      SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Registrarse', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
