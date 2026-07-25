/// Modelos del Módulo A del backoffice (SPEC puntos): buscador de clientes,
/// saldo, movimientos y configuración del programa de puntos.
/// Todos parsean contra `/api/v1/admin/...` (points_admin).

int _toInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

/// Fila del buscador `GET /admin/customers/?search=<email>`.
/// El superadmin opera por email; `id` es de uso interno para llamar a /points/.
class CustomerListItem {
  final String id;
  final String email;
  final String name;
  final bool isActive;
  final DateTime? dateJoined;

  const CustomerListItem({
    required this.id,
    required this.email,
    this.name = '',
    this.isActive = true,
    this.dateJoined,
  });

  factory CustomerListItem.fromJson(Map<String, dynamic> json) {
    final first = (json['first_name'] ?? '').toString();
    final last = (json['last_name'] ?? '').toString();
    final composed = '$first $last'.trim();
    return CustomerListItem(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? (composed.isEmpty ? '' : composed)).toString(),
      isActive: json['is_active'] != false,
      dateJoined: DateTime.tryParse((json['date_joined'] ?? '').toString()),
    );
  }
}

/// Saldo de puntos de un cliente `GET /admin/users/{id}/points/`.
class PointsBalance {
  final int disponible;
  final int pendiente;
  final int bloqueado;
  final int expirado;
  final int totalHistorico;
  final DateTime? actualizadoEn;

  const PointsBalance({
    this.disponible = 0,
    this.pendiente = 0,
    this.bloqueado = 0,
    this.expirado = 0,
    this.totalHistorico = 0,
    this.actualizadoEn,
  });

  factory PointsBalance.fromJson(Map<String, dynamic> json) => PointsBalance(
        disponible: _toInt(json['disponible']),
        pendiente: _toInt(json['pendiente']),
        bloqueado: _toInt(json['bloqueado']),
        expirado: _toInt(json['expirado']),
        totalHistorico: _toInt(json['total_historico']),
        actualizadoEn:
            DateTime.tryParse((json['actualizado_en'] ?? '').toString()),
      );
}

/// Movimiento del libro de puntos `GET /admin/users/{id}/points/movements/`.
class PointsMovement {
  final String id;
  final DateTime? createdAt;
  final int amount; // con signo
  final String direction; // SUMA|CONSUMO|BLOQUEO|LIBERACION|EXPIRACION|AJUSTE
  final String status; // PENDIENTE|VALIDADO|BLOQUEADO|LIBERADO|CONSUMIDO|RECHAZADO|EXPIRADO|AJUSTADO
  final String sourceType; // SPACE|EVENT|TRANSFER|REFUND|ADJUSTMENT|REGISTRATION|PROFILE|PURCHASE|REFERRAL
  final String reason;
  final String description;
  final String? actorEmail;
  final String? auditReference;
  final String? reverses;

  const PointsMovement({
    this.id = '',
    this.createdAt,
    this.amount = 0,
    this.direction = '',
    this.status = '',
    this.sourceType = '',
    this.reason = '',
    this.description = '',
    this.actorEmail,
    this.auditReference,
    this.reverses,
  });

  factory PointsMovement.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'];
    return PointsMovement(
      id: (json['id'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      amount: _toInt(json['amount']),
      direction: (json['direction'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      sourceType: (json['source_type'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      actorEmail: actor is Map ? (actor['email'] ?? '').toString() : null,
      auditReference: (json['audit_reference'] ?? '').toString().isEmpty
          ? null
          : json['audit_reference'].toString(),
      reverses: json['reverses'] == null ? null : json['reverses'].toString(),
    );
  }

  bool get isPositive => amount >= 0;
}

/// Configuración del programa de puntos `GET/PUT /admin/points/config/`.
/// Forma real: `{settings:{...}, rules:[...]}`.
class PointsConfig {
  final PointsConfigSettings settings;
  final List<PointsConfigRule> rules;
  // Vive en el objeto `antifraud` (togglea la regla CROSS_USER_DUPLICATE, BG-07).
  final bool validarDuplicados;

  const PointsConfig({
    this.settings = const PointsConfigSettings(),
    this.rules = const [],
    this.validarDuplicados = true,
  });

  factory PointsConfig.fromJson(Map<String, dynamic> json) {
    final rawRules = json['rules'];
    final antifraud = (json['antifraud'] as Map?) ?? const {};
    return PointsConfig(
      settings: PointsConfigSettings.fromJson(
          Map<String, dynamic>.from((json['settings'] as Map?) ?? const {})),
      rules: rawRules is List
          ? rawRules
              .whereType<Map>()
              .map((e) => PointsConfigRule.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      validarDuplicados: antifraud['validar_duplicados'] != false,
    );
  }
}

class PointsConfigSettings {
  final int maxPointsPerOrder;
  final int pointsPerEur;
  final int maxReferralsPerMonth;
  final int redemptionCodeValidityDays;
  final int maxPointsPerCampaign; // default global (GP-05)
  final bool validateReferrals; // GP-12: exigir verificación del referido antes de pagar

  const PointsConfigSettings({
    this.maxPointsPerOrder = 0,
    this.pointsPerEur = 0,
    this.maxReferralsPerMonth = 0,
    this.redemptionCodeValidityDays = 0,
    this.maxPointsPerCampaign = 0,
    this.validateReferrals = true,
  });

  factory PointsConfigSettings.fromJson(Map<String, dynamic> json) =>
      PointsConfigSettings(
        maxPointsPerOrder: _toInt(json['max_points_per_order']),
        pointsPerEur: _toInt(json['points_per_eur']),
        maxReferralsPerMonth: _toInt(json['max_referrals_per_month']),
        redemptionCodeValidityDays: _toInt(json['redemption_code_validity_days']),
        maxPointsPerCampaign: _toInt(json['max_points_per_campaign']),
        validateReferrals: json['validate_referrals'] != false,
      );
}

class PointsConfigRule {
  final int id;
  final String action; // REGISTRATION|PROFILE_COMPLETED|FIRST_PURCHASE|REFERRAL|SPACE_PUBLISHED|EVENT_PUBLISHED
  final String labelEs;
  final bool isActive;
  final int basePoints;
  final int lifetimeDays;
  final bool requiresValidation;

  const PointsConfigRule({
    this.id = 0,
    this.action = '',
    this.labelEs = '',
    this.isActive = true,
    this.basePoints = 0,
    this.lifetimeDays = 0,
    this.requiresValidation = false,
  });

  factory PointsConfigRule.fromJson(Map<String, dynamic> json) => PointsConfigRule(
        id: _toInt(json['id']),
        action: (json['action'] ?? '').toString(),
        labelEs: (json['label_es'] ?? json['action'] ?? '').toString(),
        isActive: json['is_active'] != false,
        basePoints: _toInt(json['base_points']),
        lifetimeDays: _toInt(json['lifetime_days']),
        requiresValidation: json['requires_validation'] == true,
      );
}
