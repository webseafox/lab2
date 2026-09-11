# Carta de Exceção ao Fluxo de DevOps

**Data:** 28 de Janeiro de 2026

Eu, como **Pedro Zeola Lopes**, **MLOps** da **VVIA**, estou solicitando uma exceção ao fluxo de DevOps proposto para o projeto **Modelos de Machine Learning (Automação Databricks MLOps)**.

O motivo desta solicitação é a necessidade de automação completa do ciclo de vida de modelos de Machine Learning no Databricks, incluindo autenticação e deploy de Jobs via APIs REST, garantindo padronização, governança e eliminação de etapas manuais no pipeline de CI/CD.

Estou ciente dos riscos associados a esta exceção e comprometo-me a respeitar o SLA da equipe de DevOps para casos fora do padrão, bem como implementar planos de ação para mitigar esses riscos conforme detalhado abaixo.

---

## Descrição do Projeto

O projeto **Modelos de Machine Learning** tem como objetivo padronizar e automatizar o processo de CI/CD para modelos de Machine Learning utilizando Databricks, integrando práticas de MLOps ao fluxo corporativo da Vivo.

O pipeline contempla versionamento de código, automação de deploy e governança entre ambientes DEV e PROD, reduzindo intervenção manual e riscos operacionais.

---

## Solução Proposta por DevOps

O fluxo de DevOps proposto utiliza:

- Azure DevOps para CI/CD  
- Pipelines padronizados conforme diretrizes corporativas  
- Controle de acessos e segredos via práticas recomendadas de segurança  
- Deploy automatizado seguindo os templates oficiais da plataforma  

---

## Motivo da Exceção

Para atender aos requisitos técnicos do Databricks e da automação MLOps, são necessárias as seguintes exceções ao fluxo padrão:

### 1. Geração automática de token Databricks via Service Principal (SP)

- Utilização de scripts para criação automática de token durante a execução do pipeline  
- Necessário para integração com APIs REST do Databricks  

### 2. Deploy direto de Jobs Databricks via API REST

- Criação e atualização direta de Jobs Databricks  
- Eliminação de dependência de execução manual  
- Padronização entre ambientes  
- Governança centralizada dos Jobs e pipelines de Machine Learning  

Essas necessidades não são totalmente contempladas pelo fluxo padrão de DevOps, justificando a solicitação de exceção.

---

## Riscos Identificados

- **Risco de Segurança:** Exposição indevida de tokens de acesso caso não haja controle adequado  
- **Risco Operacional:** Falhas na automação podem impactar o deploy de Jobs Databricks  
- **Risco de Governança:** Uso incorreto de APIs pode gerar inconsistência entre ambientes  

---

## Planos de Ação

Para mitigar os riscos identificados, serão adotados os seguintes controles:

- Segredos e tokens gerenciados por **Variable Groups**  
- Tokens configurados com **escopo mínimo necessário**  
- Segregação de ambientes (**DEV / PROD**)  
- Logs de execução auditáveis  
- Revisões periódicas conforme evolução do Databricks e Azure DevOps  

---

## RACI

| Atividade                          | Time de DevOps | Área Cliente (MLOps) |
|-----------------------------------|---------------|----------------------|
| Criação do pipeline personalizado | A             | R                    |
| Manutenção da automação Databricks| C             | R                    |
| Debug em casos de falhas           | C             | R                    |
| Funcionamento da infraestrutura   | R             | I                    |
| Governança e diretrizes DevOps     | A             | R                    |
| Revisão de segurança e acessos     | A             | R                    |

**R – Responsável:** Executa a atividade e garante a entrega  
**A – Aprovador:** Autoridade final e accountability  
**C – Consultado:** Contribui com conhecimento  
**I – Informado:** Mantido a par das decisões  

---

## Aprovação

[Listar os stakeholders que devem aprovar esta carta antes de prosseguir com as alterações]

- Willy Hung Hsu – MLOps – VVIA – **willy.hsu@telefonica.com**  
- Pedro Zeola Lopes – MLOps – VVIA – **plopesz@minsait.com**

---

## Revisões Futuras

Esta carta de exceção deverá ser revisada periodicamente ou sempre que houver:

- Mudanças significativas no pipeline de CI/CD  
- Alterações nas diretrizes corporativas de DevOps ou Segurança  
- Evolução relevante das plataformas Databricks ou Azure DevOps  

---
