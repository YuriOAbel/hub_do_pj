# Google Play — policy map for this app

Source: [Central de políticas para desenvolvedores](https://play.google/intl/pt-BR/developer-content-policy/)

Map Play policy areas → concrete checks for Consulta CNPJ. Cite area names in `docs/STORE_COMPLIANCE.md`.

## Restricted content / misleading

| Area | App check |
|---|---|
| **Declarações falsas** | App must not claim to be Receita Federal / governo; disclaimer in listing + in-app |
| Impersonation | No official seals, gov colors/branding that mislead |
| Metadata | Title, short/full description, screenshots match real features |

## Monetization

| Area | App check |
|---|---|
| **Pagamentos** | Play Billing for digital subscriptions/features (via RevenueCat) |
| **Assinaturas** | Clear terms; manage/cancel via Play; restore where applicable |
| Ads | If ads added later: Families / ad policies; disclosure |

Do not unlock digital premium via PIX/Pagarme inside the Play-distributed app.

## Privacy, fraud, device abuse

| Area | App check |
|---|---|
| **Dados do usuário** | Play Console Data safety form matches reality (Analytics, Crashlytics, FCM, device ID, contacts, profile) |
| Account deletion | Provide in-app or linked web path to delete account/data; declare in Data safety |
| Permissões | Only request contacts/notifications when needed; purpose clear |
| Deceptive behavior | No dark patterns forcing purchase without disclosure |

## Financial services

| Area | App check |
|---|---|
| **Serviços financeiros** | If app shows credit cards / loans / financial product offers, complete Play financial declarations and disclosures |
| Financial products | No credit/loan/card offer screens in binary; if reintroduced, declare Play financial services |

## Spam / UX / functionality

| Area | App check |
|---|---|
| Functionality | Core CNPJ search must work; incomplete “Monitor 24/7” must not look finished |
| Spam | No duplicate apps; no misleading keywords (e.g. official gov names as primary brand) |
| User-generated content | N/A unless social/UGC added |

## Families / children

| Area | App check |
|---|---|
| Families / Designed for Families | Default: **not** for kids; target professional/general audience |
| COPPA | Do not collect child data; no kids-directed UX |

## Priority for Consulta CNPJ

1. Data safety + privacy policy URL + deletion path
2. Declarações falsas / non-government positioning
3. Play Billing for subscriptions only
4. Accurate feature claims vs NotAvailable / waitlist
5. Financial products declaration if card offers ever exposed
