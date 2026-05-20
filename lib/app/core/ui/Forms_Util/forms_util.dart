import 'package:flutter/material.dart';

/// Função genérica para lidar com formulários.
/// [submitFunction] é a função que envia os dados e retorna true/false.
/// [onSuccess] é chamada quando o envio é bem-sucedido.
/// [onError] é chamada quando há erro e recebe a mensagem.
Future<void> handleFormSubmit({
  required BuildContext context,
  required Future<Map<String, dynamic>> Function() submitFunction,
  String successMessage = 'Operação realizada com sucesso!',
  VoidCallback? onSuccess,
}) async {
  // Mostra loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
    final result = await submitFunction();

    // Fecha o loading
    Navigator.of(context).pop();

    if (result['success'] == true) {
      // Mostra mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
        ),
      );

      // Chama callback de sucesso se houver
      if (onSuccess != null) onSuccess();
    } else {
      // Mostra erro se houver
      final errorMessage = result['error'] ?? 'Ocorreu um erro inesperado';
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erro'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    Navigator.of(context).pop(); // Fecha o loading
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text('Erro inesperado: $e'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
