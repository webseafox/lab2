# Pipeline de Deploy em Massa - Microfrontends SPA Vivo

Pipeline para disparar múltiplos deploys de microfrontends SPA em lote.

## Pré-requisitos

1. **PAT (Personal Access Token)** com permissões:

   - `Code (Read & Write)`
   - `Build (Read & Execute)`

2. Ao executar a pipeline:
   - Adicionar variável `AZURE_DEVOPS_PAT` com seu token
   - Marcar **"Keep this value secret"**

## Uso

### Parâmetros

| Parâmetro             | Tipo    | Obrigatório | Padrão            | Descrição                                            |
| --------------------- | ------- | ----------- | ----------------- | ---------------------------------------------------- |
| `dryRun`              | boolean | Não         | `true`            | Modo de prévia sem disparar pipelines                |
| `project`             | string  | Sim         | `APPV - APP VIVO` | Projeto de destino no Azure DevOps                   |
| `environment`         | string  | Sim         | `prodlike`        | Ambiente de destino do deploy                        |
| `deploymentList`      | object  | Sim         | `{}`              | Objeto JSON com nomes das apps e versões             |
| `skipReleaseCreation` | boolean | Não         | `false`           | Pular etapa de criação de release                    |
| `skipReleaseUpdate`   | boolean | Não         | `false`           | Pular etapa de habilitação/atualização de release    |
| `releaseEnabledFlag`  | string  | Não         | `true`            | Valor da flag de release habilitada (`true`/`false`) |

### Queue Time Variables

| Variável           | Obrigatório | Descrição                                     |
| ------------------ | ----------- | --------------------------------------------- |
| `AZURE_DEVOPS_PAT` | Sim         | PAT pessoal do executor (inserir como secret) |

### Formato da Lista de Deploy

O parâmetro `deploymentList` espera um objeto JSON onde:

- **Chave**: Nome da aplicação (sem o prefixo `src.src-`)
- **Valor**: Versão a ser deployada

```json
{
  "framework-brasil-archetype-spa-front": "1.0.121",
  "framework-brasil-dynamic-content-front": "1.0.173"
}
```

- Máximo de 10 deploys por execução
- Entradas duplicadas são automaticamente deduplicadas (primeira ocorrência mantida)
- Suporte para deploy apenas de microfrontends no mesmo projeto (`APPV - APP VIVO` ou `FRBR - FRAMEWORK BRASIL`)

### Exemplo

Para deploy de 2 SPAs em prodlike:

1. Execute a pipeline manualmente
2. Na aba **Variables**, adicione:
   - Nome: `AZURE_DEVOPS_PAT`
   - Valor: seu PAT pessoal
   - Marque: **Keep this value secret**
3. Selecione o projeto: `FRBR - FRAMEWORK BRASIL`
4. Selecione o ambiente: `prodlike`
5. Insira a lista de deploy:

```json
{
  "framework-brasil-archetype-spa-front": "1.0.121",
  "framework-brasil-dynamic-content-front": "1.0.173"
}
```

6. Clique em **Run**

### Dry Run

Habilite `dryRun` para visualizar quais pipelines seriam disparadas sem realmente executá-las. Útil para validar a lista de deploy antes de executar.

## Relatório

Após a execução, um relatório é gerado mostrando:

- Informações da execução (projeto, ambiente, data)
- Contagem de resumo (sucesso, falha, dry run, desconhecido)
- Detalhes de cada deploy com links para as pipelines disparadas
- JSON dos deploys que falharam (para fácil retry)

O relatório está disponível na aba **Extensions** da execução da pipeline.

## Retry de Deploys com Falha

Se alguns deploys falharem, o relatório inclui um bloco JSON com os itens que falharam. Copie este JSON e use como `deploymentList` em uma nova execução para retentar apenas os deploys que falharam.
