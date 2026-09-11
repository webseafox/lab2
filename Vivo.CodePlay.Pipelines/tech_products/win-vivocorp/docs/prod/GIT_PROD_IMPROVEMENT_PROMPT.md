# Prompt para Melhoria de Scripts Batch em Pipelines Azure DevOps

## 🎯 Objetivo
Este documento serve como guia e prompt para melhorar scripts batch (.bat) executados em pipelines do Azure DevOps, transformando scripts silenciosos em scripts verbosos, rastreáveis e debugáveis.

## 📊 Análise Comparativa: git_prod.bat vs git_prod_az.bat

### Diferenças Identificadas

#### 1. **Uso de Caminhos Absolutos vs Navegação Relativa**

**❌ ANTES (git_prod.bat):**
```batch
cd C:\Siebel_Devops\PROD\ambientes\
git clone https://$(GITUSER):$(GITPASS)@dev.azure.com/...
cd C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod
```

**✅ DEPOIS (git_prod_az.bat):**
```batch
echo Entrando no diretório de ambientes...
cd C:\Siebel_Devops\PROD\ambientes\
echo Diretório atual: %CD%

echo Clonando repositório...
git clone --tags https://svc_vcorops:TOKEN@dev.azure.com/... C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod
```

**🔑 Melhoria:** Especificação do caminho completo de destino no comando `git clone`, eliminando dependência de estar no diretório correto.

---

#### 2. **Logging Estruturado e Delimitadores Visuais**

**❌ ANTES:**
```batch
@echo off
set datetime=%date:~-4%%date:~3,2%%date:~0,2%%time:~0,2%%time:~3,2%%time:~6,2%
set "timestamp=%datetime: =0%"
rem echo %timestamp%
```

**✅ DEPOIS:**
```batch
@echo off

echo === INICIO DO SCRIPT git_prod.bat ===

set datetime=%date:~-4%%date:~3,2%%date:~0,2%%time:~0,2%%time:~3,2%%time:~6,2%
set "timestamp=%datetime: =0%"
echo Timestamp definido: %timestamp%
```

**🔑 Melhorias:**
- Delimitador visual `===` para marcar início/fim do script
- Echo de variáveis importantes logo após sua definição
- Remoção de comentários REM, substituídos por mensagens echo ativas

---

#### 3. **Mensagens Descritivas para Cada Operação**

**❌ ANTES:**
```batch
git config --system --unset http.proxy
git config --system --unset https.proxy
git config --system http.proxy http://10.240.58.39:3128
git config --system https.proxy http://10.240.58.39:3128
```

**✅ DEPOIS:**
```batch
echo Configurando Git...
git config --global credential.helper ""
git config --system --unset http.proxy
git config --system --unset https.proxy
git config --system http.proxy http://10.240.58.39:3128
git config --system https.proxy http://10.240.58.39:3128

git config --global user.email "dev.crm.b2b.br@telefonica.com"
git config --global user.name "devops_b2b-vivocorp"
set GIT_PATH="C:\Program Files\Git\bin\git.exe"
echo Configuração Git concluída
```

**🔑 Melhorias:**
- Mensagem inicial `"Configurando Git..."`
- Mensagem de conclusão `"Configuração Git concluída"`
- Adição de `git config --global credential.helper ""` para limpar cache
- Definição explícita de `GIT_PATH`

---

#### 4. **Echo do Diretório Atual após CD**

**❌ ANTES:**
```batch
cd C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod

git describe --abbrev=0 --tags > C:\Siebel_Devops\PROD\ambientes\VERSION.log
```

**✅ DEPOIS:**
```batch
cd C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod
echo Diretório atual após clone: %CD%

echo Obtendo última tag do Git...
git fetch --tags
git describe --tags --abbrev=0 --always
git describe --tags --abbrev=0 --always > "C:\Siebel_Devops\PROD\ambientes\VERSION.log" 2>&1
echo Última tag salva em VERSION.log
```

