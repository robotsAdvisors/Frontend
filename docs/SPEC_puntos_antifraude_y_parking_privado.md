# SPEC — Gestión del Super Admin en el Backoffice: Puntos y Supervisión de Aparcamiento

| | |
|---|---|
| **Estado** | Borrador para revisión |
| **Fecha** | 2026-07-25 |
| **Ámbito backend** | Django, app `points_admin` (`/api/v1/admin/…`) |
| **Ámbito frontend** | **Backoffice del Super Admin, exclusivamente** (repo `Frontend`, `d:\Frontend`) |
| **Fuera de ámbito** | Pantallas de usuario final (wallet propia, mapa, publicar, pagar) → viven en la **app de cliente** (repo `Lentend`) |
| **Pantallas que concluye** | Wallet de puntos, Historial de movimientos, Configuración de puntos, Publicaciones de aparcamiento, Detalle de publicación |
| **Fuentes autoritativas** | `Historias de usuario - conseguir y consumir puntos LetDem 06-07.md` · `Historias funcionales - informacion compensada de aparcamiento 06-07.md` |

---

## 0. Alcance y principio rector

Este documento especifica **solo lo que el Super Admin hace desde el backoffice**. Todo lo que el usuario final publica, consulta o paga desde la app (publicar información de aparcamiento, mapa, wallet propia, autorizar pagos) **no se especifica aquí**: se construye en el frontal de cliente (`Lentend`) y su backend. El backoffice **consume y supervisa** los datos que ese sistema produce.

Dos módulos:

- **Módulo A — Puntos (construible ya).** El Super Admin consulta el saldo y los movimientos de puntos de un usuario concreto, ajusta puntos por fraude/incidencia con auditoría, revisa la cola de puntos sospechosos y configura las reglas globales del programa. Historias: **ADM-PT-01, ADM-PT-02, ADM-PT-03**.
- **Módulo B — Supervisión de aparcamiento (bloqueado por negocio/legal).** El Super Admin supervisa las operaciones de "información compensada": cola de revisión, expediente, mediación y resolución de disputas, reembolsos, restricciones y configuración del piloto. Historias: **IC-05.03, IC-06.03, IC-06.04, IC-07.05, IC-08.01…IC-08.05**.

**Principio rector del Módulo A:** el saldo de puntos es un **libro mayor de solo-adición (*append-only*)**. Nunca se actualiza un contador ni se borra un movimiento; toda corrección es un asiento nuevo. Da auditoría, reversibilidad y defensa jurídica por construcción, y cumple ADM-PT-03 / CP-12.

**Convenciones del proyecto (obligatorias):** base `https://api.letdem.net/api/v1`; rutas con barra final; paginación DRF `{count, next, previous, results}`; contrato de error `{error_code, message, details}`; permiso por defecto `IsSuperAdmin` → `403` en cualquier otro caso.

---

# MÓDULO A — Puntos (Super Admin)

> ✅ **IMPLEMENTADO EN BACKEND (2026-07-25).** Los endpoints de este módulo ya están en vivo. Esta sección refleja la implementación real; las diferencias con el borrador previo se han incorporado (source_type en inglés + `TRANSFER`/`REFUND`, campo `description` en movimientos, config con forma `{settings, rules}`, `409` con `details:{needed, available}`). Pendiente: **cablear el frontend** (pantallas de Hernan) a estos endpoints.

## A.1 Modelo de datos

Sigue **§8.1 del documento de puntos** (campos y nomenclatura autoritativos). Clave: `direction` (tipo de movimiento) y `status` (estado) son **campos separados** — no mezclarlos en uno solo, como sí hace el prototipo actual.

