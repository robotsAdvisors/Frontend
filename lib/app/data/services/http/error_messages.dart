/// Traducción al español de los `error_code` del backend.
///
/// El backend responde siempre en inglés, pero la interfaz del backoffice está
/// en español. Sin esta traducción el usuario veía el mensaje crudo del
/// servidor: "Invalid Credentials." en una pantalla íntegramente en español.
///
/// Se traduce por código, nunca por texto: el `error_code` es el contrato
/// estable, el `message` puede cambiar en el backend sin previo aviso.
///
/// Un código que no esté aquí conserva el mensaje del servidor, así que un
/// error nuevo se sigue viendo aunque todavía no tenga traducción.
class ErrorMessages {
  const ErrorMessages._();

  /// Texto en español para [code], o null si no está traducido.
  static String? of(String code) => _mensajes[code];

  static const Map<String, String> _mensajes = {
    // Cuentas y autenticación
    'INVALID_CREDENTIALS': 'Credenciales inválidas. Inténtalo de nuevo.',
    'INVALID_CURRENT_PASSWORD': 'La contraseña actual es incorrecta.',
    'REPEATED_PASSWORD':
        'La nueva contraseña no puede ser igual a la anterior.',
    'PASSWORDS_DO_NOT_MATCH': 'Las contraseñas no coinciden.',
    'INACTIVE_ACCOUNT': 'La cuenta está inactiva.',
    'ACCOUNT_ALREADY_ACTIVATED': 'La cuenta ya está activada.',
    'EMAIL_ALREADY_EXISTS': 'Este correo electrónico ya está registrado.',
    'EMAIL_NOT_FOUND': 'Correo electrónico no encontrado.',
    'USER_NOT_FOUND': 'Usuario no encontrado.',
    'INVALID_SOCIAL_TOKEN': 'Token de inicio de sesión social inválido.',
    'NOT_A_SOCIAL_USER': 'Esta operación solo está disponible para usuarios '
        'que iniciaron sesión con una cuenta social.',
    'SOCIAL_USER_CANNOT_RESET_PASSWORD':
        'No se puede restablecer la contraseña de un usuario social.',
    'INVALID_OTP': 'Código OTP inválido.',
    'OTP_NOT_VALIDATED': 'El OTP no ha sido validado.',
    'RESEND_MAX_LIMIT':
        'Se ha alcanzado el límite de reenvíos. Espera unos minutos.',
    'EIGHTEEN_YEARS_REQUIRED': 'El cliente debe ser mayor de 18 años.',
    'INVALID_PHONE': 'Número de teléfono inválido.',

    // Política de contraseñas
    'PASSWORD_TOO_SHORT': 'La contraseña debe tener al menos 8 caracteres.',
    'PASSWORD_REQUIRES_NUMBER':
        'La contraseña debe contener al menos un número.',
    'PASSWORD_REQUIRES_UPPERCASE':
        'La contraseña debe contener al menos una letra mayúscula.',
    'PASSWORD_REQUIRES_SPECIAL_CHARACTER':
        'La contraseña debe contener al menos un carácter especial.',
    'TOO_MANY_ATTEMPTS':
        'Demasiados intentos. Espera unos minutos antes de volver a intentarlo.',

    // Puntos
    'INSUFFICIENT_POINTS': 'No hay suficientes puntos.',
    'MOVEMENT_NOT_FOUND': 'Movimiento no encontrado.',
    'ALREADY_REVERSED': 'Este movimiento ya fue revertido.',
    'IDEMPOTENCY_KEY_REQUIRED':
        'Falta la clave de idempotencia de la operación.',

    // Marketplace
    'MARKETPLACE_EMPTY_CART': 'El pedido debe contener al menos un artículo.',
    'MARKETPLACE_PRODUCT_NOT_FOUND':
        'Uno o más productos no existen o están inactivos.',
    'MARKETPLACE_INSUFFICIENT_STOCK':
        'No hay stock suficiente para uno o más productos.',
    'MARKETPLACE_INVALID_ORDER_ITEM':
        'Las líneas del pedido deben incluir el producto y la cantidad.',

    // Pagos y cobros
    'card_declined': 'La tarjeta fue rechazada. Revisa los datos de pago.',
    'PAYMENT_FAILED': 'El pago falló. Inténtalo de nuevo más tarde.',
    'PAYMENT_REQUIRES_ACTION':
        'El pago requiere una acción adicional. Revisa el método de pago.',
    'PAYMENT_METHOD_NOT_FOUND': 'Método de pago no encontrado.',
    'PAYMENT_METHOD_ALREADY_EXISTS': 'El método de pago ya existe.',
    'PAYOUT_METHOD_NOT_FOUND': 'Método de retiro no encontrado.',
    'PAYOUT_REQUEST_FAILED': 'La solicitud de retiro no pudo completarse.',
    'BALANCE_LOWER_THAN_MINIMUM':
        'El saldo está por debajo del mínimo para retirar.',
    'EARNING_ACCOUNT_ALREADY_EXISTS': 'La cuenta de ingresos ya existe.',
    'EARNING_ACCOUNT_REQUIRED': 'Se requiere una cuenta de ingresos.',
    'EARNING_ACCOUNT_IS_NOT_ACCEPTED': 'La cuenta de ingresos no es aceptada.',
    'COUNTRY_NOT_SUPPORTED': 'Este país no es compatible.',
    'INVALID_ADDRESS_COUNTRY': 'El país de la dirección no es válido.',
    'INVALID_PAYOUT_METHOD_FOR_ACCOUNT_COUNTRY':
        'Este método de retiro no está disponible en ese país.',
    'BAD_REQUEST_FOR_CURRENT_STEP': 'Solicitud inválida para el paso actual.',

    // Reservas
    'RESERVATION_NOT_FOUND': 'Reserva no encontrada.',
    'RESERVATION_CANCELLED': 'Esta reserva ha sido cancelada.',
    'ACTIVE_RESERVATION_ALREADY_EXIST': 'Ya existe una reserva activa.',
    'CANCEL_RESERVATION_ERROR': 'Ocurrió un error al cancelar la reserva.',
    'CONFIRM_RESERVATION_ERROR': 'Ocurrió un error al confirmar la reserva.',
    'INVALID_CONFIRMATION_CODE': 'Código de confirmación inválido.',
    'SPACE_ALREADY_RESERVED': 'Esta plaza ya está reservada.',
    'SPACE_OWNER_CANNOT_RESERVE': 'No se puede reservar la propia plaza.',

    // Plazas
    'SPACE_NOT_FUND': 'Plaza no encontrada.',
    'SPACE_EXPIRED': 'Esta plaza ha caducado y ya no puede modificarse.',
    'SPACE_INVALID_PRICE': 'El precio de la plaza es inválido.',
    'SPACE_INVALID_TIME_TO_WAIT': 'El tiempo de espera indicado es inválido.',
    'SPACE_PUBLISHED_NEARBY_RECENTLY':
        'Ya se publicó una plaza cerca recientemente.',
    'SPACE_FEEDBACK_ALREADY_CREATED':
        'Ya se ha enviado una reseña para esta plaza.',
    'SPACE_OWNER_CANNOT_SEND_FEEDBACK':
        'El propietario de la plaza no puede enviar reseñas.',
    'INVALID_COORDINATES': 'Las coordenadas indicadas no son válidas.',

    // Eventos
    'EVENT_NOT_FUND': 'Evento no encontrado.',
    'EVENT_PUBLICATION_ERROR': 'Ocurrió un error al publicar el evento.',
    'EVENT_FEEDBACK_ALREADY_CREATED':
        'Ya se ha enviado una reseña para este evento.',
    'EVENT_OWNER_CANNOT_SEND_FEEDBACK':
        'El propietario del evento no puede enviar reseñas.',
    'NOTIFICATION_ALREADY_SCHEDULED_IN_PLACE':
        'Ya hay una notificación programada para este lugar.',
    'ENDS_TIME_SHOULD_BE_GREATER':
        'La hora de fin debe ser posterior a la de inicio.',
    'ENDS_AND_START_TIME_SHOULD_BE_GREATER_THAN_NOW':
        'Las horas de inicio y fin deben estar en el futuro.',

    // Vehículos
    'CAR_ALREADY_CREATED': 'Ya se ha añadido un coche.',
    'USER_DOES_NOT_HAVE_CAR': 'No hay un coche asociado a este usuario.',

    // Genéricos
    'VALIDATION_ERROR': 'Algunos de los datos introducidos no son válidos.',
    'UNKNOWN_ERROR': 'Solicitud inválida.',
  };

  /// Solo para los tests: los códigos traducidos.
  static Iterable<String> get codigos => _mensajes.keys;
}
