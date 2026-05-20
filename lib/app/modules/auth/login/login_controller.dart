
import 'package:todo_list_provider/app/core/notifier/default_change_notifier.dart';
import 'package:todo_list_provider/app/exception/auth_exceptions.dart';
import 'package:todo_list_provider/app/services/user_service.dart' show UserService;

class LoginController extends DefaultChangeNotifier { //  Estende DefaultChangeNotifier
  final UserService _userService;
  String? _infoMessage; // Mantém a mensagem de info

  LoginController({required UserService userService}) : _userService = userService;

  String? get infoMessage => _infoMessage;
  bool get hasInfoMessage => _infoMessage != null;

  Future<void> login(String email, String password) async {
    try {
      resetState(); //  Usa o resetState do DefaultChangeNotifier
      showLoading(); // Usa o showLoading do DefaultChangeNotifier
      
      final user = await _userService.login(email, password);

      if (user != null) {
        setSuccess(); // Usa o setSuccess do DefaultChangeNotifier
        print('✅ USUÁRIO LOGADO: ${user.email}');
      }
    } on AuthException catch (e) {
      setError('❌ ${e.message}'); // ✅ Usa o setError do DefaultChangeNotifier
    } catch (e) {
      setError('❌ Erro inesperado ao fazer login');
    } finally {
      hideLoading(); // Usa o hideLoading do DefaultChangeNotifier
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      resetState(); // ✅ Reseta o estado
      showLoading(); // ✅ Mostra loading
      
      await _userService.forgotPassword(email);
      
      // Para forgotPassword, usamos infoMessage em vez de success
      _infoMessage = '✅ E-mail de recuperação enviado! Verifique sua caixa de entrada.';
      notifyListeners(); // ✅ Notifica para mostrar a mensagem
      
      print('✅ E-MAIL DE RECUPERAÇÃO ENVIADO');
    } on AuthException catch (e) {
      setError('❌ ${e.message}');
    } catch (e) {
      setError('❌ Erro inesperado ao enviar e-mail');
    } finally {
      hideLoading(); // ✅ Esconde loading
    }
  }

  // ✅ Método para limpar a mensagem de info
  void clearInfoMessage() {
    _infoMessage = null;
    notifyListeners();
  }

Future<void> googleLogin() async {
    try {
      resetState();
      showLoading();
      
      final user = await _userService.googleLogin();
      
      if (user != null) {
        setSuccess();
        print('✅ Login com Google realizado: ${user.email}');
      }
    } on AuthException catch (e) {
      setError('❌ ${e.message}');
    } catch (e) {
      setError('❌ Erro inesperado ao fazer login com Google');
    } finally {
      hideLoading();
    }
  }
Future<void> logout() async {
  try {
    showLoading();
    await _userService.logout(); // Chama o método do repository
    setSuccess();
    // Navegar para a tela de login ou limpar estado
  } catch (e) {
    setError('Erro ao fazer logout');
  } finally {
    hideLoading();
  }
}
}