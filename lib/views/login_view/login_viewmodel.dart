import 'package:financeplanner/services/login_service.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';

@injectable
class LoginViewModel extends BaseViewModel {
  final LoginService _loginService;

  LoginViewModel(this._loginService);

  Future<bool> login(String authService) async {
    return await _loginService.login(authService);
  }
}
