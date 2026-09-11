# Manual de Contribuição Flutter - Vivo+

Abaixo um resumo dos principais pipelines disponíveis neste projeto e seus parâmetros de entrada.

## 1. Pipeline Flutter App
Arquivo: `pipeline_flutter_app.yml`
Descrição: CI/CD completo para aplicações Flutter (Android e iOS), incluindo build, testes, segurança, empacotamento e deploy.

Parâmetros de entrada:
- `qa_environment` (string): ambiente de QA para deploy. Valores: `preprod`, `release`, `producao`. (default: `preprod`)
- `target` (string): plataforma alvo. Valores: `android`, `ios`, `both`. (default: `both`)
- `firebase_groups_android` (string): grupo de testadores Android no Firebase. (default: `android`)
- `firebase_groups_ios` (string): grupo de testadores iOS no Firebase. (default: `ios`)
- `skip_signing` (boolean): pular assinatura de código. Valores: `True`, `False`. (default: `False`)
- `skip_protect` (boolean): pular proteção Arxan. Valores: `True`, `False`. (default: `True`)
- `skip_promote` (boolean): pular promoção BSIM. Valores: `True`, `False`. (default: `True`)
- `use_flutter_version_latest` (boolean): usar última versão do Flutter. Valores: `True`, `False`. (default: `True`)
- `release_notes` (string): notas de release para publicação.

## 2. Pipeline Flutter Lib
Arquivo: `pipeline_flutter_lib.yml`
Descrição: Pipeline para biblioteca Flutter, incluindo bump de versão e publicação de pacotes.

Parâmetros de entrada:
- `bump_version` (string): nova versão da lib (e.g. `1.2.0`).
- `bump_message` (string): mensagem de versão (e.g. `feat: Adiciona nova API`).
- `use_flutter_version_latest` (boolean): usar última versão do Flutter. Valores: `True`, `False`. (default: `False`)

## 3. Pipeline Flutter Web
Arquivo: `pipeline_flutter_web.yml`
Descrição: CI/CD para deploy de aplicações Flutter Web, incluindo bump de versão e publicação.

Parâmetros de entrada:
- `bump_version` (string): nova versão da aplicação web.
- `bump_message` (string): mensagem de versão.
- `use_flutter_version_latest` (boolean): usar última versão do Flutter. Valores: `True`, `False`. (default: `True`)

## Pontos importantes Pipeline Flutter App

### Arxan / EnsureIT
O aplicativo Vivo+ é protegido e monitorado pelas soluções da Digital AI.

A versão android do aplicativo utiliza Arxan e a versão iOS utiliza EnsureIT
Essas soluções são armazenadas na Azure Devops utilizando Universal Pakages.
Com isso, a pipeline precisa fazer o download das ferramentas de proteção e instação e configuração nos agentes. 

Quando tiver uma nova versão dessas ferramentas, deve-se criar novo pacote e atualizar o parâmetro definition.


```bash
# Exemplo de uso do cli para criar novo pacote na Azure Devops:

    cd <<diretorio contem arquivo>>
    az login
    az artifacts universal publish --organization https://dev.azure.com/telefonica-vivo-brasil --feed devops --name EnsureIT-15.1.0.ba532f0-macosx-x64-ios-arm.dmg --version 15.1.0 --description "EnsureIT iOS X86-64 MacOS v15.1" --path .

```

```yaml
# Exemplo de uso Arxan android

    - task: DownloadPackage@1
      displayName: "Download Arxan"
      inputs:
        packageType: 'upack'
        feed: '/3d53bc62-8749-4931-ae46-a443b73bc87a'
        view: 'da88d2ff-67d7-44d6-a91b-cc4bffa5fa70'
        definition: '$(ARXAN_ARTIFACTS_DEFINITION)'
        version: '$(ARXAN_VERSION)'
        downloadPath: '$(System.DefaultWorkingDirectory)'

    - task: ExtractFiles@1        
      displayName: 'Extract Arxan'
      inputs:
        archiveFilePatterns: '$(System.DefaultWorkingDirectory)/$(ARXAN_PACKAGE_FILENAME)'
        destinationFolder: '$(System.DefaultWorkingDirectory)/protect-android'
        cleanDestinationFolder: false
        overwriteExistingFiles: true   
...
    - task: Bash@3
      displayName: Protect Android
      inputs:
        targetType: 'inline'
        script: |             
          $(System.DefaultWorkingDirectory)/protect-android/protect-android-5.6.1-linux-cb0ec448/bin/protect-android -b $(Build.SourcesDirectory)/$(BLUEPRINT_PATH) -i $(DEFAULT_WORKDIR_ARTIFACTS)/$(APP_FILE_NAME_ANDROID).apk -o $(Build.SourcesDirectory)/build/app/outputs/flutter-apk
      env:
        LICENSE_TOKEN: "$(ARXAN_LICENSE_TOKEN)"
        ANDROID_HOME: "$(ANDROID_HOME)"
        ANDROID_SDK_ROOT: "$(ANDROID_HOME)"

```

```yaml
# Exemplo de uso EnsureIT android

    - task: DownloadPackage@1
      displayName: 'Download EnsureIT x86-64'
      inputs:
        packageType: 'upack'
        feed: '/3d53bc62-8749-4931-ae46-a443b73bc87a'
        view: 'da88d2ff-67d7-44d6-a91b-cc4bffa5fa70'
        definition: 'dceabad7-5f93-45a7-953c-6a76e95f8c95'
        version: '15.1.0'
        downloadPath: '$(System.ArtifactsDirectory)'

    - task: Bash@3
      displayName: 'Descompactar arquivo EnsureIT'
      inputs:
        targetType: 'inline'
        script: |      
        echo "##[debug]Descompactando arquivo DMG..."
        hdiutil attach $(System.ArtifactsDirectory)/ensureit-15.1.0.ba532f0-macosx-x64-ios-arm.dmg -mountpoint /Volumes/EnsureIT
        cp -R /Volumes/EnsureIT/EnsureIT-15.1.0.ba532f0-macosx-x64-ios-arm.app $(System.ArtifactsDirectory)/EnsureIT
        hdiutil detach /Volumes/EnsureIT
        echo "##[debug]Arquivo DMG descompactado com sucesso!"

    - task: Bash@3
      displayName: Config Ensure IT
      inputs:
        targetType: 'inline'
        script: |           
        # source
        echo "##[debug]EnsureIT setenv..."
        source $(System.ArtifactsDirectory)/EnsureIT/Contents/EnsureIT/bin/setenv.sh
        
        # Check if EnsureIT is properly configured
        echo "##[debug]EnsureIT version details:"
        $(System.ArtifactsDirectory)/EnsureIT/Contents/EnsureIT/bin/ensureit --version
    env:
        LICENSE_TOKEN: "$(ARXAN_LICENSE_TOKEN)"

```

---

Contribuições são bem-vindas! Crie uma branch a partir de `master`, faça suas alterações e abra um Pull Request descrevendo claramente suas mudanças e testes realizados.

