# ECMC Java Pipeline Provisioners

Esta documentação descreve a estrutura dos pipelines Java criados para o ECMC, baseados na estrutura do Node.js existente.

## Estrutura Criada

### Estrutura Global
```
tech_products/ecmc/core-pipelines/provisioners/app/
├── global/
│   └── java/
│       └── variables/
│           └── init.yml                    # Variáveis globais Java/Maven
└── trunkbased/
    └── java/
        ├── api_default/                    # Pipeline para APIs Java
        │   ├── provisioner_entry.yml       # Entry point principal
        │   ├── provisioner_entry_pr.yml    # Entry point para PRs
        │   ├── variables/
        │   │   ├── load.yml                # Carregamento de variáveis
        │   │   └── override.yml            # Override de variáveis
        │   └── stages/
        │       ├── init.yml                # Inicialização
        │       ├── build_test.yml          # Build e testes
        │       ├── gates.yml               # Quality gates
        │       ├── package.yml             # Empacotamento
        │       ├── validation.yml          # Validações
        │       ├── component_test.yml      # Testes de componente
        │       ├── deploy.yml              # Deploy
        │       ├── release.yml             # Release para produção
        │       ├── validate_standards_dev_flow.yml
        │       ├── pos_validate_standards_dev_flow.yml
        │       └── security_sast_dev.yml
        └── lib_default/                    # Pipeline para bibliotecas Java
            ├── provisioner_entry.yml       # Entry point principal
            ├── provisioner_entry_pr.yml    # Entry point para PRs
            ├── variables/
            │   ├── load.yml                # Carregamento de variáveis
            │   └── override.yml            # Override de variáveis
            └── stages/
                └── init.yml                # Inicialização (outros stages similares)
```

## Características Principais

### API Default (api_default)
- **Propósito**: Pipeline completo para aplicações/APIs Java
- **Inclui**: Build, teste, empacotamento Docker, deploy Kubernetes
- **Características**:
  - Suporte a Maven como build tool
  - Integração com SonarQube
  - Análise de segurança (SAST/SCA)
  - Deploy com Helm e ArgoCD
  - Testes de componente
  - Múltiplos ambientes (dev, qa, produção)

### Lib Default (lib_default)
- **Propósito**: Pipeline para bibliotecas Java
- **Inclui**: Build, teste, empacotamento JAR, publicação Nexus
- **Características**:
  - Geração de artefatos JAR (binário, sources, javadoc)
  - Publicação no Nexus Repository
  - Versionamento automático
  - Geração de documentação
  - Verificação de licenças

## Variáveis Globais

O arquivo `global/java/variables/init.yml` contém:
- Comandos Maven padrão
- Configurações Docker
- URLs corporativas
- Configurações de cache
- Configurações SonarQube
- Configurações de segurança

## Práticas de Segurança Implementadas

### 🔒 **Gerenciamento de Secrets**
- **System.AccessToken**: Gerenciado automaticamente pelo Azure DevOps
- **Secrets**: Use Azure Key Vault ou Variable Groups
- **Tokens**: Nunca faça hardcode de tokens nos arquivos YAML

### 🛡️ **Análises de Segurança**
- **SAST**: Análise estática com Fortify
- **SCA**: Verificação de dependências vulneráveis
- **Container Security**: Scan de imagens Docker
- **License Compliance**: Verificação de licenças permitidas

### 📊 **Health Checks Robustos**
- **Retry Logic**: Configuração de tentativas e timeouts
- **Warm-up Period**: Período de aquecimento para aplicações Java
- **JVM Metrics**: Monitoramento específico para Java
- **Rollback Automático**: Em caso de falha na validação

### ⚙️ **Configuração Flexível**
- **Fallback Values**: Valores padrão para todas as configurações
- **Dynamic Variables**: Configuração baseada em ambiente
- **Override Support**: Capacidade de sobrescrever configurações

## Uso

### Para APIs Java:
```yaml
resources:
  repositories:
    - repository: CorePipelines
      name: DevOps/Vivo.Core.Pipelines
      type: git
      ref: refs/tags/v1
      endpoint: CorePipelines

extends:
  template: /tech_products/ecmc/core-pipelines/provisioners/app/trunkbased/java/api_default/provisioner_entry.yml@CorePipelines
  parameters:
    qa_environment: "qa"
    run_component_test: true
    skip_deploy: false
```

### Para Bibliotecas Java:
```yaml
resources:
  repositories:
    - repository: CorePipelines
      name: DevOps/Vivo.Core.Pipelines
      type: git
      ref: refs/tags/v1
      endpoint: CorePipelines

extends:
  template: /tech_products/ecmc/core-pipelines/provisioners/app/trunkbased/java/lib_default/provisioner_entry.yml@CorePipelines
  parameters:
    publish_to_nexus: true
    generate_documentation: true
    run_integration_tests: false
```

## Compatibilidade

Esta estrutura mantém compatibilidade com:
- Padrões existentes do ECMC
- Core Pipelines da Vivo
- Estrutura Node.js existente
- Ferramentas corporativas (SonarQube, Nexus, Fortify)

## Customização

### Variáveis Override
Use os arquivos `variables/override.yml` para customizar variáveis específicas do projeto.

### Stages Customizados
Crie stages customizados seguindo o padrão dos stages existentes e referencie-os nos provisioner_entry.yml.

## Parâmetros Principais

### API Default
- `qa_environment`: Ambiente de QA para deploy
- `run_component_test`: Executar testes de componente
- `skip_deploy`: Pular etapa de deploy
- `argocd_enabled`: Usar ArgoCD para deploy
- `runSecurityStage`: Executar análises de segurança

### Lib Default
- `publish_to_nexus`: Publicar no Nexus Repository
- `generate_documentation`: Gerar documentação Javadoc
- `run_integration_tests`: Executar testes de integração
- `autoIncrementVersion`: Incrementar versão automaticamente
