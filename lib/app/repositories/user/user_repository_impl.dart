import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todo_list_provider/app/exception/auth_exceptions.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  UserRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(
          scopes: ['email', 'profile'],
        );

  @override
  Future<User?> register(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getRegisterErrorMessage(e));
    } catch (e) {
      throw AuthException('Erro inesperado no cadastro');
    }
  }

  @override
  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getLoginErrorMessage(e));
    } catch (e) {
      throw AuthException('Erro inesperado no login');
    }
  }

  @override
  Future<User?> googleLogin() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw AuthException('Login cancelado');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw AuthException(
          'Este email já está cadastrado com outro método de login.\n\n'
          'Faça login com email e senha primeiro.'
        );
      }
      throw AuthException(_getGoogleAuthErrorMessage(e));
    } catch (e) {
      throw AuthException('Erro inesperado no login com Google');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getForgotPasswordErrorMessage(e));
    } catch (e) {
      throw AuthException('Erro inesperado ao enviar email');
    }
  }

  // Métodos privados para tratamento de erros
  String _getRegisterErrorMessage(FirebaseAuthException e) {
    const errors = {
      'email-already-in-use': 'Email já cadastrado.',
      'invalid-email': 'Email inválido.',
      'weak-password': 'Senha muito fraca.',
    };
    return errors[e.code] ?? 'Erro no cadastro: ${e.message}';
  }

  String _getLoginErrorMessage(FirebaseAuthException e) {
    const errors = {
      'user-not-found': 'Usuário não encontrado.',
      'wrong-password': 'Senha incorreta.',
      'invalid-email': 'Email inválido.',
      'user-disabled': 'Conta desativada.',
    };
    return errors[e.code] ?? 'Erro no login: ${e.message}';
  }

  String _getGoogleAuthErrorMessage(FirebaseAuthException e) {
    const errors = {
      'network-request-failed': 'Sem conexão com a internet.',
      'user-disabled': 'Conta desativada.',
      'invalid-credential': 'Credencial inválida.',
    };
    return errors[e.code] ?? 'Erro no login com Google: ${e.message}';
  }

  String _getForgotPasswordErrorMessage(FirebaseAuthException e) {
    const errors = {
      'user-not-found': 'Email não cadastrado.',
      'invalid-email': 'Email inválido.',
    };
    return errors[e.code] ?? 'Erro ao enviar email: ${e.message}';
  }
  
  @override
  Future<void> logout()async {
    return _firebaseAuth.signOut();
    

  }
}