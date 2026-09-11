# Pipeline: Mass String Replacement in Repository Files

## Descrição

Esta pipeline permite realizar operações de **find-and-replace** em arquivos de múltiplos repositórios de forma automatizada. Ideal para alterações em massa como atualização de versões, renomeação de branches, adição de novos itens em listas YAML, etc.

---

## ⚠️ IMPORTANTE: Para Edições de YAML de Pipeline, Use yml-editor

**Se você está editando arquivos YAML de pipelines do Azure DevOps** (ex: `azure-pipelines.yml`, `app-*-ci.yml`, `app-*-cd.yml`), você deve usar **`pipeline_yml_editor.yml`** ao invés desta pipeline.

### Por Que Usar yml-editor Para Arquivos YAML?

| Problema | pipeline_replace_from_repo.yml | pipeline_yml_editor.yml |
|-------|-------------------------------|------------------------|
| **Indentação** | Contagem manual necessária, propensa a erros | Automática, gerenciada pelo `yq` |
| **Validação** | Nenhuma (pode criar YAML inválido) | Validação completa de sintaxe YAML |
| **Espaçamento** | Perdido durante edições | Preservado entre parâmetros |
| **Sincronização extends** | Manual | Automática (para parâmetros) |
| **Prevenção de duplicatas** | Não verificada | Automaticamente prevenida |
| **Curva de aprendizado** | Complexa (regex, escaping, `\n`) | Simples (formato JSON) |

### Quando Usar Qual Pipeline?

✅ **Use `pipeline_yml_editor.yml`** para:
- Adicionar/modificar parâmetros de pipeline
- Alterações estruturadas em YAML (modificar objetos aninhados, arrays)
- Quando indentação é importante
- Quando você precisa de validação
- Arquivos YAML de pipelines do Azure

✅ **Use `pipeline_replace_from_repo.yml`** (esta pipeline) para:
- Substituição simples de strings (URLs, números de versão, texto)
- Arquivos não-YAML (Markdown, JSON, scripts, arquivos de configuração)
- Edições parciais de linha (substituir parte de uma string)
- Quando você precisa de correspondência regex

**Documentação**: Veja [PIPELINE_YML_EDITOR.md](../yml-editor/PIPELINE_YML_EDITOR.md) para uso do yml-editor.

---

## Pré-requisitos

1. **PAT (Personal Access Token)** com permissões:
   - `Code (Read & Write)`
2. Ao executar a pipeline:
   - Adicionar variável `AZURE_DEVOPS_PAT` com seu token
   - Marcar **"Keep this value secret"**

---

## Parâmetros

| Parâmetro            | Tipo    | Default  | Descrição                                       |
| -------------------- | ------- | -------- | ----------------------------------------------- |
| `dryRun`             | boolean | `true`   | Simula as alterações sem aplicar                |
| `projectName`        | string  | -        | Projeto Azure DevOps                            |
| `filePath`           | string  | -        | Caminho do arquivo (ex: `/azure-pipelines.yml`) |
| `searchString`       | string  | -        | String a ser encontrada                         |
| `replaceString`      | string  | -        | String de substituição                          |
| `startsWith`         | string  | `src`    | Filtro de prefixo do repositório (`*` = todos)  |
| `endsWith`           | string  | `*`      | Filtro de sufixo do repositório (`*` = todos)   |
| `branch`             | string  | `master` | Branch alvo                                     |
| `commitMessage`      | string  | -        | Mensagem do commit (opcional)                   |
| `skipCi`             | boolean | `true`   | Adiciona `[CI SKIP]` ao commit                  |
| `specificRepository` | string  | -        | Processar apenas este repositório               |

---

## Suporte a Multiline

Use `\n` para representar quebras de linha:

```
searchString: linha1\nlinha2
replaceString: linha1\nlinha2\nlinha3
```

---

## Exemplos de Uso

### Exemplo 1: Substituição Simples

**Objetivo:** Trocar referência de branch `master` para `main`

| Parâmetro       | Valor               |
| --------------- | ------------------- |
| `searchString`  | `refs/heads/master` |
| `replaceString` | `refs/heads/main`   |

---

### Exemplo 2: Atualizar Múltiplas Linhas em Arquivo de Configuração

**Objetivo:** Atualizar configuração de conexão do banco de dados em arquivo `.env`

