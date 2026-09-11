# 📊 Git Stats - Extrator de Estatísticas

Scripts Python para extrair e gerar relatórios de estatísticas do Git com foco no último mês de atividade.  
**Agora com análise completa de Pull Requests via Azure DevOps API!** 🔀

## 📁 Arquivos

- **`git_stats.py`** - Script completo com relatório detalhado em Markdown + análise de PRs do Azure DevOps
- **`git_stats_simple.py`** - Versão simplificada para uso rápido no terminal
- **`exemplo_integracao.md`** - Exemplo de como integrar o relatório em documentos maiores

## 🚀 Como Usar

### Script Completo (`git_stats.py`)

```bash
# Executar no diretório do seu repositório Git
python3 git_stats.py
```

**Saída:**
- Gera um arquivo `git_stats_report_YYYYMMDD_HHMMSS.md`
- Mostra preview do relatório no terminal
- Formato adequado para seção "Status Codeplay"
- **Inclui análise completa de Pull Requests se Azure DevOps configurado**

### Configuração do Azure DevOps (para análise de PRs)

Para habilitar a análise de Pull Requests, configure as seguintes variáveis de ambiente:

```bash
# Exportar variáveis no terminal (zsh/bash)
export AZURE_DEVOPS_ORG="vivo-ti"
export AZURE_DEVOPS_PROJECT="NomeDoSeuProjeto"
export AZURE_DEVOPS_REPO="nome-do-repositorio"
export AZURE_DEVOPS_PAT="seu-personal-access-token-aqui"

# Ou criar um arquivo .env e carregar antes de executar
```

#### 🔑 Como obter o Personal Access Token (PAT):

1. Acesse: `https://dev.azure.com/{sua-org}/_usersSettings/tokens`
2. Clique em "New Token"
3. Configure:
   - **Name**: Git Stats Script
   - **Organization**: Sua organização
   - **Expiration**: Defina conforme política da empresa
   - **Scopes**: Selecione **Code (Read)** - acesso de leitura ao código
4. Copie o token gerado (não será exibido novamente!)
5. Use o token na variável `AZURE_DEVOPS_PAT`

**⚠️ Importante:** Mantenha seu PAT seguro! Não comite em repositórios ou compartilhe publicamente.

### Script Simplificado (`git_stats_simple.py`)

```bash
# Para estatísticas rápidas no terminal
python3 git_stats_simple.py
```

**Saída:**
- Apenas no terminal
- Estatísticas básicas
- Execução mais rápida

## 📈 Métricas Incluídas

### Dados Básicos (últimos 30 dias)

- 🔄 Número de commits
- 👥 Quantidade de committers únicos
- ➕ Linhas adicionadas
- ➖ Linhas removidas
- 📁 Arquivos modificados

### Análises Avançadas

- 📏 Estatísticas de tamanho dos commits (médio, maior, menor)
- 📁 Top 10 arquivos mais modificados
- ⏰ **Gráfico Mermaid** da distribuição de commits por horário
- 📄 Tipos de arquivo mais modificados
- 🕐 Horários mais ativos de desenvolvimento

### 🔀 Análise de Pull Requests (Azure DevOps)

**Quando configurado com Azure DevOps API, o script fornece:**

#### Métricas Gerais

- 📊 Total de PRs criados no período
- ✅ PRs completados (merged) com porcentagem
- 🔄 PRs ativos
- ❌ PRs abandonados
- 💬 Média de comentários por PR

#### Tempo de Merge

- ⏱️ Tempo médio de merge (horas/dias)
- 📊 Tempo mediano de merge
- 🏃 PR com merge mais rápido
- 🐢 PR com merge mais lento

#### Aprovações e Reviews

- ✅ Quantidade de aprovações
- ⭐ Aprovações com sugestões
- ⏳ PRs aguardando autor
- ❌ PRs rejeitados
- 📊 Total de votos/reviews

#### Rankings

- 👨‍💻 Top 10 autores de PRs
- 👀 Top 10 reviewers mais ativos

#### Visualizações

- 📈 Gráfico de pizza (Mermaid) com distribuição de status dos PRs
- 📋 Tabela com os 10 PRs mais recentes

**Todos os dados de PRs referem-se aos últimos 30 dias (personalizável)**

## 📊 Visualização com Mermaid

O script gera gráficos usando Mermaid Chart para mostrar a atividade de commits por hora:

```mermaid
xychart-beta
    title "Atividade de Commits por Hora"
    x-axis [0h, 1h, 2h, ..., 23h]
    y-axis "Número de Commits"
    bar [dados_dos_commits]
```

## 🔧 Requisitos

- Python 3.6+
- Repositório Git inicializado
- Comandos `git` disponíveis no PATH
- **Para análise de PRs**: Biblioteca `requests` (`pip3 install requests`)

### Instalação de Dependências

```bash
# Instalar biblioteca necessária para análise de PRs
pip3 install requests

# Ou usar requirements.txt (se disponível)
pip3 install -r requirements.txt
```

## 💡 Uso em Relatórios

O script foi projetado para gerar relatórios que se integram perfeitamente em seções "Status Codeplay" de documentos maiores. Veja o arquivo `exemplo_integracao.md` para referência.

## 🛠️ Personalização

Para modificar o período de análise, altere a variável `days` no script:

```python
# Para últimos 60 dias ao invés de 30
self.one_month_ago = self.today - timedelta(days=60)
```

## 📝 Exemplo de Uso

```bash
# Navegar para o repositório
cd /caminho/para/seu/repositorio

# Executar o script
python3 git_stats.py

# Verificar o arquivo gerado
ls git_stats_report_*.md
```

## 🔍 Troubleshooting

### Erro: "não é um repositório Git"

- Certifique-se de estar em um diretório com `.git/`

### Comandos git não encontrados

- Instale o Git ou adicione-o ao PATH

### Sem dados para análise

- Verifique se há commits no período dos últimos 30 dias

### Erro ao acessar API do Azure DevOps

- Verifique se o PAT está correto e não expirou
- Confirme que o PAT tem permissão de leitura em Code
- Verifique os nomes da organização, projeto e repositório
- Teste a conexão: `curl -u :{PAT} https://dev.azure.com/{ORG}/{PROJECT}/_apis/git/repositories`

### Erro "Module 'requests' not found"

- Instale a biblioteca: `pip3 install requests`
