class Account {
  final int userId;
  final String fullName;
  final String phone;
  final String nationalId;
  final List<AccountRole> roles;

  Account({
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.nationalId,
    required this.roles,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      userId: json['userId'],
      fullName: json['fullName'],
      phone: json['phone'],
      nationalId: json['nationalId'],
      roles: (json['roles'] as List)
          .map((role) => AccountRole.fromJson(role))
          .toList(),
    );
  }
}

class AccountRole {
  final String role;
  final int roleId;

  AccountRole({
    required this.role,
    required this.roleId,
  });

  factory AccountRole.fromJson(Map<String, dynamic> json) {
    return AccountRole(
      role: json['Role'],
      roleId: json['RoleId'],
    );
  }
}