**Arquivo original:**

```
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=old_database
DB_USER=admin
```

| Parâmetro       | Valor                                 |
| --------------- | ------------------------------------- |
| `searchString`  | `DB_HOST=localhost\nDB_PORT=5432\nDB_NAME=old_database` |
| `replaceString` | `DB_HOST=production-db.example.com\nDB_PORT=5432\nDB_NAME=new_database` |
| `filePath`      | `.env` |
| `projectName`   | `APPV - APP VIVO` |
| `dryRun`        | `true` |

**Resultado:**

```
# Database Configuration
DB_HOST=production-db.example.com
DB_PORT=5432
DB_NAME=new_database
DB_USER=admin
```

> ⚠️ **Importante:** Use `\n` para representar quebras de linha. A pipeline substituirá por quebras de linha reais.

---

### Exemplo 3: Substituição em Scripts Shell

**Objetivo:** Atualizar caminho de instalação em script de deployment

**Arquivo original (`deploy.sh`):**

```bash
#!/bin/bash
INSTALL_PATH="/opt/old-app"
VERSION="1.0.0"
```

| Parâmetro       | Valor                                 |
| --------------- | ------------------------------------- |
| `searchString`  | `INSTALL_PATH="/opt/old-app"\nVERSION="1.0.0"` |
| `replaceString` | `INSTALL_PATH="/opt/new-app"\nVERSION="2.0.0"` |
| `filePath`      | `scripts/deploy.sh` |

**Resultado:**

```bash
#!/bin/bash
INSTALL_PATH="/opt/new-app"
VERSION="2.0.0"
```

---

### Exemplo 4: Processar Apenas Um Repositório

**Objetivo:** Testar alteração em um único repositório antes de aplicar em massa

| Parâmetro            | Valor                     |
| -------------------- | ------------------------- |
| `specificRepository` | `src.meu-repositorio-bff` |
| `dryRun`             | `true`                    |
| `searchString`       | `API_VERSION=v1`          |
| `replaceString`      | `API_VERSION=v2`          |

---

## Identificador de Execução

Cada execução gera um **EXECUTION_ID** único no formato `MASS-XXXXXX`.

```
============================================================
EXECUTION IDENTIFIER: MASS-A1B2C3
============================================================
Save this identifier to revert changes later!
Use it in pipeline 'pipeline_revert_from_repo.yml'
============================================================
```

> **Guarde este identificador!** Você precisará dele para reverter as alterações.

---

## Modo Dry-Run

Quando `dryRun = true`:

- Lista todos os repositórios que seriam afetados
- Mostra o DIFF de cada alteração
- **NÃO** cria commits

**Recomendação:** Sempre execute primeiro com `dryRun = true` para validar as alterações.

---

## Saída de Exemplo

```
============================================================
PROCESSING REPLACEMENTS
============================================================
Processing 15 repositories...

src.meu-repositorio-bff (1/15)
String found! Performing replacement...

Changes DIFF:
------------------------------------------------------------
--- a/azure-pipelines.yml (original)
+++ b/azure-pipelines.yml (modificado)
@@ -10,6 +10,7 @@
     values:
       - "dev-bff"
       - "preprod-bff"
+      - "prodlike-bff"
       - "esteira01-bff"
------------------------------------------------------------

[DRY-RUN] Changes that would be made:
  - Repository: src.meu-repositorio-bff
  - File: /azure-pipelines.yml
  - Branch: master
[DRY-RUN] Commit will NOT be created.
```

## Dicas e Boas Práticas

1. **Sempre use dry-run primeiro**

   ```
   dryRun: true
   ```

2. **Teste em um repositório específico antes**

   ```
   specificRepository: src.meu-repo-teste
   ```

3. **Verifique a indentação do YAML**

   - Conte os espaços no arquivo original
   - Use a mesma quantidade no `replaceString`

4. **Evite alterações muito amplas**

   - Use filtros `startsWith` e `endsWith` para limitar o escopo

## Reverter Alterações

Para desfazer as alterações, use a pipeline `pipeline_revert_from_repo.yml`:

```
executionId: MASS-A1B2C3
```

Consulte a documentação: [PIPELINE_REVERT_FROM_REPO.md](./PIPELINE_REVERT_FROM_REPO.md)
