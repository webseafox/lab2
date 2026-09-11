# 10. Alterar nível de acesso padrão para novos usuários no Azure DevOps

## Status

Proposed

## Contexto

Nossa organização do Azure DevOps (`telefonica-vivo-brasil`) está configurada com integração ao Microsoft Entra ID (antigo Azure AD). O acesso dos usuários é gerenciado através de grupos do Entra ID configurados em cada projeto.

Atualmente, a configuração "Default access level for new user" está definida como **Stakeholder**, que é um nível de acesso restrito. Isso significa que quando um usuário é adicionado à organização pela primeira vez, ele recebe apenas permissões limitadas de visualização.

Na prática, esse comportamento tem causado fricção operacional:

1. **Experiência de onboarding degradada**: Novos usuários precisam solicitar upgrade manual de permissões após serem adicionados via Dev Support
2. **Overhead administrativo**: A equipe Dev Support precisa processar solicitações recorrentes de upgrade de acesso
3. **Produtividade reduzida**: Desenvolvedores ficam bloqueados esperando permissões adequadas para começar a trabalhar

Como temos:
- Controle de acesso gerenciado via grupos do Entra ID em cada projeto
- Um microserviço que remove automaticamente usuários inativos da organização (economizando licenças)
- Processos de governança que garantem que apenas pessoas autorizadas são adicionadas aos grupos do Entra ID

O modelo de "confiança zero inicial" (Stakeholder por padrão) adiciona uma camada de segurança que é redundante com nossos controles existentes.

## Decisão

Alteraremos a configuração "Default access level for new user" na organização `telefonica-vivo-brasil` de **Stakeholder** para **Basic**.

Com essa mudança:
- Usuários adicionados à organização receberão automaticamente o nível de acesso **Basic**
- Continuaremos controlando o acesso a projetos específicos via grupos do Entra ID
- O microserviço de limpeza continuará removendo usuários inativos para otimizar licenças

## Consequências

### Positivas

- **Onboarding simplificado**: Novos membros das equipes têm acesso imediato às funcionalidades necessárias
- **Redução de overhead**: Elimina solicitações recorrentes de upgrade de permissões ao Dev Support
- **Melhor experiência de usuário**: Desenvolvedores podem começar a trabalhar imediatamente após serem adicionados aos grupos apropriados
- **Alinhamento com modelo de confiança**: Se confiamos que o usuário deve estar na organização (via Entra ID), faz sentido dar acesso adequado desde o início

### Negativas

- **Custo de licenças ligeiramente maior**: Usuários temporários ou incorretamente adicionados consumirão licenças Basic até serem removidos
  - **Mitigação**: O microserviço de limpeza de usuários inativos continua operando, minimizando o custo de usuários ociosos
- **Necessidade de governança mais rigorosa no Entra ID**: A concessão de acesso via grupos do Entra ID torna-se o único controle de entrada
  - **Mitigação**: Já temos processos de governança estabelecidos para gerenciamento de grupos do Entra ID

### Neutras

- A segurança real continua sendo gerenciada no nível de projeto através de grupos do Entra ID
- Usuários que precisam de acesso mais restrito (Stakeholder) ou mais amplo (Basic + Test Plans) ainda podem ter seus níveis ajustados individualmente quando necessário
