# 🤖 PROMPT PARA ATUALIZAÇÃO AUTOMÁTICA DE DOCUMENTAÇÃO DE PIPELINES

## ⚠️ INSTRUÇÕES IMPORTANTES

**IMPORTANT!** Não invente nada que não esteja no arquivo pipeline.yaml. Mantenha toda a estrutura e formatação do README.md existente, altere apenas o que estiver inconsistente.

**IMPORTANT!** Nunca utilize `{}` e `<>` sem estar dentro de um bloco de código ou código inline.

**IMPORTANT!** Não invente capacidades na tabela de capacidades, só modifique o status (✅/❌/⚠️/🚧/❎) se realmente mudou no pipeline.

**IMPORTANT!** Mantenha a ordem das seções conforme definido no template. NÃO adicione seções novas nem remova seções existentes.

**IMPORTANT!** Preserve emojis, formatação visual e estrutura já estabelecida.

## 🎯 OBJETIVO

Este prompt serve como guia para atualizar automaticamente a documentação de pipelines Azure DevOps mantendo consistência, precisão e completude sem intervenções desnecessárias.

## 📋 INSTRUÇÕES DE USO

### Comando Base
```
Adeque a documentação de #file:pipeline.yaml em #file:README.md, mantenha toda a estrutura existente e modifique apenas dados que apresentem inconsistências.
```

### Parâmetros Aceitos
- `#file:pipeline.yaml` - Arquivo de pipeline a ser analisado
- `#file:README.md` - Documentação a ser atualizada

## 🔍 ANÁLISE OBRIGATÓRIA

### 1. Comparação Estrutural

- [ ] **Parâmetros**: Compare lista, tipos, valores padrão e descrições
- [ ] **Variáveis**: Verifique definições e valores
- [ ] **Estágios**: Analise sequência, dependências e condições
- [ ] **Recursos**: Valide service connections e dependências externas
- [ ] **Comentários**: Identifique TODOs, notas técnicas importantes
- [ ] **Capacidades**: Verifique se SAST, SCA, testes, etc. estão corretamente documentados

### 2. Detecção de Inconsistências

- [ ] **Parâmetros Adicionados**: Novos parâmetros não documentados
- [ ] **Parâmetros Removidos**: Parâmetros documentados mas não existentes
- [ ] **Parâmetros Modificados**: Tipos, valores padrão ou nomes alterados
- [ ] **Ordem de Seções**: Sequência incorreta de estágios ou parâmetros
- [ ] **Descrições Desatualizadas**: Funcionalidades alteradas não refletidas
- [ ] **Exemplos Obsoletos**: Código de exemplo com sintaxe desatualizada
- [ ] **Capacidades Incorretas**: Status de capacidades não condiz com implementação real

## ⚙️ REGRAS DE ATUALIZAÇÃO

### 🚨 CRÍTICO - SEMPRE ATUALIZAR

1. **Lista de Parâmetros**: Adicionar/remover/modificar conforme pipeline.yaml
2. **Tipos de Dados**: Corrigir tipos (string, boolean, number, array) incorretos
3. **Valores Padrão**: Sincronizar com definições do pipeline
4. **Estágios e Fluxo**: Atualizar diagramas mermaid (apenas stages) e descrições de execução
5. **Dependências Externas**: Service connections, pools de agentes, recursos
6. **TODOs e Limitações**: Refletir comentários importantes do pipeline
7. **Matriz de Capacidades**: Atualizar status real das capacidades implementadas
8. **Quick Start**: Garantir que exemplo básico está funcional

### ⚠️ MODERADO - ATUALIZAR SE NECESSÁRIO

1. **Descrições de Parâmetros**: Melhorar clareza sem alterar significado
2. **Exemplos de Código**: Corrigir sintaxe ou adicionar casos omissos
3. **Links e Referências**: Validar URLs e caminhos
4. **Seção FAQ**: Adicionar perguntas comuns identificadas
5. **Comportamentos Customizados**: Atualizar exemplos se parâmetros mudaram

### ✅ MANTER - NÃO ALTERAR

