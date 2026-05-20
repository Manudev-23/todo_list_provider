import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_list_provider/app/repositories/user/user_repository.dart'; // aqui importa a interface
import 'package:todo_list_provider/app/services/user_service.dart';

class UserServiceImpl implements UserService {
  final UserRepository _userRepository;  //  a interface aqui
  
  UserServiceImpl({required UserRepository userRepository})
      : _userRepository = userRepository {
    print('🔧 [DEBUG] UserServiceImpl CONSTRUIDO');
    print('🔧 [DEBUG] Tipo do _userRepository: ${_userRepository.runtimeType}');
  }
  
  @override
  Future<User?> register(String email, String password) => 
     _userRepository.register(email, password);

  @override
  Future<User?> login(String email, String password) =>
      _userRepository.login(email, password);
    
      @override
      Future<void> forgotPassword(String email) {
    return _userRepository.forgotPassword(email); 
  }
  
  @override
  Future<User?> googleLogin() => _userRepository.googleLogin();
  
  @override
  Future<void> logout() {
    return _userRepository.logout();
  }


} 