**🔑 Melhorias:**
- Echo do `%CD%` para confirmar mudança de diretório
- Mensagens antes e depois da operação
- Redirecionamento `2>&1` para capturar stderr
- Uso de aspas nos caminhos de arquivo

---

#### 5. **Redirecionamento de Saída Completo (stdout + stderr)**

**❌ ANTES:**
```batch
git describe --abbrev=0 --tags > C:\Siebel_Devops\PROD\ambientes\VERSION.log
git diff %VERSION_old% %timestamp% --name-only > C:\Siebel_Devops\PROD\ambientes\new_sifs.log
```

**✅ DEPOIS:**
```batch
git describe --tags --abbrev=0 --always > "C:\Siebel_Devops\PROD\ambientes\VERSION.log" 2>&1
echo Última tag salva em VERSION.log

git diff %VERSION_old% %timestamp% --name-only > "C:\Siebel_Devops\PROD\ambientes\new_sifs.log" 2>&1
echo Arquivos modificados salvos em new_sifs.log
```

**🔑 Melhorias:**
- Adição de `2>&1` para redirecionar stderr junto com stdout
- Mensagens de confirmação após gravação dos logs
- Uso consistente de aspas em caminhos de arquivo

---

#### 6. **Confirmação de Operações Git Críticas**

**❌ ANTES:**
```batch
git tag -a %timestamp% -m "Versionamento DevOps"
git push origin %timestamp%

git diff %VERSION_old% %timestamp% --name-only > C:\Siebel_Devops\PROD\ambientes\new_sifs.log
```

**✅ DEPOIS:**
```batch
echo Criando nova tag: %timestamp%
git tag -a %timestamp% -m "Versionamento DevOps"
git push origin %timestamp%
echo Nova tag enviada ao repositório

echo Gerando lista de arquivos modificados...
git diff %VERSION_old% %timestamp% --name-only > "C:\Siebel_Devops\PROD\ambientes\new_sifs.log" 2>&1
echo Arquivos modificados salvos em new_sifs.log
```

**🔑 Melhorias:**
- Mensagem antes da criação da tag com valor da variável
- Confirmação de push bem-sucedido
- Descrição da operação de diff

---

#### 7. **Logging Detalhado em Loops**

**❌ ANTES:**
```batch
for /f "tokens=*" %%a in (new_sifs.log) do (
echo %%a
echo F|xcopy C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod\"%%a" C:\Siebel_Devops\PROD\temp\"%%a"
echo F|xcopy C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod\"%%a" C:\Siebel_Devops\PPL\temp\"%%a" 
)
```

**✅ DEPOIS:**
```batch
echo Copiando arquivos modificados...
for /f "tokens=*" %%a in (C:\Siebel_Devops\PROD\ambientes\new_sifs.log) do (
    echo Copiando %%a para temp e PPL/temp...
    echo F|xcopy C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod\"%%a" C:\Siebel_Devops\PROD\temp\"%%a"
    echo F|xcopy C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod\"%%a" C:\Siebel_Devops\PPL\temp\"%%a"
)
echo Copia de arquivos concluída
```

**🔑 Melhorias:**
- Mensagem antes do início do loop
- Descrição do que está sendo copiado em cada iteração
- Mensagem de conclusão após o loop
- Caminho absoluto no arquivo de entrada do loop

---

#### 8. **Configuração Adicional de Git Remote**

**❌ ANTES:**
```batch
git clone https://$(GITUSER):$(GITPASS)@dev.azure.com/... C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod

cd C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod
```

**✅ DEPOIS:**
```batch
git clone --tags https://svc_vcorops:TOKEN@dev.azure.com/... C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod
git remote set-url origin https://svc_vcorops:TOKEN@dev.azure.com/...
echo Clone e configuração remota concluídos

cd C:\Siebel_Devops\PROD\ambientes\src-vivocorp-prod
echo Diretório atual após clone: %CD%
```

**🔑 Melhorias:**
- Adição de `--tags` no clone para garantir download de todas as tags
- `git remote set-url origin` para garantir URL correta após clone
- Mensagens de confirmação