```python
class PointsMovement(models.Model):
    """Libro mayor de puntos. APPEND-ONLY: nunca UPDATE ni DELETE (CP-12, ADM-PT-03)."""

    DIRECTION = [("SUMA","Suma"), ("CONSUMO","Consumo"), ("BLOQUEO","Bloqueo"),
                 ("LIBERACION","Liberación"), ("EXPIRACION","Expiración"), ("AJUSTE","Ajuste")]

    STATUS = [("PENDIENTE","Pendiente"), ("VALIDADO","Validado"), ("BLOQUEADO","Bloqueado"),
              ("CONSUMIDO","Consumido"), ("LIBERADO","Liberado"), ("RECHAZADO","Rechazado"),
              ("EXPIRADO","Expirado"), ("AJUSTADO","Ajustado")]          # §3.1

    SOURCE = [("SPACE","Plaza"), ("EVENT","Alerta vial"), ("TRANSFER","Transferencia"),
              ("REFUND","Reembolso"), ("ADJUSTMENT","Ajuste"), ("REGISTRATION","Registro"),
              ("PROFILE","Perfil"), ("PURCHASE","Compra"), ("REFERRAL","Referido")]   # real backend

    user             = FK(User, related_name="points_movements", db_index=True)  # user_id
    amount           = IntegerField()                 # con signo: +50 / -100
    direction        = CharField(choices=DIRECTION)
    status           = CharField(choices=STATUS)
    source_type      = CharField(choices=SOURCE)
    source_id        = CharField(null=True)           # referencia a la entidad origen
    reason           = TextField(blank=True)          # obligatorio si direction=AJUSTE
    expires_at       = DateTimeField(null=True)       # caducidad si aplica (CP-11)
    created_at       = DateTimeField(auto_now_add=True, db_index=True)
    validated_at     = DateTimeField(null=True)
    validated_by     = FK(User, null=True)            # sistema / usuario / agente
    audit_reference  = CharField(null=True)           # ticket o expediente (ADM-PT-03)

    # Operativos (no en §8.1, necesarios para integridad)
    actor            = FK(User, null=True)            # null=sistema; informado=Super Admin
    idempotency_key  = CharField(unique=True, null=True)
    reverses         = FK("self", null=True, related_name="reversals")

    class Meta:
        indexes = [Index(fields=["user", "-created_at"])]
```

```python
class PointsWallet(models.Model):
    """Caché de saldos. Se actualiza SIEMPRE en la misma transacción que el movimiento."""
    user       = OneToOne(User, related_name="points_wallet")
    disponible = IntegerField(default=0)
    pendiente  = IntegerField(default=0)
    bloqueado  = IntegerField(default=0)
    expirado   = IntegerField(default=0)
    updated_at = DateTimeField(auto_now=True)
```

La configuración real tiene **dos partes**: `settings` (parámetros globales) y `rules` (una regla por acción que genera puntos):

```jsonc
// GET /admin/points/config/  y respuesta del PUT
{
  "settings": {
    "max_points_per_order": 300,          // GP-04
    "points_per_eur": 1,                  // GP-04
    "max_referrals_per_month": 5,         // GP-12
    "redemption_code_validity_days": 7,   // CP-06
    "modified": "..."
  },
  "rules": [
    { "id": 1, "action": "REGISTRATION", "label_es": "Completar el registro",
      "label_en": "Complete sign-up", "is_active": true, "base_points": 50,
      "lifetime_days": 365, "requires_validation": false,
      "validations_needed": 0, "unvalidated_points": 0, "modified": "..." }
    // + PROFILE_COMPLETED, FIRST_PURCHASE, REFERRAL, SPACE_PUBLISHED, EVENT_PUBLISHED
  ]
}
```

**Migración de datos:** al desplegar, generar un `PointsMovement` histórico por cada acreditación existente para que el saldo derivado cuadre con el actual. Un saldo que no se reconstruya desde el libro es un bug.

## A.2 Buckets y transiciones (§3.1)

