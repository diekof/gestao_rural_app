import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_rural_app/data/models/auth_models.dart';

void main() {
  test('AuthSessionModel parse', () {
    final model = AuthSessionModel.fromJson({
      'accessToken': 'a',
      'refreshToken': 'r',
      'user': {'id': 1, 'name': 'Ana', 'email': 'ana@agro.com'},
    });
    expect(model.user.email, 'ana@agro.com');
    expect(model.toEntity().accessToken, 'a');
  });
}