1. **Estrutura Base do README**: Títulos, emojis, organização geral
2. **Texto Narrativo Correto**: Descrições que ainda são precisas
3. **Histórico de Decisões**: Seção "Decisões Tomadas" existente
4. **Formatação Markdown**: Estilos, tabelas, listas já bem formatadas
5. **Seção de Suporte**: Links e informações de contato

## 📐 PADRÕES DE DOCUMENTAÇÃO

### Seções Obrigatórias (manter ordem)

1. **Título e Descrição**
2. **🎯 Descrição** (detalhada com contexto)
3. **🚀 Quick Start (5 minutos)**
4. **🏗️ Matriz de Capacidades**
5. **🔄 Estrutura do Pipeline** (com diagrama Mermaid mostrando apenas stages)
6. **⚙️ Parâmetros Disponíveis** (divididos por categoria)
7. **🔧 Dependências Externas**
8. **🎨 Comportamentos Customizados**
9. **Variáveis de Ambiente**
10. **❓ FAQ**
11. **🆘 Suporte**
12. **📝 Decisões Tomadas**

### Formato de Parâmetros

```markdown
#### nomeParametro

- **nome**: nomeParametro
- **tipo**: string|boolean|number|array
- **default**: "valorPadrao" (ou true/false sem aspas para boolean)
- **descrição**: Descrição clara e concisa do parâmetro.
- **dependências**: Requisitos ou impactos relacionados, ou "Nenhuma."
```

### Exemplos de Código

```markdown
#### [Cenário X - Descrição]

\`\`\`yaml
# .azuredevops/pipelines/[categoria].yaml
resources:
  repositories:
    - repository: CodePlay
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: refs/heads/master
      endpoint: CodePlay

extends:
  template: /framework/pipelines/[categoria]/[nome-do-pipeline]/pipeline.yaml@CodePlay
  parameters:
    parametro1: valor1
    parametro2: valor2
\`\`\`
```

## 🔧 PROCESSO DE VALIDAÇÃO

### Checklist Pré-Atualização

- [ ] Ler completamente o pipeline.yaml identificando alterações
- [ ] Mapear diferenças entre pipeline e documentação atual
- [ ] Identificar seções que precisam de atualização
- [ ] Verificar se exemplos ainda funcionam com a sintaxe atual
- [ ] Validar se capacidades documentadas condizem com implementação real

### Checklist Pós-Atualização

- [ ] Todos os parâmetros do pipeline estão documentados
- [ ] Nenhum parâmetro documentado está ausente no pipeline
- [ ] Tipos e valores padrão estão corretos
- [ ] Fluxo de execução reflete estágios do pipeline
- [ ] Diagrama mermaid mostra apenas stages (não jobs/steps)
- [ ] Exemplos de uso são válidos e completos
- [ ] TODOs e limitações são mencionados quando relevantes
- [ ] Capacidades na matriz estão corretamente marcadas
- [ ] Quick Start está atualizado e funcional

## 🚨 ALERTAS IMPORTANTES

### ❌ NÃO FAÇA

- **Não remova** seções existentes sem verificar se são obsoletas
- **Não altere** estrutura de títulos e organização já estabelecida
- **Não modifique** formatação que está funcionando bem
- **Não adicione** informações não baseadas no pipeline.yaml
- **Não simplifique** descrições técnicas importantes
- **Não invente** capacidades que não existem no pipeline
- **Não documente** jobs ou steps no diagrama mermaid - apenas stages
- **Não use** `{}` ou `<>` fora de código inline

### ✅ SEMPRE FAÇA

- **Mantenha** consistência com pipeline.yaml como fonte da verdade
- **Preserve** emojis e formatação visual existente
- **Atualize** links e referências quando necessário
- **Documente** mudanças significativas encontradas
- **Valide** sintaxe YAML nos exemplos
- **Analise** capacidades honestamente (não marque ✅ se não existir)
- **Mantenha** ordem das seções conforme template
- **Use** código inline para placeholders: ``{exemplo}`` ou ``<exemplo>``