| `direction` | `status` resultante | Origen → Destino | Cuándo |
|---|---|---|---|
| SUMA | PENDIENTE | — → pendiente | Acción que requiere validación (GP-08/09/10) |
| SUMA | VALIDADO | pendiente → disponible | Acción confirmada (GP-01…GP-07) |
| BLOQUEO | BLOQUEADO | disponible → bloqueado | Canje generado (CP-04) |
| CONSUMO | CONSUMIDO | bloqueado → gastado | Tienda confirma entrega (CP-05) |
| LIBERACION | LIBERADO | bloqueado → disponible | Canje expira/cancela (CP-06/07) |
| EXPIRACION | EXPIRADO | disponible → expirado | Job de caducidad (CP-11) |
| AJUSTE | AJUSTADO | cualquiera → cualquiera | Intervención Super Admin (ADM-PT-03) |

## A.3 Endpoints

### A.3.1 Saldo de un usuario — pantalla *Wallet de puntos* (CP-01)
```http
GET /api/v1/admin/users/{user_id}/points/
→ 200 {user_id, disponible, pendiente, bloqueado, expirado, total_historico, actualizado_en}
```

### A.3.2 Movimientos de un usuario — pantalla *Historial de movimientos* (CP-02)
```http
GET /api/v1/admin/users/{user_id}/points/movements/
      ?direction=AJUSTE&status=RECHAZADO&source_type=INFORMACION&from=&to=&page=
→ 200 {count, next, previous, results:[
    {id, created_at, amount, direction, status, source_type, source:{id},
     reason, description, validated_at, validated_by, actor:{id,email},
     audit_reference, reverses}]}
```
`source_type` real: `SPACE · EVENT · TRANSFER · REFUND · ADJUSTMENT · REGISTRATION · PROFILE · PURCHASE · REFERRAL`.

### A.3.3 Ajuste manual de puntos — endpoint crítico (ADM-PT-03)
```http
POST /api/v1/admin/users/{user_id}/points/adjustments/
Idempotency-Key: <uuid>        ← obligatorio
{ "amount": -500, "direction": "AJUSTE", "reason_text": "5 contribuciones duplicadas",
  "audit_reference": "ticket:1234", "bucket": "disponible" }
→ 201 {movement_id, saldos:{disponible, pendiente, bloqueado, expirado}}
```
`amount≠0`; `reason_text` y `audit_reference` (ticket/incidencia) obligatorios; `select_for_update()` sobre el wallet dentro de `transaction.atomic()`; escribe en el audit-log del usuario. No se presenta como pago ni reembolso (CP-12).

**Saldo no negativo (decisión D1):** el saldo **nunca puede quedar negativo**. Si un ajuste dejaría un bucket por debajo de 0, se **rechaza** con `409 INSUFFICIENT_POINTS`, indicando cuántos puntos hay disponibles para que el Super Admin reintente con una cantidad menor. Consecuencia a tener en cuenta: si el defraudador **ya gastó** los puntos, la retirada se limita a lo que quede en el saldo; la pérdida ya materializada queda **registrada y auditada**, pero no se recupera del wallet.

### A.3.4 Reversión de un ajuste
```http
POST /api/v1/admin/points/adjustments/{movement_id}/reverse/   {"reason_text": "..."}
→ 201  (asiento con amount invertido y reverses=movement_id; el original permanece)
```
No existe `DELETE`.

### A.3.5 Cola de puntos sospechosos (ADM-PT-02) — reutiliza BG-06 (ya existe)
```http
GET  /api/v1/admin/moderation/contributions/?status=SUSPICIOUS|UNDER_REVIEW|OBSERVATION
POST /api/v1/admin/moderation/contributions/{kind}/{id}/
     {decision: "validate|reject|observe", reason, revoke_points: true}
```
Con `revoke_points:true`, rechazar una contribución fraudulenta genera automáticamente el `PointsMovement` de retirada (`direction=AJUSTE`, `source_type=INFORMACION`), visible en el historial del usuario (ADM-PT-02).

### A.3.6bis Regla de canje con saldo insuficiente (decisión D1)

