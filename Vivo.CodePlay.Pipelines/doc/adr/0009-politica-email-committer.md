# 9. Política de Validação de E-mail do Committer

Date: 2026-05-12

## Status

Accepted

## Context

As organizações Azure DevOps da Telefônica (Preprod e Prod) hospedam centenas de projetos com contribuições de diferentes times. Sem uma regra de governança, commits podiam ser realizados com qualquer e-mail configurado localmente na máquina do desenvolvedor ou no agente de build — incluindo:

- E-mails pessoais (`gmail.com`, `hotmail.com`, etc.)
- E-mails de contas externas ou de fornecedores


A política é uma **repository policy** configurada a nível de repositório. A validação ocorre **no push**: commits com `author.email` fora do padrão são rejeitados diretamente pelo servidor

## Beneficios
- Evitar commits "anônimos" ou genéricos — Impedir e-mails como user@localhost, noreply@github.com ou configurações incorretas do Git local.
- Rastreabilidade e auditoria — Garantir que todo commit possa ser associado a um colaborador legítimo da organização (ex: exigir @empresa.com).
- Consistência no histórico do repositório — Evitar que desenvolvedores acidentalmente commitem com um e-mail de uso pessoal em vez do corporativo.

## Decision

Aplicar a política nativa do Azure DevOps **"Commit author email validation"** em **todos os projetos** das organizações Preprod e Prod, configurada com o padrão:

```
*@telefonicati.onmicrosoft.com
```

### Características da política

| Atributo | Valor |
|----------|-------|
| Tipo | Commit author email validation |
| Padrão de e-mail | `*@telefonicati.onmicrosoft.com` |
| Escopo | Todos os repositórios de cada projeto |
| Modo | Bloqueante — impede a conclusão do PR se violada |
| Organizações | Preprod e Prod |


## Como isso afeta os times

### Desenvolvedores

Todo desenvolvedor que contribui com código nos repositórios da Telefônica precisa garantir que o Git local esteja configurado com o e-mail corporativo:

```bash
# Verificar configuração atual
git config user.email

# Configurar e-mail correto (globalmente)
git config --global user.email "seu.nome@telefonicati.onmicrosoft.com"
```

A política é uma **repository policy** configurada a nível de repositório. A validação ocorre **no push**: commits com `author.email` fora do padrão são rejeitados diretamente pelo servidor.

### Pipelines de CI/CD (Core e CodePlay)

Pipelines que realizam commits automáticos (ex: bump de versão, geração de changelogs, atualização de manifests) devem configurar a identidade Git do agente antes do step de commit:

```yaml
- script: |
    git config user.email "devops-automation@telefonicati.onmicrosoft.com"
    git config user.name "DevOps Automation"
  displayName: 'Configurar identidade Git do agente'
```

### Agentes de build self-hosted

O usuário de sistema que executa o agente deve ter o `.gitconfig` global configurado:

```bash
git config --global user.email "devops-automation@telefonicati.onmicrosoft.com"
git config --global user.name "DevOps Automation"
```

---

## Consequences

### Positivas

- **Rastreabilidade garantida**: cada commit é atribuído a uma conta corporativa ativa
- **Compliance**: atende aos requisitos de auditoria e governança da organização
- **Segurança**: elimina contribuições anônimas ou de contas externas não autorizadas
- **Padronização**: todos os projetos seguem a mesma regra, sem exceções por esquecimento
- **Novos projetos**: a politica vai ser implementada pela API setup 

### Negativas / Pontos de atenção

- **Curva de adaptação**: desenvolvedores com configuração errada no Git local terão Commits/Pushe bloqueados até corrigirem
- **Pipelines legados**: pipelines que fazem commits sem configurar `user.email` precisarão ser atualizados

### Ações necessárias pelos times

1. Verificar e atualizar a configuração de `user.email` em máquinas locais
2. Atualizar pipelines que realizam commits automáticos
3. Configurar agentes self-hosted com a identidade correta


## Referências

- [Erro conhecido: E-mail do committer inválido](https://dev.azure.com/telefonica-vivo-brasil/DVPS%20-%20DEVOPS/_git/Vivo.CodePlay.Portal?path=/code/erros-conhecidos/erro-email-committer-invalido.md&version=GBadr-policy-commiter-erro&_a=preview)
- [Azure DevOps — Commit author email validation policy](https://learn.microsoft.com/en-us/azure/devops/repos/git/repository-settings?view=azure-devops&tabs=browser)
- Script de aplicação: `Set-CommitterEmailPolicy.ps1`
