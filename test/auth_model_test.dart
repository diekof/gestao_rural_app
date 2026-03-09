import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_rural_app/data/models/auth_models.dart';

void main() {
  test('AuthSessionModel parse tokens only', () {
    final model =
        AuthSessionModel.fromJson({'accessToken': 'a', 'refreshToken': 'r'});
    expect(model.accessToken, 'a');
    expect(model.refreshToken, 'r');
    expect(model.toEntity().accessToken, 'a');
  });

  test('UserModel parse UserResponse payload', () {
    final user = UserModel.fromJson({
      'id': '1',
      'tenantId': 't1',
      'nome': 'Ana',
      'email': 'ana@agro.com',
      'username': 'ana',
      'role': 'MANAGER',
      'status': 'ACTIVE',
      'lastLoginAt': '2024-10-10T10:00:00Z',
      'createdAt': '2024-01-01T12:00:00Z',
      'updatedAt': '2024-02-01T12:00:00Z',
      'createdBy': 'system',
      'updatedBy': 'system',
    });
    final entity = user.toEntity();
    expect(entity.name, 'Ana');
    expect(entity.username, 'ana');
    expect(entity.status, 'ACTIVE');
    expect(entity.lastLoginAt?.toUtc().year, 2024);
  });
}