---

#### 9. **Git Fetch Explícito para Tags**

**❌ ANTES:**
```batch
git describe --abbrev=0 --tags > C:\Siebel_Devops\PROD\ambientes\VERSION.log
```

**✅ DEPOIS:**
```batch
echo Obtendo última tag do Git...
git fetch --tags
git describe --tags --abbrev=0 --always
git describe --tags --abbrev=0 --always > "C:\Siebel_Devops\PROD\ambientes\VERSION.log" 2>&1
echo Última tag salva em VERSION.log
```

**🔑 Melhorias:**
- `git fetch --tags` explícito antes de descrever tags
- Execução do comando antes do redirecionamento (para ver output no console)
- Flag `--always` para fallback se não houver tags

---

## 🎓 Padrões de Melhoria Identificados

### 1. **Verbosidade Estruturada**
- ✅ Adicionar delimitadores visuais (`===`) no início e fim do script
- ✅ Incluir mensagens descritivas antes de cada operação importante
- ✅ Adicionar mensagens de confirmação após operações críticas
- ✅ Echo de variáveis importantes logo após sua definição

### 2. **Rastreabilidade de Contexto**
- ✅ Echo do diretório atual (`%CD%`) após cada `cd`
- ✅ Mensagens indicando o que está sendo processado em loops
- ✅ Logging do progresso em operações longas

### 3. **Robustez de Logging**
- ✅ Usar `2>&1` para capturar stderr junto com stdout
- ✅ Aspas em todos os caminhos de arquivo para evitar problemas com espaços
- ✅ Caminhos absolutos em vez de navegação relativa

### 4. **Configuração Explícita**
- ✅ Limpar configurações existentes antes de aplicar novas
- ✅ Definir variáveis de ambiente importantes (como `GIT_PATH`)
- ✅ Confirmar configurações de Git (remote URL, credentials)

### 5. **Debugging Facilitado**
- ✅ Separação visual de seções do script
- ✅ Mensagens que permitem identificar exatamente onde uma falha ocorreu
- ✅ Output dos comandos visível no console antes de redirecionar para arquivos

---

## 📝 Prompt para Melhorar Outros Scripts Batch

```
Analise o script batch a seguir e aplique as seguintes melhorias para torná-lo adequado para execução em pipelines Azure DevOps:

### Melhorias Obrigatórias:

1. **LOGGING ESTRUTURADO:**
   - Adicione delimitadores visuais com `echo === INICIO DO SCRIPT [nome] ===` no início
   - Adicione `echo === FIM DO SCRIPT [nome] ===` no final
   - Inclua mensagens descritivas com `echo` antes de cada operação importante
   - Adicione mensagens de confirmação após operações críticas (ex: "echo Operação X concluída")

2. **RASTREABILIDADE:**
   - Após cada comando `cd`, adicione `echo Diretório atual: %CD%`
   - Exiba o valor de variáveis importantes logo após sua definição
   - Em loops, adicione mensagens indicando o item sendo processado

3. **CAMINHOS ABSOLUTOS:**
   - Substitua navegação relativa por caminhos absolutos completos
   - Use caminhos absolutos nos comandos (ex: `git clone URL C:\caminho\completo\destino`)
   - Sempre use aspas em caminhos de arquivo para evitar problemas com espaços

4. **REDIRECIONAMENTO ROBUSTO:**
   - Adicione `2>&1` em todos os redirecionamentos para capturar stderr e stdout
   - Antes de redirecionar para arquivo, execute o comando sem redirecionamento para mostrar no console
   - Use aspas nos caminhos de arquivo de destino

5. **CONFIGURAÇÃO EXPLÍCITA:**
   - Limpe configurações existentes antes de aplicar novas (ex: `git config --global credential.helper ""`)
   - Defina variáveis de ambiente importantes explicitamente
   - Adicione comandos de validação/confirmação após configurações críticas

6. **OPERAÇÕES GIT:**
   - Use `git fetch --tags` antes de `git describe`
   - Adicione `--tags` ao comando `git clone`
   - Use `git remote set-url origin` após clone para garantir URL correta
   - Adicione flag `--always` em `git describe` como fallback

7. **MENSAGENS CONTEXTUAIS:**
   - Substitua comentários `rem` por mensagens `echo` ativas
   - Use mensagens no formato: "Operação iniciada..." → "Operação concluída"
   - Em loops, descreva o que está sendo feito com cada item

### Estrutura Recomendada:

```batch
@echo off

