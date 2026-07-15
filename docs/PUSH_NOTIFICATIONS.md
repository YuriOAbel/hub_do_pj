# Push notifications & in-app inbox

How to send FCM so the app persists the notification, shows the unread badge, and opens the right screen.

## Behavior summary

1. **Every FCM delivery** (foreground, background, or terminated) is saved to the local inbox (`SharedPreferences` key `notification_inbox_key`).
2. Unread items show a **purple dot** next to the list row and on the home bell.
3. Opening a notification (system tray, foreground local banner, or inbox tap) **marks it read** and **navigates**.
4. Navigation uses `data.type` defaults, or an explicit `data.route` when present (non-http).

## Topics

| Topic | When |
|---|---|
| `geral` | Subscribed on every app launch |
| `restricao` | After user engages restriction waitlist (`NotAvailableScreen` origin containing `restricao`) |

## Data payload contract

Always send a `data` map (even when using the `notification` title/body block). Recommended fields:

| Key | Required | Description |
|---|---|---|
| `type` | Recommended | Flow selector — see table below |
| `title` | Soft | Inbox title if `notification.title` is missing (data-only messages) |
| `body` | Soft | Inbox body if `notification.body` is missing |
| `route` | Optional | Named route override (e.g. `/cnd/orders`). Wins over type default when set and not `http*` |
| `url` | Legacy | Same as `route` when `type=url` (http URLs are ignored by the app) |
| `product_kind` | Optional | Extra args for `/cnd/request` or origin for `/not-available` |
| `tag` | Legacy | `notif_premium` → treated as `type=premium` → `/paywall` |

Stable ids come from FCM `messageId` when available.

## Types → routes

| `type` | Default route | Arguments |
|---|---|---|
| `content` | `/notification-content` | `NotificationContentArgs(title, body)` |
| `cnd` | `/cnd/orders` | — |
| `monitoramento` | `/not-available` | `'monitorar'` |
| `restricao` | `/cnd/request` | `CndRequestEntryArgs(productKind: 'restricao')` |
| `protesto` | `/cnd/request` | `CndRequestEntryArgs(productKind: 'protesto')` |
| `score` | `/company-score` | — |
| `premium` | `/paywall` | — |

If `route` is set, the app pushes that route and still applies args when the route is `/notification-content`, `/cnd/request`, or `/not-available`.

### App named routes used by notifications

| Constant | Path |
|---|---|
| `AppRoutes.notificationContent` | `/notification-content` |
| `AppRoutes.notifications` | `/notifications` (inbox UI only) |
| `AppRoutes.cndOrders` | `/cnd/orders` |
| `AppRoutes.cndRequest` | `/cnd/request` |
| `AppRoutes.notAvailable` | `/not-available` |
| `AppRoutes.companyScore` | `/company-score` |
| `AppRoutes.paywall` | `/paywall` |

## Example payloads (Firebase Console / Admin SDK)

### Content (title + body detail screen)

```json
{
  "notification": {
    "title": "Novidade no Hub do PJ",
    "body": "Confira o que mudou neste mês."
  },
  "data": {
    "type": "content",
    "title": "Novidade no Hub do PJ",
    "body": "Confira o que mudou neste mês."
  }
}
```

Open → `/notification-content` with title/body.

### CND

```json
{
  "notification": {
    "title": "Certidão pronta",
    "body": "Sua CND federal já está disponível."
  },
  "data": {
    "type": "cnd"
  }
}
```

Open → `/cnd/orders`.

Optional override:

```json
{
  "data": {
    "type": "cnd",
    "route": "/cnd/orders"
  }
}
```

### Score

```json
{
  "notification": {
    "title": "Score mensal",
    "body": "Faça o score da sua empresa este mês."
  },
  "data": {
    "type": "score"
  }
}
```

Open → `/company-score`.

### Restrição

```json
{
  "notification": {
    "title": "Consulta de restrição",
    "body": "Verifique restrições cadastrais da empresa."
  },
  "data": {
    "type": "restricao",
    "product_kind": "restricao"
  }
}
```

Open → `/cnd/request` with `productKind: restricao`.

### Protesto

```json
{
  "notification": {
    "title": "Consulta de protesto",
    "body": "Veja se há protestos ativos."
  },
  "data": {
    "type": "protesto",
    "product_kind": "protesto"
  }
}
```

Open → `/cnd/request` with `productKind: protesto`.

### Monitoramento

```json
{
  "notification": {
    "title": "Monitoramento",
    "body": "Ative alertas de irregularidades."
  },
  "data": {
    "type": "monitoramento"
  }
}
```

Open → `/not-available` with origin `monitorar`.

### Premium (legado)

```json
{
  "notification": {
    "title": "Premium",
    "body": "Desbloqueie recursos ilimitados."
  },
  "data": {
    "tag": "notif_premium"
  }
}
```

or:

```json
{
  "data": {
    "type": "premium"
  }
}
```

Open → `/paywall`.

## Open paths

| Entry point | What happens |
|---|---|
| System notification tray (app background/killed) | Persist (if needed) → mark read → navigate via `type`/`route` |
| Foreground local banner tap | Mark read → navigate (payload is full inbox JSON) |
| Inbox list (`/notifications`) | Mark read → same navigation resolver |

## Implementation notes

- Inbox service: `LocalNotificationInboxService` (`lib/services/local_notification_inbox_service.dart`).
- Nav resolver: `NotificationNav.resolve` (`lib/domain/models/notification_nav.dart`).
- Background isolate saves via `firebaseMessagingBackgroundHandler`; UI refreshes on app resume and on foreground `onInboxUpdated`.
- Prefer sending both `notification` + `data` so iOS/Android show a system banner and the app receives typed fields.
- Do not rely on http `url` deep links; the navigator ignores `http*` routes.
