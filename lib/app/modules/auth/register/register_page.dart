import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_provider/app/core/widget/todo_list_logo.dart';
import 'package:todo_list_provider/app/core/notifier/default_listener_notifier.dart';
import 'package:todo_list_provider/app/modules/auth/register/register_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late DefaultListenerNotifier _listenerNotifier;

  @override
  void initState() {
    super.initState();
    final registerController = context.read<RegisterController>();
    
    // ✅ LISTENER COM CALLBACKS + GOROUTER
    _listenerNotifier = DefaultListenerNotifier(
      changeNotifier: registerController,
      context: context,
      onSuccess: () {
        // ✅ NAVEGAÇÃO COM GOROUTER APÓS SUCESSO
        print('✅ Registro bem-sucedido - navegando para login');
        context.go('/login'); // ← GoRouter navigation
      },
      onError: (error) {
        // ✅ TRATAMENTO ESPECÍFICO DE ERRO DO REGISTER
        print('❌ Erro no registro: $error');
        // Pode adicionar lógica específica aqui se precisar
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _listenerNotifier.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final registerController = context.read<RegisterController>();

    if (!_formKey.currentState!.validate()) return;

    await registerController.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Cadastro'),
            SizedBox(height: 4),
            Text('Preencha os campos para criar um novo usuário'),
          ],
        ),
        leading: IconButton(
          onPressed: () => context.go('/login'), // ← GoRouter
          icon: ClipOval(
            child: Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.all(8.0),
              child: const Icon(Icons.arrow_back),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                height: 120,
                child: const FittedBox(
                  child: TodoListLogo(),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Todo List'),
              const SizedBox(height: 40),
              
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Campos do formulário (mantenha como estava)
                      _buildTextField(
                        controller: _nameController,
                        label: 'Nome',
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, digite seu nome';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildPasswordField(
                        controller: _passwordController,
                        label: 'Senha',
                        isPassword: _obscurePassword,
                        onToggle: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        label: 'Confirmar Senha',
                        isPassword: _obscureConfirmPassword,
                        onToggle: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        validator: _validateConfirmPassword,
                      ),
                      const SizedBox(height: 32),
                      
                      Consumer<RegisterController>(
                        builder: (context, controller, child) {
                          return Container(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: controller.loading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: controller.loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Cadastrar'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mantenha os métodos _buildTextField, _buildPasswordField e validadores...
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(prefixIcon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isPassword,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            isPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Por favor, digite seu email';
    if (!value.contains('@')) return 'Por favor, digite um email válido';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Por favor, digite sua senha';
    if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Por favor, confirme sua senha';
    if (value != _passwordController.text) return 'As senhas não coincidem';
    return null;
  }
}