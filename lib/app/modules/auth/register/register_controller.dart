import 'package:todo_list_provider/app/core/notifier/default_change_notifier.dart';
import 'package:todo_list_provider/app/exception/auth_exceptions.dart';
import 'package:todo_list_provider/app/services/user_service.dart';

class RegisterController extends DefaultChangeNotifier {
  final UserService _userService;
  
  RegisterController({required UserService userService}) : _userService = userService;

  Future<void> register(String name, String email, String password) async {
    try {
      resetState();
      showLoading();

      print('📝 Registrando usuário...');

      final user = await _userService.register(email, password);

      if (user == null) {
        setError('Erro ao criar usuário');
        return;
      }

      // 🔹 GRAVA O NOME NO FIREBASE AUTH
      await user.updateDisplayName(name);
      await user.reload();

      print('✅ Nome salvo no Firebase Auth: $name');

      // ❗ NÃO FAÇA LOGOUT AQUI
      // O GoRouter deve te mandar para /login se você quiser isso

      setSuccess();

    } on AuthException catch (e) {
      setError(e.message);
    } catch (e) {
      setError('Erro inesperado: $e');
    } finally {
      hideLoading();
    }
  }
}
