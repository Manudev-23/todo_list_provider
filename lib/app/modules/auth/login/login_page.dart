import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:todo_list_provider/app/core/widget/todo_list_logo.dart';
import 'package:todo_list_provider/app/modules/auth/login/login_controller.dart';
import 'package:todo_list_provider/app/core/notifier/default_listener_notifier.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  late DefaultListenerNotifier _listenerNotifier;

  @override
  void initState() {
    super.initState();
    final loginController = context.read<LoginController>();
    
    _listenerNotifier = DefaultListenerNotifier(
      changeNotifier: loginController,
      context: context,
      onSuccess: () {
        if (loginController.success) {
          context.go('/home');
        }
      },
      onError: (error) {
        print('❌ Erro: $error');
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      
      if (mounted) {
        FocusScope.of(context).requestFocus(_emailFocusNode);
        print('✅ Foco aplicado no campo de email');
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _listenerNotifier.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog() {
    final loginController = context.read<LoginController>();
    final dialogFocusNode = FocusNode();
    
    showDialog(
      context: context,
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(dialogFocusNode);
        });
        
        return AlertDialog(
          title: const Text('Recuperar Senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Digite seu email para receber o link de recuperação:'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Por favor, insira um email válido';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                dialogFocusNode.dispose();
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_emailController.text.isNotEmpty) {
                  loginController.forgotPassword(_emailController.text);
                  dialogFocusNode.dispose();
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Email de recuperação enviado! Verifique sua caixa de entrada.'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const TodoListLogo(),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Por favor, insira um email válido';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua senha';
                        }
                        if (value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureText,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: const Text('Esqueceu a senha?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ✅ BOTÃO LOGIN NORMAL
                    Consumer<LoginController>(
                      builder: (context, controller, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: controller.loading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      final email = _emailController.text;
                                      final password = _passwordController.text;
                                      await controller.login(email, password);
                                    }
                                  },
                            child: controller.loading
                                ? const CircularProgressIndicator()
                                : const Text('Entrar'),
                          ),  
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // ✅ BOTÃO GOOGLE CORRIGIDO
                   Consumer<LoginController>(
  builder: (context, controller, child) {
    return SizedBox(
      width: double.infinity,
      child: SignInButton(
        Buttons.google,
        text: controller.loading
            ? "Entrando..."
            : "Entrar com Google",
        onPressed: controller.loading
            ? () {} // Função vazia enquanto carrega
            : () {
                controller.googleLogin();
              },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  },
),


                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Não tem conta? ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.go('/register');
                          },
                          child: const Text(
                            'Cadastre-se',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
