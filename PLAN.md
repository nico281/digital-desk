# D-Desk — Plataforma de Reservas con Profesionales

## Stack

| Capa | Tecnología |
|------|------------|
| Framework | Rails 8 (full-stack) |
| Frontend | Hotwire (Turbo + Stimulus) + Tailwind CSS |
| DB | SQLite (Solid Queue, Solid Cache, Solid Cable) |
| Auth | Devise + OmniAuth (Google + email) |
| Videollamadas | LiveKit Cloud |
| Pagos | MercadoPago (API REST) |
| Background Jobs | Solid Queue |
| Real-time | Turbo Streams + ActionCable |
| Deploy | Kamal |

---

## Concepto

Plataforma donde profesionales/técnicos ofrecen servicios con reserva de turnos y videollamada integrada. Un profesional tiene UNA cuenta y puede ofrecer múltiples servicios bajo múltiples categorías (ej: un profesor puede dar Matemática, Física y Química sin crear cuentas separadas).

---

## Modelo de Datos

```
users
├── id, name, email, avatar
├── role: CLIENT | PROFESSIONAL (default CLIENT)
│   PROFESSIONAL es superset de CLIENT (puede también reservar con otros)

professionals
├── id, user_id, bio, headline
├── verified, rating_avg, rating_count

categories (jerárquico)
├── id, name, slug, parent_id (nullable)
│   Ej: "Educación" > "Matemática", "Física", "Química"

professional_categories (many-to-many)
├── professional_id, category_id

services
├── id, professional_id, title, description
├── price (neto, lo que el profesional quiere recibir)
├── duration_minutes, category_id?

availability_schedules
├── id, professional_id, day_of_week, start_time, end_time
│   Horario semanal recurrente

availability_blocks
├── id, professional_id, date, start_time, end_time
├── status: AVAILABLE | BOOKED | BLOCKED

bookings
├── id, client_id, professional_id, service_id, block_id
├── status: PENDING | CONFIRMED | COMPLETED | CANCELLED
├── payment_id, meeting_url, meeting_room_id

payments
├── id, booking_id, amount, currency, status, mp_payment_id

reviews
├── id, booking_id, client_id, professional_id
├── rating (1-5), comment, created_at

cancellation_policies
├── id, professional_id
├── free_cancel_hours_before (default 24)
├── late_cancel_refund_percent (default 0)
```

### Notas modelo
- Comisiones: constantes en código hasta que haya admin panel
- Slots de disponibilidad: generados on-the-fly desde `availability_schedules` menos bookings existentes. `availability_blocks` solo para bloqueos/excepciones manuales

---

## Comisiones — Modelo Progresivo

El profesional pone el precio NETO. El sistema suma comisiones encima. El cliente ve desglose en checkout.

| Bookings completados | Comisión plataforma |
|----------------------|---------------------|
| 0 - 10 | 0% |
| 11 - 50 | 5% |
| 51 - 150 | 7% |
| 150+ | 10% |

Comisión MP se calcula sobre el total final (no sobre el neto) para evitar cálculo circular.

---

## Auth

- Devise + OmniAuth (Google + Email con confirmación)
- Campo `role` en users (CLIENT default, PROFESSIONAL al completar setup)
- PROFESSIONAL = superset de CLIENT
- `before_action` en controllers protege rutas pro y dashboard

### Flujo
```
Registro → CLIENT → /pro/setup → completa perfil → role = PROFESSIONAL
```

---

## Timezone

- DB guarda todo en UTC
- Frontend detecta timezone del navegador
- Conversión con `Time.use_zone` en controllers
- Target inicial: LATAM (UTC-3 a UTC-6)

---

## Cancelación

- Configurable por profesional (horas mínimas para cancelar gratis)
- Default: cancelación gratis hasta 24hs antes
- Cancelación tardía: sin reembolso (o parcial según config)
- Reembolso via API refund de MercadoPago
- Profesional cancela → reembolso total siempre

---

## Videollamadas

- LiveKit Cloud (token generado server-side con SDK Ruby)
- Sala creada al confirmar pago
- Cliente y profesional se unen desde la app (Stimulus controller + LiveKit JS)

---

## Estructura

```
app/
├── controllers/
│   ├── application_controller.rb
│   ├── pages_controller.rb          # landing, home
│   ├── search_controller.rb         # búsqueda pública
│   ├── profiles_controller.rb       # perfil público profesional
│   ├── bookings_controller.rb       # crear/cancelar reservas
│   ├── dashboard_controller.rb      # dashboard general
│   ├── pro/
│   │   ├── setup_controller.rb
│   │   ├── services_controller.rb
│   │   ├── availability_controller.rb
│   │   └── bookings_controller.rb
│   └── webhooks/
│       └── mercadopago_controller.rb
├── models/
│   ├── user.rb
│   ├── professional.rb
│   ├── category.rb
│   ├── service.rb
│   ├── availability_schedule.rb
│   ├── availability_block.rb
│   ├── booking.rb
│   ├── payment.rb
│   ├── review.rb
│   └── cancellation_policy.rb
├── views/
│   ├── layouts/
│   ├── pages/
│   ├── search/
│   ├── profiles/
│   ├── bookings/
│   ├── dashboard/
│   └── pro/
├── javascript/
│   └── controllers/        # Stimulus controllers
│       ├── availability_controller.js
│       ├── booking_controller.js
│       ├── video_room_controller.js
│       └── timezone_controller.js
└── services/               # POROs
    ├── slot_generator.rb           # genera slots desde schedules
    ├── booking_creator.rb
    ├── commission_calculator.rb
    ├── mercadopago_client.rb
    └── livekit_token_generator.rb
```

---

## Fases

### Fase 1 — MVP Core
1. `rails new` con SQLite, Hotwire y Tailwind
2. Devise + OmniAuth Google
3. Perfil profesional (crear/editar, categorías, servicios)
4. Disponibilidad (horarios semanales, bloqueos manuales, generación de slots)
5. Búsqueda pública (por categoría, filtros básicos)
6. Reservas (seleccionar slot, confirmar)
7. Dashboard (próximas reservas, ambos roles)

### Fase 2 — Pagos y Video
8. MercadoPago (checkout al reservar, webhooks, refunds)
9. LiveKit (sala de video al confirmar pago)
10. Notificaciones (ActionMailer: confirmación, recordatorio via Solid Queue)

### Fase 3 — Reviews y Polish
11. Reviews post-sesión (rating 1-5 + comentario)
12. Rating promedio en perfil (Turbo Frame para carga async)
13. Página pública del profesional completa
