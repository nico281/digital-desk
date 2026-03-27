# Ideas inspiradas en Preply

## Prioridad alta (bajo esfuerzo, alto impacto)

### 1. Email al pro cuando recibe primer mensaje
Notificar al profesional por email cuando un cliente nuevo le envia su primer mensaje.
En Preply, responder rapido a un contacto inicial hace 50x mas probable que el estudiante reserve.
- Trigger: primer Message de un client_id nuevo en una Conversation
- Enviar email con preview del mensaje + link a /conversations/:id
- No enviar en mensajes subsiguientes del mismo cliente

### 2. Primera consulta con precio especial
Permitir al profesional configurar un precio reducido para la primera sesion con un cliente nuevo.
En Preply la "trial lesson" es el primer paso del funnel de conversion.
- Agregar campo `trial_price` (nullable) en Service o Professional
- Agregar campo `trial_duration_minutes` (nullable, default: 25 min)
- Al crear booking, detectar si es el primer booking del cliente con ese profesional
- Si es el primero y hay trial configurado, aplicar precio y duracion especial
- Mostrar badge "Primera consulta $X" en el perfil y search results

### 3. Filtro anti-contacto externo en mensajes pre-booking
Prevenir que se compartan datos de contacto (tel, email, redes) antes de la primera sesion paga.
Protege el modelo de negocio evitando que se salteen la plataforma.
- Validar body del Message contra regex de: emails, telefonos, URLs, @handles
- Solo aplicar cuando la Conversation no tiene ningun Booking completado/confirmado
- Mostrar mensaje de error amigable: "Por seguridad, no se pueden compartir datos de contacto antes de la primera sesion"
- No bloquear si ya hay al menos 1 booking pago entre las partes

## Prioridad media

### 4. Sistema de favoritos
Permitir al cliente guardar profesionales favoritos. Notificar al pro cuando alguien lo guarda.
En Preply responder a un "favorito" es clave para conversion.
- Tabla `favorites`: user_id + professional_id, unique constraint
- Boton corazon en cards de search y perfil del profesional
- Notificar al pro por email (con debounce, no uno por cada fav)
- El pro puede enviar mensaje proactivo desde la notificacion
- Seccion "Favoritos" en dashboard del cliente

### 5. Subcategory ratings
En vez de un solo rating general, permitir calificar en multiples dimensiones.
Preply usa 4 subcategorias de rating en el perfil del tutor.
- Agregar campos en Review: `rating_punctuality`, `rating_communication`, `rating_quality`, `rating_value`
- Mantener `rating` como rating general (promedio o independiente)
- Mostrar breakdown en perfil del profesional con barras o estrellas por subcategoria
- Agregar promedios por subcategoria en Professional model

### 6. Notificacion por visita al perfil / booking incompleto
Avisar al pro cuando un cliente visita su perfil o empieza un booking sin completarlo.
En Preply esto aumenta 20x la probabilidad de conversion.
- Trackear visitas a /professionals/:id (solo de usuarios logueados)
- Detectar bookings abandonados (sesion con pending_booking que expira)
- Notificar al pro con email resumido (daily digest, no en tiempo real)
- Incluir CTA para que el pro envie mensaje al potencial cliente

## Prioridad baja (nice to have)

### 7. Respuesta rapida del pro (templates)
Permitir al pro guardar mensajes predefinidos para responder rapido a consultas comunes.
- Tabla `message_templates`: professional_id, title, body
- Selector de templates en el chat form
- El pro puede crear/editar desde su panel

### 8. Indicador de tiempo de respuesta
Mostrar en el perfil del profesional cuanto tarda en promedio en responder mensajes.
- Calcular promedio de tiempo entre primer mensaje del cliente y primera respuesta del pro
- Mostrar badge: "Responde en menos de 1 hora" / "Responde en menos de 24h"
- Incentivar respuestas rapidas (factor en ranking de search)

### 9. Status online/offline del profesional
Mostrar si el profesional esta conectado o cuando fue su ultima actividad.
- Actualizar `last_seen_at` en User en cada request autenticado
- Mostrar indicador verde/gris en avatar
- "Activo hace X minutos" en perfil y chat