El canje (flujo de la app, CP-04) **no se permite si el usuario no tiene puntos disponibles suficientes**. El backend debe rechazar la generación del canje con `409 INSUFFICIENT_POINTS` y un mensaje tipo *"Te faltan N puntos"*, sin bloquear puntos ni crear el código. Nunca debe dejar el bucket `disponible` negativo.

### A.3.6 Configuración del programa — pantalla *Configuración de puntos* (ADM-PT-01)
```http
GET /api/v1/admin/points/config/    → 200 {settings:{…}, rules:[{action, base_points, …}]}
PUT /api/v1/admin/points/config/    → 200 (mismo shape; parcial)
```
El `PUT` es **parcial**: solo se toca lo que envíes; se audita `old/new`; **no retroactivo**.
```jsonc
PUT body:
{ "settings": { "points_per_eur": 2 },
  "rules": [ { "action": "REGISTRATION", "base_points": 75 } ] }
```
**Ojo de cableado:** la pantalla de Hernan tiene campos planos (limitePorPedido, caducidadMeses, puntosRegistro…). Hay que remapearlos: los globales van a `settings`; los puntos-por-acción (registro, perfil, referido…) van a `rules[action].base_points`. Los campos de Hernan `maximoPorCampania`, `validarDuplicados` y `validarReferidos` **no existen** en la config real → se quitan o se dejan como no-op hasta que negocio los defina.

## A.4 Errores (Módulo A)

| HTTP | `error_code` | Cuándo |
|---|---|---|
| 400 | `VALIDATION_ERROR` | `amount`=0, `reason_text`/`audit_reference` vacío, bucket inválido |
| 403 | `PERMISSION_DENIED` | No es Super Admin |
| 404 | `USER_NOT_FOUND` / `MOVEMENT_NOT_FOUND` | — |
| 409 | `INSUFFICIENT_POINTS` | Dejaría negativo → `details:{needed, available}` (mostrar "faltan N") |
| 409 | `ALREADY_REVERSED` | El ajuste ya tiene reversión |
| 428 | `IDEMPOTENCY_KEY_REQUIRED` | Falta la cabecera en el ajuste |

---

# MÓDULO B — Supervisión de aparcamiento (Super Admin)

> **Estado: PARCIAL / bloqueado.** El documento de aparcamiento (§17) prohíbe considerar este flujo listo para desarrollo definitivo hasta que negocio apruebe **PN-01…PN-16**, legal valide el objeto de la compensación y técnica cierre la **arquitectura de Stripe Connect**. Esta sección define **solo la parte de backoffice** para preparar modelo y contratos, no para lanzar sin esas aprobaciones.

## B.0 Qué NO es esto

El backoffice **no publica ni cobra** información de aparcamiento. Publicar (las 3 modalidades), el mapa, autorizar el pago y abrir disputa son acciones del **usuario en la app** (EPICs IC-02, IC-03, IC-06.01). El backoffice solo **supervisa, media, resuelve y configura**.

> **Pregunta abierta (D8):** en conversaciones se mencionó que "el superadmin puede publicar parking privados de cobro". Eso **no aparece** en las historias (donde publica el *informador* desde la app). Si es requisito real, necesita su propia decisión de negocio; no se especifica aquí.

## B.1 Modelo de datos (solo lo que el backoffice lee/decide)

Las tres modalidades tienen **economías distintas** (no son etiquetas): PA-01 va por **puntos** (sin Stripe); PA-02 y PA-03 van por **Stripe Connect**.

| Código | Modalidad | Incentivo | Stripe Connect |
|---|---|---|---|
| PA-01 | He visto un sitio libre | Puntos promocionales | No |
| PA-02 | Voy a dejar libre mi sitio | Compensación base | Sí |
| PA-03 | Espero al usuario | Compensación superior | Sí |

