# Quickstart - CodePlay Framework

> **🚀 Comece aqui! Guia rápido para usar pipelines do CodePlay Framework**

---

## TL;DR

1. **Consulte o catálogo** → [Pipelines disponíveis](https://dvps.redecorp.azr/portal/catalog/pipelines)
2. **Leia as diretrizes** → [`GUIDELINES.md`](/GUIDELINES.md)
3. **Use um pipeline existente** ou contribua seguindo [`CONTRIBUTING.md`](/CONTRIBUTING.md)

---

## 🎯 O que é o CodePlay Framework?

O CodePlay Framework fornece **pipelines prontos para uso** que cobrem 80% dos cenários de CI/CD na Vivo.

**Princípio fundamental:**
> "Se preocupe com o desenvolvimento do código e deixe o framework cuidar da construção, garantia de qualidade, segurança e entrega do software."

---

## 📚 Onde Encontrar Informações

| Recurso | Descrição |
|---------|-----------|
| [Catálogo de Pipelines](https://dvps.redecorp.azr/portal/catalog/pipelines) | **Comece aqui!** Pipelines disponíveis |
| [Portal CodePlay](https://dvps.redecorp.azr/portal/codeplay/framework/) | Documentação completa do framework |
| [Capacidades](https://dvps.redecorp.azr/portal/codeplay/capacidades/) | Capacidades habilitadas nos pipelines |
| [`GUIDELINES.md`](/GUIDELINES.md) | Regras e padrões corporativos |
| [`CONTRIBUTING.md`](/CONTRIBUTING.md) | Como contribuir com o framework |
| [ADRs - DevOps Corporativo](/doc/adr/) | Decisões arquiteturais gerais (environments, artifacts, políticas) |
| [ADRs - Framework](/framework/docs/adr/) | Decisões específicas do framework (pipelines, stages, AppSec) |
| [Canal DevEx - Teams](https://teams.microsoft.com/l/channel/19%3A8fbd00946cf044d7a844182ac71e6aa1%40thread.tacv2/Azure%20DevOps?groupId=038b4415-d6dd-42ce-92e5-31a8e2a13bf8&tenantId=9744600e-3e04-492e-baa1-25ec245c6f10) | Suporte e comunidade DevOps |

---

## 🛠️ Como Usar um Pipeline Existente

### Passo 1: Encontre o Pipeline

Acesse o [Catálogo de Pipelines](https://dvps.redecorp.azr/portal/catalog/pipelines) e encontre o pipeline adequado para sua aplicação.

### Passo 2: Configure no seu Repositório

No repositório da sua aplicação, crie o arquivo `.azuredevops/app-<nome>-ci.yml`:

```yaml
resources:
  repositories:
    - repository: CodePlay
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: refs/heads/master

extends:
  template: /framework/pipelines/ci/<tipo>/pipeline.yaml@CodePlay
  parameters:
    # Configure os parâmetros conforme documentação do pipeline
    projectName: 'minha-aplicacao'
```

### Passo 3: Crie o Pipeline no Azure DevOps

1. Acesse Azure DevOps → Pipelines → New Pipeline
2. Selecione seu repositório
3. Aponte para o arquivo `.azuredevops/app-<nome>-ci.yml`

---

## 📂 Estrutura do Repositório

```
📂 Vivo.CodePlay.Pipelines
├── 📁 framework/           # Core do Framework
│   ├── 📁 pipelines/ci/    # Pipelines de CI (build)
│   ├── 📁 pipelines/cd/    # Pipelines de CD (deploy)
│   └── 📁 templates/       # Templates compartilhados
├── 📁 tech_products/       # Pipelines específicos por produto
├── 📁 security/            # Templates de segurança
└── 📁 examples/            # Exemplos e snippets
```

---

## ✅ Precisa Criar ou Modificar um Pipeline?

Consulte o guia completo de contribuição: [`CONTRIBUTING.md`](/CONTRIBUTING.md)

O guia cobre:
- Fluxo de decisão (framework vs tech_product)
- Como contribuir com o framework
- Como criar um tech product (exceção)
- Processo de Pull Request
- Validação obrigatória

---

## 📞 Precisa de Ajuda?

1. **Catálogo**: [Pipelines disponíveis](https://dvps.redecorp.azr/portal/catalog/pipelines)
2. **FAQ**: [`/framework/README.md`](/framework/README.md)
3. **Suporte**: [Canal DevEx - Teams](https://teams.microsoft.com/l/channel/19%3A8fbd00946cf044d7a844182ac71e6aa1%40thread.tacv2/Azure%20DevOps?groupId=038b4415-d6dd-42ce-92e5-31a8e2a13bf8&tenantId=9744600e-3e04-492e-baa1-25ec245c6f10)

---

> **💡 Dica**: Sempre prefira usar pipelines existentes do catálogo. Criar do zero deve ser a última opção!


