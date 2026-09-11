# 12. PIM para Administração do Azure DevOps

Date: 2026-06-05

## Status

Accepted

## Context

As plataformas DevOps são ferramentas críticas para viabilizar a resposta rápida das empresas às necessidades de seus clientes e por esse motivo são bastante visadas por atacantes internos e externos.

É imperativo aplicar conceito de mínimo privilégio possível, diminuir superfície de ataque e aumentar proteção e rastreabilidade dos acessos administrativos às organizações do Azure DevOps da Vivo.

## Decision

O grupo **Project Collection Administrator** terá seus membros reduzidos para:

- Owner da organização do Azure DevOps ou pessoa cobrindo sua ausência prolongada (férias, por exemplo)
- Pessoas e credenciais-chave indicadas pelo time de Segurança da Vivo
- Credenciais de automações do time DevOps/Plataforma que exigem esse tipo de acesso, desde que utilizando mitigações como Managed Identities do Azure
- Grupo `[TEAM FOUNDATION]\BRTLV-DEVOPS-ADMIN` com membros selecionados do time DevOps/Plataforma para acesso administrativo temporário (just-in-time) mediante aprovação via PIM (Privileged Identity Management)

**Aprovadores PIM**: Liderança executiva do time DevOps/Plataforma  
**Duração máxima**: Conforme política de segurança da Vivo (8 horas)

## Consequences

**Positivas:**
- Maior controle e rastreabilidade sobre acessos administrativos à plataforma DevOps
- Redução da superfície de ataque por meio da aplicação do princípio de menor privilégio
- Auditoria completa de todas as elevações de privilégio via logs do PIM
- Conformidade com políticas de segurança corporativa

**Negativas:**
- Pedidos de acesso administrativo estão sujeitos à disponibilidade dos aprovadores
- Necessidade de planejamento prévio para manutenções e mudanças que exigem acesso elevado
- Em situações de incidente crítico, pode haver atraso na resposta se aprovadores não estiverem disponíveis

**Mitigações:**
- Definir SLA de aprovação para incidentes críticos (SEV1/SEV2)
- Manter múltiplos aprovadores disponíveis em diferentes horários
- Documentar procedimentos de escalação em caso de indisponibilidade

## Related Decisions

- [ADR-0013](0013-pim-para-suporte-azure-devops.md) - PIM para Suporte do Azure DevOps
