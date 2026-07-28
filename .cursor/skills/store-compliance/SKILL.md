---
name: store-compliance
description: >-
  Audits the app against Apple App Store Review Guidelines and Google Play
  Developer Program Policies before store submission. Produces or updates
  docs/STORE_COMPLIANCE.md with attention points and a compliance checklist.
  Use when the user asks to revisar o app, compliance, App Store, Google Play,
  envio, publicação, nova versão, store review, or checklist loja.
---

# Skill: Store compliance (Apple + Google Play)

Run this skill whenever the user requests a store compliance review or asks to
prepare / submit a new version to the App Store or Google Play.

Official sources (always cite in the report):
- [Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/#introduction)
- [Google Play — Central de políticas](https://play.google/intl/pt-BR/developer-content-policy/)

Policy detail maps (read when classifying findings):
- [apple-guidelines-map.md](apple-guidelines-map.md)
- [google-play-policy-map.md](google-play-policy-map.md)

Existing project docs (cross-link; do not duplicate setup checklists):
- `docs/APPSTORE_CHECKLIST.md`
- `docs/STORE_LISTING.md`
- `docs/IOS_SETUP.md`

---

## When to run

- User asks for compliance / store review / “revisar app para envio”
- User asks to publish or ship a new version to Apple or Google
- User names this skill explicitly

Do **not** skip writing `docs/STORE_COMPLIANCE.md`.

---

## Workflow

Copy and track:

```
Store compliance:
- [ ] 1. Read this skill + policy maps as needed
- [ ] 2. Read existing docs (APPSTORE_CHECKLIST, STORE_LISTING)
- [ ] 3. Audit code against axes below
- [ ] 4. Classify: Bloqueador / Atenção / OK
- [ ] 5. Write/update docs/STORE_COMPLIANCE.md
- [ ] 6. Summarize top blockers in chat
```

### Audit axes (mandatory)

Inspect code and configs for each axis. Cite file paths in the report.

| Axis | What to check |
|---|---|
| **Privacy / data** | Privacy + terms URLs (`LegalUrls` via `.env` / flutter_dotenv); Analytics, Crashlytics, FCM, device ID, profile fields; in-app account/data deletion; Data Safety / Nutrition Labels coverage |
| **Permissions** | `AndroidManifest.xml` + `Info.plist` usage strings vs real features; no unused dangerous permissions |
| **Payments / IAP** | Digital unlocks via store billing (RevenueCat); restore purchases; auto-renew disclosure; no external payment for digital goods; PIX/external only for physical/out-of-app services |
| **Misleading / government** | Disclaimers in-app + listing; no RFB/gov impersonation; listing copy matches shipped features |
| **Completeness** | Announced features vs `NotAvailable` / Remote Config / dead routes; crashes; placeholder URLs |
| **Subscriptions / metadata** | Paywall benefits match products; screenshots/description accuracy; support contact |
| **Age / kids** | Not Made for Kids unless intentional; no COPPA violations |
| **Financial products (Play)** | Credit/loan/card offer screens → Play financial services declarations if exposed |

### Severity

| Level | Meaning |
|---|---|
| **Bloqueador** | Likely rejection or policy violation; fix before submit |
| **Atenção** | Risk or inconsistency; fix or document in review notes |
| **OK** | Compliant or adequately mitigated |

---

## Output: `docs/STORE_COMPLIANCE.md`

Overwrite/update this single living file. Set **Última revisão** to today’s date.
Read `version` from `pubspec.yaml` and bundle/package from project config.

Use this template exactly (fill sections; keep headings):

```markdown
# Store Compliance — Consulta CNPJ

Última revisão: YYYY-MM-DD
Versão app: x.y.z+build
Bundle/package: com.hubdopj.consultaempresas

Fontes: [Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/#introduction) · [Google Play Policies](https://play.google/intl/pt-BR/developer-content-policy/)

Docs relacionados: [APPSTORE_CHECKLIST](APPSTORE_CHECKLIST.md) · [STORE_LISTING](STORE_LISTING.md) · [IOS_SETUP](IOS_SETUP.md)

## Resumo executivo

(1 parágrafo. Contagem: N bloqueadores, N atenções, N OK.)

## Pontos de atenção

### Bloqueadores

- …

### Atenção

- …

### OK / mitigado

- …

## Checklist de conformidade

### Apple App Review

- [ ] …
- [ ] …

### Google Play Policies

- [ ] …
- [ ] …

### Console / listing (manual)

- [ ] …
- [ ] …

## Evidências no código

| Achado | Path | Nota |
|---|---|---|
| … | `…` | … |

## Próximas ações

1. …
2. …
```

Checklist items must map to real policy sections (use the policy maps). Mark `[x]` only when verified in this audit; leave `[ ]` for open items.

---

## Chat summary

After writing the doc:

1. State path: `docs/STORE_COMPLIANCE.md`
2. List **Bloqueadores** (short bullets)
3. Do not implement product fixes unless the user asks

---

## Scope limits

- This skill produces **audit docs**, not product code changes.
- Setup steps already covered in `APPSTORE_CHECKLIST.md` stay there; link them under Console / listing.
- Re-run the full audit on each new version request; refresh the same markdown file.
