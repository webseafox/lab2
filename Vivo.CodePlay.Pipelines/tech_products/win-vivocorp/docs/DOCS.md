# Documentação Pipeline Win-VivoCore

## Índice de Documentação

Este diretório contém a documentação completa da pipeline Win-VivoCore, organizada para facilitar a consulta e manutenção.

### 📋 Arquivos de Documentação

| Arquivo | Descrição | Público-Alvo |
|---------|-----------|--------------|
| [README.md](./README.md) | Documentação principal da pipeline | Desenvolvedores, DevOps |
| [FLUXOS.md](./FLUXOS.md) | Diagramas e fluxos detalhados | Arquitetos, DevOps |
| [DOCS.md](./DOCS.md) | Este índice de documentação | Todos |

### 🚀 Início Rápido

1. **Primeira vez usando a pipeline?**
   - Comece com [README.md](./README.md) para entender a arquitetura

2. **Configurando uma nova pipeline?**
   - Consulte os fluxos em [FLUXOS.md](./FLUXOS.md)

3. **Problemas ou erros?**
   - Verifique os logs conforme instruções

### 📊 Visão Geral da Pipeline

A pipeline Win-VivoCore suporta dois modelos principais:

- **Deploy**: Fluxo completo de CI/CD
- **Backup**: Operações de backup e recuperação

### 🔧 Arquivos da Pipeline

```text
entrypoint.yml                   # Ponto de entrada
├── provisioner_entry.yml        # Pipeline de deploy
├── provisioner_entry_backup.yml # Pipeline de backup
├── variables/load.yml           # Configuração de variáveis
└── stages/                      # Stages organizados
    ├── default/                 # Stages de deploy
    └── backup/                  # Stages de backup
```

### 🌍 Ambientes Suportados

| Ambiente | Código | Descrição |
|----------|--------|-----------|
| Development 1 | `dev1` | Desenvolvimento |
| Quality Assurance 1 | `qa1` | Testes QA |
| Quality Assurance 2 | `qa2` | Testes QA |
| Pre-Production | `pp` | Pré-produção |
| Pre-Production Lima | `ppl` | Pré-produção Lima |
| Production New | `prod_new` | Produção Nova |
| Production | `prd` | Produção |

### 🔒 Gates de Segurança

- **Fortify**: Análise SAST
- **SonarQube**: Qualidade de código
- **Checkmarx**: Análise de segurança (opcional)
- **DependencyTrack**: Análise SCA (opcional)

### 📝 Como Contribuir

1. **Atualizando a documentação:**
   - Mantenha a consistência entre os arquivos
   - Atualize a data de modificação
   - Teste os exemplos fornecidos

2. **Reportando problemas:**
   - Documente novos problemas encontrados
   - Contribua com soluções

3. **Adicionando exemplos:**
   - Mantenha os exemplos atualizados
   - Teste antes de documentar

### 🔍 Busca Rápida

#### Por Fluxo

- **Fluxo de deploy**: [FLUXOS.md - Fluxo Principal](./FLUXOS.md#fluxo-principal-de-deploy)
- **Fluxo de backup**: [README.md - Provisioner de Backup](./README.md#2-provisioner-de-backup-provisioner_entry_backupyml)
- **Security gates**: [FLUXOS.md - Arquitetura de Security Gates](./FLUXOS.md#arquitetura-de-security-gates)

### 📞 Contatos

- **Equipe DevOps Vivo**: <devops@vivo.com>
- **Documentação Geral**: [CONTRIBUTING.md](../../CONTRIBUTING.md)
- **Guidelines**: [GUIDELINES.md](../../GUIDELINES.md)

### 📅 Histórico de Atualizações

| Data | Versão | Mudanças |
|------|--------|----------|
| 30/06/2025 | 1.0.0 | Documentação inicial completa |

### 🏷️ Tags

`#azure-devops` `#pipeline` `#vivo` `#windows` `#deploy` `#backup` `#security` `#ci-cd`

---

> Índice de documentação atualizado em: 30/06/2025
