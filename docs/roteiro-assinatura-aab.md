# Roteiro: keystore de upload e assinatura do AAB (P01/P02)

Pré-requisito: definir o **applicationId** final (A02) ANTES do primeiro upload; ele não muda depois de publicado. Hoje ainda é `com.example.app_devocional_mobile`.

## 1. Gerar a chave de upload (uma vez, no seu PC)
```
keytool -genkey -v -keystore %USERPROFILE%\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
- Guarde o `.jks` FORA do repositório (ex.: pasta pessoal) e faça 2 cópias (gerenciador de senhas/nuvem privada + pendrive).
- Anote senha do keystore, senha da chave e alias no gerenciador de senhas. Nunca no git.
- Com **Play App Signing** (padrão), esta é só a chave de *upload*; se perder, dá para pedir reset ao Google. A chave final de distribuição fica com o Google.

## 2. `mobile/android/key.properties` (já ignorado pelo .gitignore)
```
storePassword=<senha>
keyPassword=<senha>
keyAlias=upload
storeFile=C:/Users/wand/upload-keystore.jks
```

## 3. Alterar `mobile/android/app/build.gradle.kts` (aplicar com Flutter local)
No topo do arquivo:
```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```
Dentro de `android { }`, antes de `buildTypes`:
```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String?
        keyPassword = keystoreProperties["keyPassword"] as String?
        storeFile = keystoreProperties["storeFile"]?.let { file(it) }
        storePassword = keystoreProperties["storePassword"] as String?
    }
}
```
E em `buildTypes.release`: `signingConfig = signingConfigs.getByName("release")` (no lugar do `debug`).
Também trocar `namespace` e `applicationId` pelo definido em A02 e atualizar o `google-services.json` do Firebase para o novo pacote.

## 4. Versão
`mobile/pubspec.yaml`: `version: 1.0.0+1` (nome+código). Cada upload novo exige `versionCode` maior (+2, +3…).

## 5. Gerar e conferir
```
cd mobile
flutter build appbundle --release
```
Saída: `build/app/outputs/bundle/release/app-release.aab`. Conferir assinatura: `keytool -printcert -jarfile app-release.aab` (deve mostrar o SHA-256 da chave de upload).
Registrar o SHA-1/SHA-256 no Firebase (login Google) — da chave de upload e, depois, da chave do Play App Signing (Console → Integridade do app).

## 6. Riscos
- Build release com `debug` signing é recusado pela Play.
- Mudar o applicationId depois do 1º upload = app novo.
- Firebase/Google Login falha em release se o SHA da chave de produção não estiver cadastrado.