```python
class ParkingOperation(models.Model):
    modalidad         = Choice(PA_01, PA_02, PA_03)
    informador        = FK(User)
    solicitante       = FK(User, null=True)
    # Estado funcional (§6.1)
    estado_funcional  = Choice(borrador, pendiente_validacion, activa, bloqueada,
                               info_liberada, pendiente_resultado, validada,
                               frustrada_sin_sancion, rechazada, en_revision,
                               expirada, cancelada)
    # Estado económico (§6.2) — solo PA-02/PA-03
    estado_economico  = Choice(sin_operacion, pendiente_autorizacion, autorizada,
                               pendiente_validacion, capturada, cancelada,
                               reembolso_pendiente, reembolsada, disputada, incidencia_pago)
    stripe_payment_intent_id, stripe_charge_id, importe, importe_reembolsado, moneda
    zona_aproximada, created_at, expires_at

class OperationEvent(models.Model):      # append-only → timeline del expediente (IC-08.03)
    operation, tipo(FUNCIONAL|ECONOMICO), estado, actor, reason, created_at

class ParkingDispute(models.Model):      # IC-06, estados §6.3
    operation, solicitante, informador, motivo, estado, resolucion, resuelto_por

class ParkingConfig(models.Model):       # IC-08.02 — parámetros PN-01…PN-16
    importe_pa02, importe_pa03, radio_publico, vigencia_min, ventana_resultado,
    max_diario_usuario, max_diario_informador, umbrales_antifraude(json), version, updated_by
```

## B.2 Endpoints (backoffice)

### B.2.1 Cola de operaciones en revisión (IC-08.01)
```http
GET /api/v1/admin/parking/operations/
      ?motivo=&estado_funcional=&estado_economico=&riesgo=&modalidad=&search=&page=
→ {count, results:[{id, modalidad, estado_funcional, estado_economico,
     informador:{id,nombre}, solicitante:{id,nombre}, importe, riesgo, created_at, stripe_charge_id}]}
```
Filtra por motivo, estado, antigüedad, riesgo e impacto económico. Abrir la ficha **no cierra** la operación.

### B.2.2 Expediente completo de una operación (IC-08.03)
```http
GET /api/v1/admin/parking/operations/{id}/
→ {…, timeline:[OperationEvent], evidencias:[…], disputa:{…},
    stripe:{payment_intent_id, charge_id, estado}, reglas_aplicadas:[…]}
```
Diferencia información **declarada**, **calculada** y **confirmada por Stripe**. Datos sensibles solo a perfiles autorizados.

### B.2.3 Resolver / decidir sobre una operación o disputa (IC-06.04)
```http
POST /api/v1/admin/parking/operations/{id}/decision/
{ "decision": "validate | cancel | refund | close_no_sanction | restrict",
  "reason": "...", "amount": "4.50" }        # amount solo en refund parcial
→ 200 {estado_funcional, estado_economico}
```
Registra quién decidió, cuándo y bajo qué política. Corresponde a los 4 botones de *Detalle de publicación* (Validar / Revisar / Cancelar / Reembolsar).

### B.2.4 Reembolso de un pago capturado (IC-05.03)
```http
POST /api/v1/admin/parking/operations/{id}/refund/   {"reason": "...", "amount": "4.50"}
→ 202 (inicia refund en Stripe; el estado final lo confirma el webhook)
```
Vinculado a la transacción y al expediente. Distingue `reembolso_pendiente` de `reembolsada`. Contempla revertir la compensación al informador (Stripe Connect, PN-10/12). Un fallo pasa a `incidencia_pago`.

### B.2.5 Restricciones progresivas a un usuario (IC-07.05)
```http
POST /api/v1/admin/users/{id}/restrictions/
{ "medida": "advertencia|limite_reducido|revision_previa|suspension_temporal|restriccion_cobro",
  "causa": "...", "alcance": "...", "duracion_dias": 30 }
```
Terminología `restricción/suspensión`, nunca `baneo`. El levantamiento también se registra.

### B.2.6 Configuración del piloto (IC-08.02)
```http
GET /api/v1/admin/parking/config/     PUT /api/v1/admin/parking/config/
```
Solo parámetros habilitados (PN-01…PN-16). Cada cambio registra valor anterior/nuevo, responsable, fecha, motivo. **No retroactivo**; versión y fecha de entrada en vigor.