echo === INICIO DO SCRIPT [nome_do_script].bat ===

REM Seção 1: Inicialização
echo Inicializando variáveis...
set VAR1=valor1
echo VAR1 definido: %VAR1%
echo Inicialização concluída

REM Seção 2: Configuração
echo Configurando [componente]...
[comandos de configuração]
echo Configuração de [componente] concluída

REM Seção 3: Operação Principal
echo Executando operação principal...
cd C:\caminho\absoluto
echo Diretório atual: %CD%

echo Executando comando X...
comando > "C:\caminho\absoluto\output.log" 2>&1
echo Comando X concluído, output salvo em output.log

REM Seção 4: Limpeza
echo Realizando limpeza...
[comandos de limpeza]
echo Limpeza concluída

echo === FIM DO SCRIPT [nome_do_script].bat ===
```

Aplique estas melhorias mantendo a lógica original do script intacta.
```

---

## 🚨 Pontos de Atenção

### ⚠️ Segurança
**NOTA IMPORTANTE:** O arquivo `git_prod_az.bat` contém credenciais hardcoded, o que é uma **vulnerabilidade de segurança crítica**. 

**Recomendação:**
- Use variáveis de pipeline do Azure DevOps: `$(GITUSER)` e `$(GITPASS)`
- Ou configure credenciais via Git Credential Manager
- **NUNCA** commite credenciais em código-fonte

**Exemplo seguro:**
```batch
git clone https://$(GITUSER):$(GITPASS)@dev.azure.com/...
```

---

## 📈 Benefícios das Melhorias

### Para Debugging:
- ✅ Logs detalhados permitem identificar exatamente onde ocorreu uma falha
- ✅ Mensagens contextuais facilitam entendimento do fluxo de execução
- ✅ Echo de diretórios e variáveis previne erros de contexto

### Para Pipelines:
- ✅ Output estruturado facilita análise em logs do Azure DevOps
- ✅ Redirecionamento robusto garante captura completa de erros
- ✅ Mensagens de conclusão confirmam sucesso de cada etapa

### Para Manutenção:
- ✅ Scripts auto-documentados através de mensagens descritivas
- ✅ Seções claramente delimitadas facilitam navegação
- ✅ Padrão consistente facilita entendimento por novos desenvolvedores

---

## 🔄 Checklist de Aplicação

Ao melhorar um script batch, verifique:

- [ ] Adicionar delimitadores de início/fim (`===`)
- [ ] Echo descritivo antes de cada operação importante
- [ ] Echo de confirmação após operações críticas
- [ ] Echo do `%CD%` após cada `cd`
- [ ] Usar caminhos absolutos em comandos e navegação
- [ ] Adicionar `2>&1` em todos os redirecionamentos
- [ ] Usar aspas em todos os caminhos de arquivo
- [ ] Echo de variáveis importantes após definição
- [ ] Substituir `rem` por `echo` quando apropriado
- [ ] Adicionar mensagens em loops descrevendo iterações
- [ ] Limpar configurações antes de aplicar novas
- [ ] Validar ausência de credenciais hardcoded

---

## 📚 Referências
- Arquivo original: `tech_products/win-vivocorp/siebel_devops/paliativo/prod/git_prod.bat`
- Arquivo melhorado: `tech_products/win-vivocorp/siebel_devops/paliativo/prod/git_prod_az.bat`
- Framework: CodePlay Pipelines - Vivo
- Data de análise: 2025-10-30
