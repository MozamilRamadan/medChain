import '../models/account.dart';

class AuthController {
  Account? _currentAccount;

  Account? get currentAccount => _currentAccount;

  bool get isLoggedIn => _currentAccount != null;

  void login(Account account) {
    _currentAccount = account;
  }

  void logout() {
    _currentAccount = null;
  }
}