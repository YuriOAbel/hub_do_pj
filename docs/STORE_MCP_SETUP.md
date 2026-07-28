# MCP App Store + Play Store — Setup (fase 1)

Passo a passo para criar um MCP que o Cursor usa para:

| Plataforma | Artefato | Destino (fase 1) |
|---|---|---|
| Android | `.aab` (App Bundle) | Google Play — **teste fechado** (closed testing) |
| iOS | `.ipa` | App Store Connect — **TestFlight** |

Fora do escopo desta fase: produção, metadata de listing, screenshots, review submission Apple, promoção de track Play.

---

## Visão geral

```
Cursor (Agent)
    ↓ MCP tools
store-mcp (Node/Python)
    ↓
Fastlane / google-api-python-client / asc / Transporter
    ↓
Play Developer API          App Store Connect API
(closed testing track)      (TestFlight / pilot)
```

Recomendação: o MCP **não** implementa HTTP das stores do zero. Ele chama **Fastlane** (ou CLIs oficiais) com credenciais locais. Menos código, menos bug de auth.

---

## Pré-requisitos

### Contas e apps

- [ ] Conta [Apple Developer](https://developer.apple.com) (pago) + app criado no [App Store Connect](https://appstoreconnect.apple.com)
- [ ] Conta [Google Play Console](https://play.google.com/console) + app criado (package: `com.hubdopj.consultaempresas`)
- [ ] Bundle ID iOS definido e alinhado ao App Store Connect (`com.hubdopj.consultaempresas`; ver `docs/IOS_SETUP.md`)
- [ ] Mac com Xcode (obrigatório para build/assinatura iOS)
- [ ] Flutter SDK + Android SDK instalados
- [ ] Node 20+ **ou** Python 3.11+ (para o servidor MCP)
- [ ] Ruby + Bundler (se usar Fastlane)

### Tracks / grupos já existentes

**Play — teste fechado**

1. Play Console → app → **Teste e lançamento** → **Teste fechado**
2. Criar track (ex.: `closed` / `alpha`) se ainda não existir
3. Adicionar pelo menos 1 tester (e-mail Google) e aceitar o link de opt-in

**iOS — TestFlight**

1. App Store Connect → app → **TestFlight**
2. Após o primeiro build processado, criar grupo Internal e/ou External
3. Internal: até 100 membros da equipe Apple Developer (mais rápido)
4. External: exige beta review na primeira vez

---

## 1. Credenciais Google Play

### 1.1 Service account

1. Abra [Google Cloud Console](https://console.cloud.google.com) (projeto ligado ao Play, ou crie um)
2. **IAM e administrador** → **Contas de serviço** → **Criar conta de serviço**
   - Nome sugerido: `play-upload-mcp`
3. Em **Chaves** → **Adicionar chave** → JSON → baixe o arquivo
4. Guarde fora do repo, ex.:

```text
~/.config/consulta-cnpj/play-service-account.json
```

**Nunca** committe esse JSON.

### 1.2 Vincular no Play Console

1. Play Console → **Usuários e permissões** → **Convidar novos usuários**
2. Cole o e-mail da service account (`...@....iam.gserviceaccount.com`)
3. Permissões mínimas fase 1:
   - **Ver dados do app**
   - **Gerenciar lançamentos de testes** (ou “Release to testing tracks”)
4. Aceitar / salvar

### 1.3 API habilitada

No Google Cloud do mesmo projeto:

- [ ] Ativar **Google Play Android Developer API**

Sem isso, upload via API falha com 403.

### 1.4 Variáveis de ambiente

```bash
export PLAY_PACKAGE_NAME="com.hubdopj.consultaempresas"
export PLAY_TRACK="closed"   # nome do track de teste fechado no Console
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/consulta-cnpj/play-service-account.json"
```

Confirme o nome exato do track no Play Console (pode ser `alpha`, `beta`, `closed`, etc.).

---

## 2. Credenciais App Store Connect

### 2.1 API Key (.p8)

1. [App Store Connect](https://appstoreconnect.apple.com) → **Users and Access** → **Integrations** → **App Store Connect API**
2. **Generate API Key**
   - Nome: `cursor-store-mcp`
   - Access: **App Manager** (mínimo para upload TestFlight; Admin também funciona)
3. Baixe o `.p8` **uma vez** (não dá para baixar de novo)
4. Anote:
   - **Key ID**
   - **Issuer ID** (topo da página de keys)
5. Guarde:

```text
~/.config/consulta-cnpj/AuthKey_XXXXXXXXXX.p8
```

### 2.2 Assinatura iOS (build)

Para gerar IPA assinada:

- [ ] Team ID no Xcode
- [ ] Bundle ID definitivo no `Runner`
- [ ] Distribution certificate + App Store provisioning profile  
  **ou** Fastlane Match (recomendado em time)

Sem assinatura válida, o MCP sobe nada — o build falha antes.

### 2.3 Variáveis de ambiente

```bash
export ASC_KEY_ID="XXXXXXXXXX"
export ASC_ISSUER_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export ASC_KEY_PATH="$HOME/.config/consulta-cnpj/AuthKey_XXXXXXXXXX.p8"
export ASC_APP_APPLE_ID="0000000000"   # Apple ID numérico do app no Connect
export ASC_BUNDLE_ID="com.hubdopj.consultaempresas"  # o ID real que você definir
```

O Apple ID numérico fica em App Store Connect → app → **App Information** → Apple ID.

---

## 3. Builds locais (antes do MCP)

Valide o pipeline manual uma vez. Só depois automatize.

### 3.1 Android — AAB

```bash
cd /Users/yuriabel/Documents/projetos/consulta_cnpj_new

flutter build appbundle --release
```

Saída típica:

```text
build/app/outputs/bundle/release/app-release.aab
```

Assinatura: configure `key.properties` / keystore no Android (release signing). Sem isso o AAB não sobe ou sobe com assinatura errada.

### 3.2 iOS — IPA

```bash
flutter build ipa --release \
  --export-options-plist=ios/ExportOptions.plist
```

Crie `ios/ExportOptions.plist` (exemplo App Store / TestFlight):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>app-store</string>
  <key>uploadBitcode</key>
  <false/>
  <key>compileBitcode</key>
  <false/>
  <key>signingStyle</key>
  <string>automatic</string>
  <key>teamID</key>
  <string>YOUR_TEAM_ID</string>
</dict>
</plist>
```

IPA típica:

```text
build/ios/ipa/*.ipa
```

---

## 4. Fastlane (camada recomendada sob o MCP)

Na raiz do app (ou em `android/` + `ios/`):

```bash
# uma vez
brew install fastlane   # ou gem install fastlane
cd android && fastlane init   # opcional
cd ../ios && fastlane init    # opcional
```

### 4.1 Android — lane `closed`

`android/fastlane/Fastfile` (exemplo):

```ruby
default_platform(:android)

platform :android do
  desc "Upload AAB to Play closed testing"
  lane :closed do
    aab = ENV.fetch("AAB_PATH", "../../build/app/outputs/bundle/release/app-release.aab")
    upload_to_play_store(
      track: ENV.fetch("PLAY_TRACK", "closed"),
      aab: aab,
      json_key: ENV.fetch("GOOGLE_APPLICATION_CREDENTIALS"),
      package_name: ENV.fetch("PLAY_PACKAGE_NAME"),
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
      release_status: "completed" # ou "draft" se preferir revisar no Console
    )
  end
end
```

Teste manual:

```bash
export AAB_PATH="$(pwd)/build/app/outputs/bundle/release/app-release.aab"
cd android && fastlane closed
```

### 4.2 iOS — lane `testflight`

`ios/fastlane/Fastfile` (exemplo):

```ruby
default_platform(:ios)

platform :ios do
  desc "Upload IPA to TestFlight"
  lane :beta do
    ipa = ENV.fetch("IPA_PATH")
    api_key = app_store_connect_api_key(
      key_id: ENV.fetch("ASC_KEY_ID"),
      issuer_id: ENV.fetch("ASC_ISSUER_ID"),
      key_filepath: ENV.fetch("ASC_KEY_PATH"),
      duration: 1200,
      in_house: false
    )
    upload_to_testflight(
      api_key: api_key,
      ipa: ipa,
      skip_waiting_for_build_processing: true,
      distribute_external: false
    )
  end
end
```

Teste manual:

```bash
export IPA_PATH="$(ls build/ios/ipa/*.ipa | head -1)"
cd ios && fastlane beta
```

Quando `skip_waiting_for_build_processing: true`, o build aparece no TestFlight após processamento Apple (minutos). Distribuição para o grupo Internal pode ser feita depois no Connect ou numa lane futura.

---

## 5. Criar o servidor MCP

Sugestão de pasta **fora** deste repo Flutter (evita misturar secrets/deps):

```text
~/tools/store-mcp/
  package.json          # ou pyproject.toml
  src/
    index.ts            # MCP server (stdio)
    tools/
      upload_play_closed.ts
      upload_testflight.ts
      build_android.ts    # opcional
      build_ios.ts        # opcional
  README.md
```

### 5.1 Tools mínimas (fase 1)

| Tool | Input | Comportamento |
|---|---|---|
| `upload_android_closed` | `aab_path?`, `track?`, `version_name?` | Roda `fastlane closed` (ou API Play `edits`) |
| `upload_ios_testflight` | `ipa_path?` | Roda `fastlane beta` |
| `build_android_aab` *(opcional)* | `dart_defines?` | `flutter build appbundle --release` |
| `build_ios_ipa` *(opcional)* | `dart_defines?` | `flutter build ipa --release` |
| `store_status` *(opcional)* | `platform` | Consulta último build / track |

Comece só com **upload** (builds manuais ou Agent via shell). Depois adicione tools de build.

### 5.2 Esqueleto MCP (TypeScript / `@modelcontextprotocol/sdk`)

```bash
mkdir -p ~/tools/store-mcp && cd ~/tools/store-mcp
npm init -y
npm i @modelcontextprotocol/sdk zod
npm i -D typescript tsx @types/node
npx tsc --init
```

Ideia do handler (pseudocódigo):

```ts
// upload_android_closed
spawn("fastlane", ["closed"], {
  cwd: `${REPO}/android`,
  env: { ...process.env, AAB_PATH: aabPath },
});

// upload_ios_testflight
spawn("fastlane", ["beta"], {
  cwd: `${REPO}/ios`,
  env: { ...process.env, IPA_PATH: ipaPath },
});
```

Regras de segurança no MCP:

1. Aceitar só paths **dentro** do workspace / `build/`
2. Não logar conteúdo de `.p8` / JSON da service account
3. Confirmar `track === closed` (ou allowlist) — bloquear `production` nesta fase
4. Timeout longo (upload pode passar de 5–15 min)

### 5.3 Alternativa sem Fastlane

- **Play:** `googleapis` → `androidpublisher.edits` (create edit → upload bundle → assign track `closed` → commit)
- **Apple:** `xcrun altool` / `xcrun notarytool` não cobre TestFlight moderno; use **Transporter**, **asc** CLI, ou API + `altool --upload-app` com API key

Fastlane ainda é o caminho mais curto.

---

## 6. Registrar o MCP no Cursor

Arquivo de config MCP do Cursor (UI: **Settings → MCP → Add**, ou JSON do usuário), exemplo:

```json
{
  "mcpServers": {
    "store-release": {
      "command": "npx",
      "args": ["tsx", "/Users/yuriabel/tools/store-mcp/src/index.ts"],
      "env": {
        "REPO_ROOT": "/Users/yuriabel/Documents/projetos/consulta_cnpj_new",
        "PLAY_PACKAGE_NAME": "com.hubdopj.consultaempresas",
        "PLAY_TRACK": "closed",
        "GOOGLE_APPLICATION_CREDENTIALS": "/Users/yuriabel/.config/consulta-cnpj/play-service-account.json",
        "ASC_KEY_ID": "XXXXXXXXXX",
        "ASC_ISSUER_ID": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "ASC_KEY_PATH": "/Users/yuriabel/.config/consulta-cnpj/AuthKey_XXXXXXXXXX.p8",
        "ASC_APP_APPLE_ID": "0000000000",
        "ASC_BUNDLE_ID": "com.hubdopj.consultaempresas"
      }
    }
  }
}
```

Depois:

1. Reiniciar Cursor / reload MCP
2. Confirmar tools `upload_android_closed` e `upload_ios_testflight` listadas
3. Em Agent mode, pedir:  
   *“Usa o MCP store-release e sobe o AAB atual no teste fechado”*

---

## 7. Fluxo operacional (dia a dia)

### Android → teste fechado

1. Bump `versionCode` / `versionName` em `android/app/build.gradle.kts`
2. `flutter build appbundle --release`
3. No Cursor: chamar `upload_android_closed` (path do AAB)
4. Play Console → Teste fechado → verificar release
5. Testers atualizam pelo link do track

### iOS → TestFlight

1. Bump `CFBundleShortVersionString` / `CFBundleVersion` (Xcode ou `pubspec` + flutter)
2. `flutter build ipa --release`
3. No Cursor: chamar `upload_ios_testflight`
4. App Store Connect → TestFlight → aguardar processamento
5. Adicionar build ao grupo Internal (se a lane não distribuir sozinha)

### Prompt exemplo no chat

```text
Sobe release de teste:
1) build AAB + upload closed testing
2) build IPA + upload TestFlight
Usa MCP store-release. Não publique em produção.
```

---

## 8. Checklist de aceite (fase 1)

- [ ] Service account Play sobe AAB no track fechado sem erro 403
- [ ] API Key Apple sobe IPA e build aparece em TestFlight (Processing → Ready)
- [ ] MCP expõe só tools de teste (sem `production`)
- [ ] Secrets fora do git (`~/.config/...` + env no Cursor)
- [ ] Um upload Android e um iOS feitos **via MCP** (não só Fastlane manual)
- [ ] Bundle ID iOS definitivo (não `com.example.*`)

---

## 9. Segurança

| Faça | Não faça |
|---|---|
| Keys em `~/.config` + env do MCP | Commitar `.p8` / JSON Play |
| Allowlist de tracks (`closed` only) | Tool genérica `upload(track=production)` na fase 1 |
| Paths restritos ao repo | Aceitar path absoluto arbitrário do Agent |
| Conta de serviço com permissão mínima | Dar Owner na Play / Admin Apple sem necessidade |
| Rotacionar keys se vazar | Colar secrets no chat |

Se o MCP rodar em máquina compartilhada, prefira CI (GitHub Actions) com OIDC/secrets e o MCP só **dispara workflow** — em vez de guardar `.p8` no laptop.

---

## 10. Próximas fases (não implementar agora)

1. Tool `promote_play_to_production` (com confirmação explícita)
2. Tool `submit_ios_review`
3. Sync de changelog / whatsnew a partir de `docs/STORE_LISTING.md`
4. Match (certs iOS) + CI Mac para build remoto
5. Version bump automático + tag git

---

## Referências

- [Google Play Developer API — edits](https://developers.google.com/android-publisher)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [Fastlane `upload_to_play_store`](https://docs.fastlane.tools/actions/upload_to_play_store/)
- [Fastlane `upload_to_testflight`](https://docs.fastlane.tools/actions/upload_to_testflight/)
- [Model Context Protocol](https://modelcontextprotocol.io)
- Listing deste app: [`docs/STORE_LISTING.md`](./STORE_LISTING.md)
- Setup iOS: [`docs/IOS_SETUP.md`](./IOS_SETUP.md)

---

## Ordem sugerida de execução

1. Corrigir Bundle ID iOS + signing  
2. Criar tracks/grupos (Play closed + TestFlight)  
3. Gerar credenciais Play + Apple  
4. Upload **manual** Fastlane uma vez em cada store  
5. Implementar MCP com 2 tools de upload  
6. Registrar no Cursor e validar pelo Agent  
7. Só então pensar em produção
