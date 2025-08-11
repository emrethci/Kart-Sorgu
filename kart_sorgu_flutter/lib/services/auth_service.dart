import '../models/user.dart';

class AuthService {
  static final List<User> _users = [
    User(email: 'emre', password: '19961996'),
  ];

  static String? _currentUser;

  // Giriş yap
  static bool login(String email, String password) {
    final user = _users.firstWhere(
      (user) => user.email == email && user.password == password,
      orElse: () => User(email: '', password: ''),
    );

    if (user.email.isNotEmpty) {
      _currentUser = user.email;
      return true;
    }
    return false;
  }

  // Çıkış yap
  static void logout() {
    _currentUser = null;
  }

  // Giriş yapılmış mı kontrol et
  static bool isLoggedIn() {
    return _currentUser != null;
  }

  // Mevcut kullanıcıyı getir
  static String? getCurrentUser() {
    return _currentUser;
  }

  // Kullanıcı ekle (geliştirme için)
  static void addUser(String email, String password) {
    _users.add(User(email: email, password: password));
  }
}