## 🎯 PROMPT EXECUTÁVEL

```text
Analise o arquivo pipeline.yaml e atualize o README.md seguindo estas diretrizes:

1. COMPARAÇÃO: Identifique diferenças entre pipeline.yaml e README.md atual
2. MAPEAMENTO: Liste inconsistências encontradas (parâmetros, tipos, valores, estágios, capacidades)
3. ATUALIZAÇÃO: Modifique apenas seções com inconsistências detectadas
4. PRESERVAÇÃO: Mantenha toda estrutura, formatação e conteúdo correto existente
5. VALIDAÇÃO: Confirme que exemplos de código são válidos

FOQUE EM:
- Sincronizar lista de parâmetros (adicionar/remover/corrigir)
- Atualizar tipos de dados e valores padrão
- Corrigir ordem de execução de estágios no diagrama mermaid (apenas stages)
- Refletir TODOs e comentários importantes do pipeline
- Validar exemplos de uso
- Verificar status de capacidades na Matriz de Capacidades (✅/❌/⚠️/🚧/❎)
- Atualizar seção Quick Start se necessário
- Validar Dependências Externas

PRESERVE:
- Estrutura de títulos e seções conforme template
- Emojis e formatação visual
- Texto narrativo que ainda é preciso
- Histórico de decisões técnicas
- Ordem das seções: Descrição → Quick Start → Matriz Capacidades → Estrutura Pipeline → 
  Parâmetros → Dependências → Customizações → Variáveis → FAQ → Suporte → Decisões

NÃO FAÇA:
- Não invente informações não presentes no pipeline.yaml
- Não use {} ou <> fora de código inline
- Não documente jobs/steps no mermaid - apenas stages
- Não invente capacidades que não existem

Resultado esperado: README.md atualizado com precisão, mantendo qualidade existente e refletindo estado atual do pipeline.yaml
```

## 📚 REFERÊNCIAS INTERNAS

### Estruturas de Pipeline Identificadas

- **CI Pipelines**: `/framework/pipelines/ci/*/`
- **CD Pipelines**: `/framework/pipelines/cd/*/`

### Padrões de Documentação

- **Exemplo Completo**: `/framework/pipelines/ci/build-docker/README.md`
- **Prompt Criação**: `/framework/PROMPT_CREATE_DOC.md`
- **Prompt Formatação**: `/framework/PROMPT_FORMAT_PIPELINE.md`

### Validação

```bash
# Execute um dos comandos abaixo na raiz do projeto:
make validate-custom PIPELINE=${PATH_TO_YAML}  # Valida um pipeline específico
## Outras formas de validação:
make validate 
make validate-pipelines          # Valida CI e CD
make validate-ci                 # Apenas pipelines CI  
make validate-cd                 # Apenas pipelines CD
## Help
make help                        # Lista todos os comandos disponíveis
```

### Estrutura de Seções Atualizada

A ordem correta das seções no README.md é:

1. **Título** - `# [Nome do Pipeline]`
2. **🎯 Descrição** - Contexto detalhado do pipeline
3. **🚀 Quick Start (5 minutos)** - Guia rápido de implementação
4. **🏗️ Matriz de Capacidades** - Status de cada capacidade
5. **🔄 Estrutura do Pipeline** - Diagrama mermaid (apenas stages) e descrição
6. **⚙️ Parâmetros Disponíveis** - Documentação por categoria
7. **🔧 Dependências Externas** - Service connections, agent pools, etc
8. **🎨 Comportamentos Customizados** - Exemplos de uso
9. **🔖 Variáveis de Ambiente** - Variáveis configuradas automaticamente
10. **❓ FAQ** - Perguntas frequentes
11. **🆘 Suporte** - Canais de atendimento
12. **📝 Decisões Tomadas** - Histórico de decisões técnicas

---

> **Nota**: Este prompt foi desenvolvido para minimizar intervenções manuais mantendo máxima precisão na documentação automatizada de pipelines Azure DevOps, seguindo o padrão atualizado do CodePlay Framework.
