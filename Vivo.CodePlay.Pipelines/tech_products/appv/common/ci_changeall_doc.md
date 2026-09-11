# Pipeline `ci_changeall.yml`

## Objetivo
Automatizar a criação ou atualização de múltiplas variáveis em grupos de variáveis (Variable Groups) de um projeto Azure DevOps, permitindo:
- Execução única (apenas um grupo específico)
- Execução massiva (vários grupos filtrados por categoria)
- Suporte a múltiplas variáveis em uma única execução
- Modo de simulação (dry-run) sem aplicar alterações

## Arquivo da Pipeline
Local: `tech_products/appv/common/scripts/ci_changeall.yml`

## Pré-requisitos
1. Grupo de variáveis contendo o PAT: `edit-library`
2. Variável secreta nesse grupo: `AZURE_DEVOPS_PAT` com permissões para Variable Groups (Read & Manage)
3. Projeto(s) existentes: "APPV - APP VIVO" ou "FRBR - FRAMEWORK BRASIL"
4. Grupos de variáveis seguem convenção iniciando com `src` (exceto quando categoria = `todos`)

---
## Parâmetros
| Parâmetro | Tipo | Obrigatório | Default | Valores | Descrição |
|-----------|------|-------------|---------|---------|-----------|
| `projectName` | string | MASSIVO | "" | APPV - APP VIVO, FRBR - FRAMEWORK BRASIL | Nome exato do projeto (apenas modo massivo) |
| `variableChange` | string | Sim | "" | livre | Lista de pares `CHAVE:VALOR` separados por vírgula ou ponto-e-vírgula |
| `specificRepository` | string | UNICO | "" | livre | Nome do grupo de variáveis alvo (deve começar com `src`) |
| `dryRun` | boolean | Não | true | true / false | Simulação: não aplica alterações, apenas mostra comandos |
| `executionMode` | string | Sim | MASSIVO | MASSIVO / UNICO | Define o modo base. Pode ser sobrescrito por `groupCategory=unico` |
| `groupCategory` | string | Sim | todos | bff / front / ms / todos / unico | Filtro de grupos ou força execução única |
|
| `groupCategory` valores: |
| Valor | Efeito no Modo MASSIVO |
|-------|-----------------------|
| `bff` | Grupos que começam com `src` e contêm `bff` |
| `front` | Grupos que começam com `src` e contêm `front` |
| `ms` | Grupos que começam com `src` e contêm `-ms` |
| `todos` | Todos os grupos (sem filtro de prefixo) |
| `unico` | Força modo único usando `specificRepository` |

### Precedência entre `executionMode` e `groupCategory`
1. Se `groupCategory = unico`, o modo é forçado para UNICO, ignorando `executionMode`.
2. Se o modo final for UNICO, apenas `specificRepository` é usado (precisa começar com `src`).
3. Se o modo final for MASSIVO, aplica o filtro de acordo com `groupCategory`.

---
## Formato de `variableChange`
Aceita múltiplos pares `CHAVE:VALOR` separados por vírgula ou ponto-e-vírgula:
```
NODE_VERSION:20.x,JAVA_VERSION:17;FEATURE_FLAG:true;API_URL:https://example.com
```
Regras:
- Cada entrada deve conter ao menos um `:` separando chave de valor.
- Valores podem conter `:` adicionais (apenas o primeiro separa chave).
- Espaços ao redor de chaves e valores são ignorados.
- Se qualquer par estiver inválido (sem `:` ou chave/valor vazios) a pipeline falha.

### Exemplo mínimo
```
variableChange: NODE_VERSION:18.x
```
### Exemplo múltiplo
```
variableChange: NODE_VERSION:20.x,JAVA_VERSION:17,FEATURE_FLAG:true
```

---
## Comportamento por Modo
### Modo UNICO
- Requer: `specificRepository` preenchido e iniciando com `src`.
- Atualiza/cria todas as variáveis dos pares somente neste grupo.
- Se uma variável não existe → cria.
- Se existe → atualiza.

### Modo MASSIVO
- Requer: `projectName` válido.
- Lista grupos de variáveis do projeto e aplica filtro da `groupCategory`:
  - `bff`: `startswith(src)` AND `contains(bff)`
  - `front`: `startswith(src)` AND `contains(front)`
  - `ms`: `startswith(src)` AND `contains(-ms)`
  - `todos`: todos os grupos (sem filtro)
  - fallback (qualquer outro): `startswith(src)`
- Aplica criação/atualização de cada variável em cada grupo.

---
## Dry-Run
Quando `dryRun = true`:
- Nenhum comando real de `az pipelines variable-group variable create/update` é executado.
- São exibidos comandos simulados com valor mascarado (`***`).
- Contadores de sucesso consideram simulações como sucesso.

