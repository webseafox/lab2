# Pipeline: Revert Mass Modifications in Repositories

## Descrição

Esta pipeline permite **reverter commits** feitos pela pipeline de replace em massa. Usa o identificador de execução (`MASS-XXXXXX`) para localizar e desfazer os commits automaticamente.

```
Commit Original:     [CI SKIP][MASS-A1B2C3] build: mass edit files
                            │
                            ▼
Commit de Revert:    [CI SKIP] revert: rollback de alterações em massa (reverts abc123)
```

## Pré-requisitos

1. **PAT (Personal Access Token)** com permissões:
   - `Code (Read & Write)`
2. **Identificador de Execução** (`MASS-XXXXXX`) da pipeline de replace

3. Ao executar a pipeline:
   - Adicionar variável `AZURE_DEVOPS_PAT` com seu token
   - Marcar **"Keep this value secret"**

---

## Parâmetros

| Parâmetro             | Tipo    | Default                           | Descrição                                      |
| --------------------- | ------- | --------------------------------- | ---------------------------------------------- |
| `dryRun`              | boolean | `true`                            | Simula a reversão sem aplicar                  |
| `projectName`         | string  | -                                 | Projeto Azure DevOps                           |
| `executionId`         | string  | -                                 | Identificador da execução (ex: `MASS-A1B2C3`)  |
| `startsWith`          | string  | `src`                             | Filtro de prefixo do repositório (`*` = todos) |
| `endsWith`            | string  | `*`                               | Filtro de sufixo do repositório (`*` = todos)  |
| `branch`              | string  | `master`                          | Branch alvo                                    |
| `revertCommitMessage` | string  | `rollback de alterações em massa` | Mensagem do commit de reversão                 |
| `skipCi`              | boolean | `true`                            | Adiciona `[CI SKIP]` ao commit                 |
| `specificRepository`  | string  | -                                 | Reverter apenas este repositório               |

---

## Como Usar

### Passo 1: Obtenha o Execution ID

O identificador é exibido durante a execução da pipeline de replace:

```
============================================================
EXECUTION IDENTIFIER: MASS-A1B2C3
============================================================
Save this identifier to revert changes later!
============================================================
```

Também está presente na **mensagem de commit** e no **nome do build**.

### Passo 2: Execute a Pipeline de Revert

| Parâmetro     | Valor                     |
| ------------- | ------------------------- |
| `executionId` | `MASS-A1B2C3`             |
| `projectName` | `FRBR - FRAMEWORK BRASIL` |
| `dryRun`      | `true` (primeiro)         |

### Passo 3: Valide o Dry-Run

Verifique os DIFFs exibidos e confirme que são as alterações corretas.

### Passo 4: Execute com Dry-Run Desativado

| Parâmetro | Valor   |
| --------- | ------- |
| `dryRun`  | `false` |

---

## Exemplos de Uso

### Exemplo 1: Reverter Todas as Alterações de uma Execução

**Cenário:** Você executou um replace em massa e precisa desfazer tudo.

| Parâmetro     | Valor                     |
| ------------- | ------------------------- |
| `executionId` | `MASS-A1B2C3`             |
| `projectName` | `FRBR - FRAMEWORK BRASIL` |
| `startsWith`  | `*`                       |
| `dryRun`      | `false`                   |

---

### Exemplo 2: Reverter Apenas em Um Repositório

**Cenário:** O replace funcionou bem na maioria, mas deu problema em um repo específico.

| Parâmetro            | Valor                          |
| -------------------- | ------------------------------ |
| `executionId`        | `MASS-A1B2C3`                  |
| `specificRepository` | `src.repositorio-com-problema` |
| `dryRun`             | `false`                        |

---

### Exemplo 3: Reverter Apenas Repos com Prefixo Específico

**Cenário:** Reverter apenas nos repositórios que começam com `src.microservico-`.

| Parâmetro     | Valor               |
| ------------- | ------------------- |
| `executionId` | `MASS-A1B2C3`       |
| `startsWith`  | `src.microservico-` |
| `dryRun`      | `false`             |

---

---

## Modo Dry-Run

Quando `dryRun = true`:

- Lista todos os commits que seriam revertidos
- Mostra o DIFF de cada reversão
- **NÃO** cria commits de revert

**Recomendação:** Sempre execute primeiro com `dryRun = true`.

---

## Saída de Exemplo

```
============================================================
PROCESSING REVERSIONS
============================================================
Processing 5 repositories...

src.meu-repositorio-bff (1/5)
Commits found to revert:
  - abc12345: [CI SKIP][MASS-A1B2C3] build: mass edit files (2024-01-15T10:30:00Z)

Reverting commit: abc12345
Original message: [CI SKIP][MASS-A1B2C3] build: mass edit files
Parent commit: def67890
Files to revert:
  - /azure-pipelines.yml (edit)

DIFF for /azure-pipelines.yml (reversion):
------------------------------------------------------------
--- a/azure-pipelines.yml (atual)
+++ b/azure-pipelines.yml (revertido)
@@ -10,7 +10,6 @@
     values:
       - "dev-bff"
       - "preprod-bff"
-      - "prodlike-bff"
       - "esteira01-bff"
------------------------------------------------------------

[DRY-RUN] Reversion that would be made:
  - Repository: src.meu-repositorio-bff
  - Commit: abc12345
  - Branch: master
[DRY-RUN] Revert commit will NOT be created.
```

---

## Dicas e Boas Práticas

1. **Sempre use dry-run primeiro**

   ```
   dryRun: true
   ```

2. **Verifique o DIFF antes de confirmar**

   - O DIFF mostra o estado "atual → revertido"
   - Confirme que é o que você espera

3. **Use filtros para reversões parciais**

   - `specificRepository` para um único repo
   - `startsWith`/`endsWith` para grupos

4. **Anote o Execution ID**
   - Mantenha um registro dos IDs de execução
   - Facilita reversões futuras

---

## Limitações

| Limitação          | Descrição                                    |
| ------------------ | -------------------------------------------- |
| Histórico          | Busca apenas nos últimos 50 commits          |
| Conflitos          | Não resolve conflitos automaticamente        |
| Múltiplos arquivos | Reverte todos os arquivos do commit original |

---
