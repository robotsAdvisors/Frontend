class StoreUserModel {
  // Backend v2 role values (uppercase)
  static const String roleOwner = 'OWNER';
  static const String roleAdmin = 'ADMIN';
  static const String roleMember = 'MEMBER';

  final String id;
  final String email;
  final String name;
  final String role; // OWNER | ADMIN | MEMBER
  final String storeId;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;

  StoreUserModel({
    required this.id,
    required this.email,
    this.name = '',
    required this.role,
    required this.storeId,
    this.avatarUrl,
    this.isActive = true,
    required this.createdAt,
  });

  String get displayName {
    if (name.isNotEmpty) return name;
    return email.contains('@') ? email.split('@').first : email;
  }

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  /// Etiqueta de rol localizada para mostrar en la UI.
  String get roleLabel {
    switch (role.toUpperCase()) {
      case roleOwner:
        return 'Propietario';
      case roleAdmin:
        return 'Administrador';
      case roleMember:
        return 'Miembro';
      // Legacy fallbacks
      case 'STORE_ADMIN':
        return 'Administrador';
      case 'STORE_VIEWER':
        return 'Visualizador';
      default:
        return role;
    }
  }

  bool get isOwner => role.toUpperCase() == roleOwner;
  bool get isAdmin => role.toUpperCase() == roleAdmin || isOwner;
  bool get canBeRemoved => !isOwner;

  factory StoreUserModel.fromJson(Map<String, dynamic> json) {
    final userRaw = json['user'];
    final String email;
    final String name;
    final String id;
    final String? avatarUrl;

    if (userRaw is Map) {
      id = (userRaw['id'] ?? json['id'] ?? '').toString();
      email = (userRaw['email'] ?? '').toString();
      final fn = (userRaw['first_name'] ?? '').toString().trim();
      final ln = (userRaw['last_name'] ?? '').toString().trim();
      name = [fn, ln].where((s) => s.isNotEmpty).join(' ').trim().isNotEmpty
          ? [fn, ln].where((s) => s.isNotEmpty).join(' ')
          : (userRaw['name'] ?? userRaw['username'] ?? '').toString();
      avatarUrl = userRaw['avatar']?.toString() ?? userRaw['photo']?.toString();
    } else {
      id = (json['id'] ?? '').toString();
      email = (json['email'] ?? '').toString();
      name = (json['name'] ?? json['full_name'] ?? '').toString();
      avatarUrl = json['avatar']?.toString() ?? json['avatar_url']?.toString();
    }

    final storeRaw = json['store'];
    final storeId = storeRaw is Map
        ? (storeRaw['id'] ?? '').toString()
        : (json['store_id'] ?? json['storeId'] ?? storeRaw ?? '').toString();

    return StoreUserModel(
      id: id,
      email: email,
      name: name,
      role: (json['role'] ?? '').toString(),
      storeId: storeId,
      avatarUrl: avatarUrl,
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(
              (json['created_at'] ?? json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'storeId': storeId,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
