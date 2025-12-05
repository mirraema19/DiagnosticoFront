import 'package:flutter/gestures.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  // CAMBIO: Un solo controlador para el nombre completo
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  bool _termsAccepted = false;
  String _selectedRole = 'VEHICLE_OWNER'; // Valor por defecto según enum del backend

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el enlace: $urlString')),
        );
      }
    }
  }

  void _showPrivacyNoticeDialog(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.bodyMedium;
    final linkStyle = defaultStyle?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aviso de Privacidad'),
          content: SingleChildScrollView(
            child: RichText(
              text: TextSpan(
                style: defaultStyle,
                children: [
                  const TextSpan(
                    text: 'AutoDiag, es el responsable del tratamiento de sus datos personales.\n\n',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const TextSpan(
                    text: 'Los datos que recabamos de usted (identificación, contacto, ubicación y datos del vehículo) serán utilizados para las siguientes finalidades principales:\n\n',
                  ),
                  const TextSpan(
                    text: '• Crear y gestionar su cuenta de usuario en nuestra plataforma.\n',
                  ),
                  const TextSpan(
                    text: '• Proporcionar diagnósticos automotrices preliminares mediante Inteligencia Artificial.\n',
                  ),
                  const TextSpan(
                    text: '• Gestionar citas y servicios con los talleres mecánicos de su elección.\n',
                  ),
                  const TextSpan(
                    text: '• Mantener un historial digital de los servicios y reparaciones de su vehículo.\n\n',
                  ),
                  const TextSpan(
                    text: 'De manera adicional, utilizaremos su información para las siguientes finalidades secundarias:\n\n',
                  ),
                  const TextSpan(
                    text: '• Mejorar nuestros algoritmos de predicción y diagnóstico.\n',
                  ),
                  const TextSpan(
                    text: '• Envío de promociones y encuestas de calidad.\n\n',
                  ),
                  const TextSpan(
                    text: 'Para más información, consulta nuestro Aviso de Privacidad Integral ',
                  ),
                  TextSpan(
                    text: 'aquí',
                    style: linkStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _launchURL('https://avisotheprivacidad.netlify.app/');
                      },
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los términos para continuar.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepository = sl<AuthRepository>();
      // CAMBIO: Enviamos fullName
      await authRepository.register(
        fullName: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text,
        role: _selectedRole,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro exitoso. Iniciando sesión...')),
        );
        // Como guardamos el token en el repositorio, podemos ir al home o admin
        if (_selectedRole == 'WORKSHOP_ADMIN') {
           context.go('/admin');
        } else {
           context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception:', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Estilos...
    final defaultStyle = Theme.of(context).textTheme.bodyMedium;
    final linkStyle = defaultStyle?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Completa tus datos', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              
              // CAMBIO: Campo único de Nombre Completo
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Nombre Completo', prefixIcon: Icon(Icons.person)),
                validator: (v) => v == null || v.length < 3 ? 'Mínimo 3 caracteres' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || !v.contains('@') ? 'Email inválido' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock)),
                obscureText: true,
                validator: (v) => v == null || v.length < 8 ? 'Mínimo 8 caracteres' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono (+52...)', prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
                // Validación básica de formato según backend
                validator: (v) => v == null || v.length < 10 ? 'Teléfono requerido' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(labelText: 'Tipo de Cuenta', prefixIcon: Icon(Icons.account_box)),
                items: const [
                  DropdownMenuItem(value: 'VEHICLE_OWNER', child: Text('Dueño de Vehículo')),
                  DropdownMenuItem(value: 'WORKSHOP_ADMIN', child: Text('Dueño de Taller')),
                ],
                onChanged: (v) => setState(() => _selectedRole = v!),
              ),

              const SizedBox(height: 24),

              CheckboxListTile(
                value: _termsAccepted,
                onChanged: (v) => setState(() => _termsAccepted = v ?? false),
                title: RichText(
                  text: TextSpan(
                    style: defaultStyle,
                    children: [
                      const TextSpan(text: 'Acepto los '),
                      TextSpan(text: 'Términos', style: linkStyle, recognizer: TapGestureRecognizer()..onTap = () {}),
                      const TextSpan(text: ' y el '),
                      TextSpan(text: 'Aviso de Privacidad', style: linkStyle, recognizer: TapGestureRecognizer()..onTap = () => _showPrivacyNoticeDialog(context)),
                    ],
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 24),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitRegistration,
                      child: const Text('REGISTRARSE'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}