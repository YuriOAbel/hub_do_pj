# Apple App Review — map for this app

Source: [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/#introduction)

Use section IDs when citing findings in `docs/STORE_COMPLIANCE.md`.

## Before You Submit

- App tested; no crashers; backends live during review
- Metadata complete; privacy URL live
- Review notes for non-obvious IAP / subscription tiers
- Contact info reachable

## 1 Safety

| Guideline | App check |
|---|---|
| 1.1 Objectionable content | Business lookup app — low risk |
| 1.1.6 False information | No fake trackers; company score must disclose estimation |
| 1.5 Developer information | Support URL + in-app contact (WhatsApp/email) |
| 1.6 Data security | Secure storage for session; HTTPS except documented ATS exception |

## 2 Performance

| Guideline | App check |
|---|---|
| **2.1 App Completeness** | Features in UI must work or clearly say “em breve”; no placeholder store URLs left as `id0000000000` in production listing |
| **2.3 Accurate Metadata** | Listing + screenshots match shipped features |
| 2.3.1 Hidden/dormant features | Document Remote Config gates; avoid promoting NotAvailable as live |
| 2.3.2 IAP in description | Premium / subscription clearly optional |
| 2.5.4 Background | Push only for intended remote-notification use |

## 3 Business

| Guideline | App check |
|---|---|
| **3.1.1 In-App Purchase** | Unlock premium / digital features via App Store IAP (RevenueCat). No license keys / external unlock for digital access |
| **3.1.2 Subscriptions** | Auto-renew disclosure before purchase; ongoing value; restore |
| 3.1.2(c) Subscription info | Price, period, what user gets (limits per tier) clear on paywall |
| 3.1.3(e) Goods outside app | Physical/out-of-app services may use other payment; do not mix as digital unlock bypass |
| 3.2.2(x) Ratings | Do not gate features on rating the app |

## 4 Design

| Guideline | App check |
|---|---|
| 4.1 Copycats / impersonation | No gov / RFB branding that implies official app |
| 4.2 Minimum functionality | Native utility beyond a thin web wrapper |
| **4.8 Login Services** | Required only if third-party social login exists; anonymous Supabase alone → N/A |

## 5 Legal / Privacy

| Guideline | App check |
|---|---|
| **5.1 Privacy** | Privacy policy URL in app + App Store Connect |
| 5.1.1 Data collection | Disclose Analytics, Crashlytics, FCM, contacts, device ID, onboarding profile |
| 5.1.1(i) Account deletion | If account created (incl. anonymous server profile) → in-app deletion path |
| 5.1.2 Permission purpose strings | Contacts (and any others) match real use |
| Government / regulated data | Clear non-official disclaimer; public data sources stated |

## Priority for Consulta CNPJ

1. Privacy URL + account deletion (5.1)
2. Completeness vs marketed features (2.1 / 2.3)
3. Subscription disclosure + IAP-only digital unlock (3.1)
4. Non-impersonation of government (4.1 + Legal)
