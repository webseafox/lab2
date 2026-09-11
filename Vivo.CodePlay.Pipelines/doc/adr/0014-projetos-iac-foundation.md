# 14. Projetos de Fundação para Service Connections de IaC

Date: 2026-06-05

## Status

Accepted

## Context

As Service Connections estruturantes de Infrastructure as Code (IaC) eram originalmente criadas no projeto "DevOps" do Azure DevOps e compartilhadas com os projetos "IAC - <SIGLA>" conforme eles fossem sendo criados.

O projeto "DevOps" apresenta uma superfície de ataque ampla devido ao elevado número de acessos, pois é onde ficam hospedados os repositórios compartilhados (Vivo Core Pipelines e CodePlay Framework, entre outros) acessíveis por membros de diversos times e projetos da organização.

Essa configuração apresenta os seguintes problemas:

1. **Princípio do Menor Privilégio Violado**: Usuários com acesso ao projeto "DevOps" para trabalhar com repositórios compartilhados têm visibilidade indevida sobre Service Connections críticas de infraestrutura.

2. **Risco de Segurança Elevado**: Service Connections contêm credenciais e service principals com permissões amplas em ambientes de produção. A exposição no projeto "DevOps" aumenta o risco de uso indevido ou comprometimento.

3. **Dificuldade de Auditoria**: Com muitos usuários tendo acesso ao projeto, torna-se complexo rastrear e auditar quem tem acesso real às credenciais de infraestrutura.

4. **Governança Inconsistente**: A gestão de acessos a Service Connections críticas estava misturada com a gestão de acessos a repositórios de código, dificultando a aplicação de políticas de segurança diferenciadas.

## Decision

Decidimos concentrar Service Connections estruturantes em projetos dedicados de fundação com acesso restrito exclusivamente às pessoas que de fato mantêm essas service connections e as credenciais utilizadas por elas.

Foram criados os seguintes projetos de fundação:

### IAC - FOUNDATION
- **URL**: https://dev.azure.com/telefonica-vivo-brasil/IAC%20-%20FOUNDATION
- **Propósito**: Centralizar Service Connections fundacionais de IaC
- **Acesso**: Restrito ao time de Plataforma Cloud, Cloud Engineering e DevOps
- **Conteúdo**: Service Connections para Azure Resource Manager, provisionamento de infraestrutura base, e acesso a recursos compartilhados

### IAC - 4P AKS FOUNDATION
- **URL**: https://dev.azure.com/telefonica-vivo-brasil/IAC%20-%204P%20AKS%20FOUNDATION
- **Propósito**: Centralizar Service Connections de acesso aos clusters AKS da 4P
- **Acesso**: Restrito ao time de Plataforma Cloud e DevOps
- **Conteúdo**: Service Connections de Kubernetes para clusters AKS da 4P

### Estratégia de Compartilhamento

As Service Connections desses projetos de fundação são compartilhadas com os projetos "IAC - <SIGLA>", garantindo que:

1. Apenas pipelines autorizados possam utilizar as connections
2. O acesso às credenciais permanece restrito ao projeto de fundação
3. Logs de uso são centralizados e auditáveis
4. Aprovações podem ser configuradas quando necessário

## Consequences

### Positivas

1. **Segurança Aprimorada**: Redução significativa da superfície de ataque ao limitar o acesso às Service Connections críticas apenas aos times responsáveis por sua manutenção.

2. **Princípio do Menor Privilégio**: Desenvolvedores e usuários gerais do projeto "DevOps" não têm mais visibilidade sobre credenciais de infraestrutura que não precisam para seu trabalho.

3. **Auditoria Simplificada**: Facilita a identificação de quem tem acesso a credenciais críticas e a auditoria de uso das Service Connections.

4. **Governança Fortalecida**: Permite aplicar políticas de segurança e compliance específicas para Service Connections de infraestrutura, separadas das políticas de repositórios de código.

5. **Segregação de Responsabilidades**: Clara separação entre times que mantêm infraestrutura e times que consomem a infraestrutura.

6. **Facilita Compliance**: Atende requisitos de frameworks de segurança (ISO 27001, SOC 2) que exigem segregação de acessos a ambientes produtivos.

### Negativas

1. **Complexidade Inicial**: Requer migração de Service Connections existentes e atualização de automações/processos que as referenciam.

2. **Overhead de Gerenciamento**: Introduz novos projetos que precisam ser gerenciados e mantidos.

3. **Curva de Aprendizado**: Times precisam entender a nova estrutura e processo de compartilhamento de Service Connections.

### Mitigações

1. **Documentação Clara**: Documentar o processo de solicitação e uso de Service Connections dos projetos de fundação.

2. **Automação**: Criar scripts e processos automatizados para facilitar o compartilhamento de Service Connections com novos projetos IaC.

3. **Comunicação**: Realizar sessões de alinhamento com times de IaC sobre a nova estrutura e benefícios.

4. **Período de Transição**: Manter Service Connections antigas temporariamente durante a migração para evitar quebras em pipelines existentes.