### B.2.7 Indicadores del piloto (IC-08.05)
```http
GET /api/v1/admin/parking/metrics/?from=&to=
→ {publicaciones, solicitudes, autorizaciones, capturas, cancelaciones, reembolsos,
   tasa_info_util, tasa_ocupado_tercero, tasa_sin_respuesta, tasa_disputa, fraude_sospechado,
   tiempo_medio_resolucion, impacto_economico}
```

### B.2.8 Webhooks de Stripe (IC-08.04) — responsabilidad del backend, alimenta al backoffice
No es un endpoint del backoffice pero **es imprescindible**: los webhooks firmados e idempotentes son la **fuente de verdad** del estado económico. Sin ellos el backoffice muestra estados falsos.

| Evento | Efecto en `estado_economico` |
|---|---|
| `payment_intent.succeeded` | pendiente_autorizacion → autorizada / capturada |
| `charge.refunded` | → reembolsada (+ `importe_reembolsado`) |
| `charge.dispute.created` | → disputada |
| `charge.dispute.closed` | → validada o reembolsada según resultado |

---

## 7. Mapeo pantalla ↔ endpoint ↔ historia

| Pantalla de Hernan (backoffice) | Endpoint | Historia | ¿Construible ya? |
|---|---|---|---|
| Wallet de puntos | `GET /admin/users/{id}/points/` | ADM-PT-02, CP-01 | ✅ Sí |
| Historial de movimientos | `GET /admin/users/{id}/points/movements/` | ADM-PT-02, CP-02 | ✅ Sí |
| (falta UI) ajuste de puntos | `POST …/points/adjustments/` | ADM-PT-03 | ✅ Sí |
| Configuración de puntos | `GET/PUT /admin/points/config/` | ADM-PT-01 | ✅ Sí |
| Publicaciones de aparcamiento | `GET /admin/parking/operations/` | IC-08.01 | ⛔ Bloqueado (PN + legal + Stripe Connect) |
| Detalle de publicación | `GET …/{id}/` + `POST …/decision/` + `…/refund/` | IC-06.04, IC-05.03, IC-08.03 | ⛔ Bloqueado |

**Ajuste de front en todas:** usar `BackofficeSidebar`; cambiar el campo único `estado` por `direction`+`status`; recibir el `id` real por argumento (hoy `'demo'`); cumplir GA-03 del PRD (ninguna pantalla con datos dummy).

## 8. Criterios de aceptación

**Módulo A**

| ID | Criterio |
|---|---|
| PF-01 | El saldo de `GET …/points/` = suma del libro de movimientos |
| PF-02 | Un ajuste crea un `PointsMovement` y actualiza buckets en la misma transacción |
| PF-03 | Repetir con el mismo `Idempotency-Key` no duplica el ajuste |
| PF-04 | Ajuste sin `reason_text` o sin `audit_reference` → `400` |
| PF-05 | No-Super-Admin → `403` en todos los endpoints del Módulo A |
| PF-06 | Todo ajuste aparece en el audit-log del usuario con actor y motivo |
| PF-07 | La reversión crea asiento invertido; el original permanece |
| PF-08 | `reject` con `revoke_points:true` retira los puntos de esa contribución |
| PF-09 | Dos ajustes concurrentes no corrompen el saldo |
| PF-10 | No existe ruta que borre un `PointsMovement` |
| PF-11 | Editar la config guarda valor anterior/nuevo y **no** afecta a movimientos pasados |

**Módulo B** (aplican al desbloquearse)

| ID | Criterio |
|---|---|
| PP-01 | La cola filtra por motivo, estado, riesgo e impacto económico |
| PP-02 | El expediente muestra el timeline completo de `OperationEvent` |
| PP-03 | Una resolución registra quién, cuándo y bajo qué política |
| PP-04 | Un reembolso confirmado por webhook deja `estado_economico=reembolsada` |
| PP-05 | Los webhooks de Stripe son idempotentes ante reenvíos |
| PP-06 | Una restricción registra causa, alcance, duración y responsable |