Para aplicar de fato, definir `dryRun = false`.

---
## Erros e Mensagens Comuns
| Situação | Mensagem |
|----------|----------|
| `variableChange` vazio | `Parâmetro variableChange obrigatório` |
| Par sem `:` | `Entrada sem ':' => <linha>` |
| Grupo único sem prefixo `src` | `Grupo informado deve iniciar com 'src'` |
| Categoria = unico sem `specificRepository` | `Modo UNICO selecionado mas 'specificRepository' não foi informado.` |
| Nenhum grupo filtrado | `Nenhum grupo ... encontrado` (pipeline falha) |
| PAT ausente | `Variável AZURE_DEVOPS_PAT não encontrada` |

---
## Exemplo: Execução Única (dry-run)
```
executionMode: UNICO
groupCategory: unico
specificRepository: src.meu-grupo.config
variableChange: NODE_VERSION:20.x,JAVA_VERSION:17
dryRun: true
projectName: (pode deixar vazio)
```
Resultado: Mostra quais variáveis seriam criadas/atualizadas apenas em `src.meu-grupo.config`.

## Exemplo: Execução Massiva (bff real)
```
executionMode: MASSIVO
groupCategory: bff
projectName: FRBR - FRAMEWORK BRASIL
variableChange: NODE_VERSION:20.x,FEATURE_FLAG:true
dryRun: false
```
Resultado: Aplica criação/atualização nos grupos começando com `src` que contenham `bff`.

## Exemplo: Todos os grupos (simulação)
```
executionMode: MASSIVO
groupCategory: todos
projectName: APPV - APP VIVO
variableChange: NODE_VERSION:18.x;JAVA_VERSION:17;FEATURE_FLAG:true
dryRun: true
```
Resultado: Exibe todos os grupos do projeto e simula a aplicação das variáveis.

---
## Fluxo Interno Simplificado
1. Validação de parâmetros / normalização de `dryRun`.
2. Parse de múltiplos pares → arquivo `pairs.txt` (cada linha: `CHAVE:::VALOR`).
3. Determinação do modo final (força UNICO se `groupCategory=unico`).
4. Listagem de grupos segundo categoria (ou único). 
5. Loop: grupo → loop: cada par → create/update (ou simulação).
6. Resumo final com contadores.

---
## Dicas e Boas Práticas
- Faça primeiro um `dryRun = true` em massivo antes de aplicar de fato.
- Use pares agrupados logicamente (ex: versões juntas) para reduzir execuções.
- Evite duplicar a mesma chave com valores diferentes na mesma execução (último prevalece, mas pode gerar confusão nos logs).
- Para valores contendo vírgula ou ponto-e-vírgula, prefira rodar uma execução separada (atual implementação usa vírgula/; como delimitador).

---
## Possíveis Extensões Futuras
- Suporte a variáveis secretas com parâmetro adicional (ex: `secretKeys`)
- Parametrização do prefixo em vez de fixo `src`
- Case-insensitive nos filtros de categoria
- Paginação / grandes quantidades de grupos (atual depende da CLI retornar tudo)

---
## Troubleshooting
| Problema | Ação |
|----------|------|
| Não aparecem grupos esperados | Verifique `groupCategory` e se começam com `src` (para bff/front/ms) |
| Dry-run aplicou mudanças | Confirme valor logado em "Dry-run:" na task de atualização (deve ser `true`) |
| PAT inválido | Gere novo PAT com escopo: Variable Groups (Read, Manage) |
| Variável não atualiza | Checar se grupo realmente contém a variável (dry-run mostra se seria create ou update) |

---
## Execução via UI (Resumo)
1. Abrir Azure DevOps → Pipelines → selecionar `ci_changeall` → Run.
2. Preencher parâmetros conforme cenário (exemplos acima).
3. Conferir logs da primeira task (validação) para ver pares detectados.
4. Conferir listagem de grupos.
5. Em dry-run: revisar comandos simulados. Se ok, repetir com `dryRun=false`.
6. Consultar resumo final.

---
## Execução via YAML (Template) - Exemplo
Se for chamar como template (exemplo genérico):
```yaml
jobs:
- template: tech_products/appv/common/scripts/ci_changeall.yml
  parameters:
    executionMode: MASSIVO
    groupCategory: ms
    projectName: FRBR - FRAMEWORK BRASIL
    variableChange: NODE_VERSION:20.x;JAVA_VERSION:17
    dryRun: false
```

---
## Fale Conosco / Ajustes
Para incluir novos filtros ou suportar múltiplos prefixos, edite a seção de `groupCategory` no job `preparar`.

---
**Fim da documentação**