## 9. Decisiones abiertas que bloquean

| ID | Decisión | Impacto |
|---|---|---|
| ~~**D1**~~ | ~~¿El saldo puede quedar negativo?~~ | **RESUELTO:** el saldo **no** puede quedar negativo. Ajuste que lo dejaría negativo → `409 INSUFFICIENT_POINTS`; canje sin saldo suficiente → bloqueado con *"Te faltan N puntos"*. |
| **D2** | ¿Qué buckets admiten ajuste (`disponible`/`pendiente`/`bloqueado`)? | Define el parámetro `bucket` |
| **D3** ⚠️ | **A verificar por backend:** ¿existe ya un job/cron de caducidad de puntos? | Sin él, `expirado` siempre será 0 (CP-11). Si no existe, hay que crearlo |
| **D4** ⚠️ | **A verificar por backend:** ¿la lógica de ganancia de puntos ya existe y lee de config, o está hardcodeada / no existe? | Determina si ADM-PT-01 es "cablear", "refactor" o "construir desde cero" |
| **D5** | **Módulo B:** aprobación de negocio de PN-01…PN-16 | Bloquea todo el parking |
| **D6** | **Módulo B:** arquitectura de Stripe Connect (quién cobra, comisiones, chargebacks) | Bloquea PA-02/PA-03 |
| **D7** | **Módulo B:** validación legal del objeto de la compensación | Bloquea el lanzamiento |
| **D8** | ¿El superadmin publica "parking privado de cobro"? (no está en las historias) | Si es real, requiere decisión propia |

## 10. Plan de entrega

1. **Fase 1 — Backend ✅ HECHO:** saldo, movimientos, ajuste+reversión, config, `revoke_points`. En vivo desde 2026-07-25.
2. **Fase 2 — Frontend (pendiente):** cablear las pantallas de Hernan a los endpoints (modelos + repositorio + controllers). Ver §12.
3. **Fase 3 — Verificar:** D3 (job de caducidad) y D4 (lógica de ganancia lee config) las confirma backend.
4. **Fase 4 — Bloqueada:** Módulo B (aparcamiento). Requiere D5, D6, D7.

## 12. Cableado del frontend (pendiente)

| Pieza | Trabajo |
|---|---|
| `ApiConfig` | Añadir rutas: `adminUserPoints(id)`, `adminUserPointsMovements(id)`, `adminUserPointsAdjust(id)`, `adminPointsAdjustReverse(mid)`, `adminPointsConfig` |
| Modelos | `PointsBalance`, `PointsMovement`, `PointsConfig` (settings + rules) |
| Repositorio | `PointsAdminRepository` (o métodos en marketplace_repository): fetchBalance, fetchMovements (paginado+filtros), adjust (con Idempotency-Key), reverse, getConfig, putConfig |
| Wallet + Movimientos | Reemplazar mocks. **Requiere un `user_id`** → ver decisión de UX abajo |
| Modal de ajuste | Crear la UI (importe, motivo, ticket) + manejo de `409 INSUFFICIENT_POINTS` (`needed/available`) e idempotencia |
| Configuración de puntos | Remapear campos planos → `{settings, rules}` |
| Moderación | Añadir `revoke_points:true` al `reject` |

**Decisión de UX pendiente:** las pantallas Wallet y Movimientos son **por usuario**, pero la maqueta de Hernan no tiene selector. Hay que decidir cómo llega el superadmin a la wallet de un usuario: (a) desde la **ficha de usuario** existente (`/admin/users/detail`) con pestañas de Puntos/Movimientos, o (b) un **buscador de usuario** al entrar en la pantalla Wallet.

## 11. Ubicación

Este documento vive en el repo **Frontend** (= backoffice, `d:\Frontend`), junto a `PRD_panel_admin.md` y `docs/screens/06-general-admin-backoffice.md`.
