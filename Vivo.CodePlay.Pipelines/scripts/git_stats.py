#!/usr/bin/env python3
"""
Script para extrair estatísticas do Git do último mês
Gera um relatório em Markdown com métricas detalhadas do repositório
Inclui análise completa de Pull Requests via Azure DevOps API
"""

import subprocess
import json
import re
from datetime import datetime, timedelta
from collections import defaultdict, Counter
import os
import sys
import requests
import base64
from urllib.parse import quote

class GitStatsExtractor:
    def __init__(self):
        self.today = datetime.now()
        self.one_month_ago = self.today - timedelta(days=30)
        self.date_since = self.one_month_ago.strftime('%Y-%m-%d')
        
    def run_git_command(self, command):
        """Executa um comando git e retorna o resultado"""
        try:
            result = subprocess.run(
                command, 
                shell=True, 
                capture_output=True, 
                text=True, 
                check=True
            )
            return result.stdout.strip()
        except subprocess.CalledProcessError as e:
            print(f"Erro ao executar comando: {command}")
            print(f"Erro: {e.stderr}")
            return ""
    
    def get_basic_stats(self):
        """Coleta estatísticas básicas: commits, linhas, committers"""
        stats = {}
        
        # Número de commits no último mês
        commit_count = self.run_git_command(
            f'git rev-list --count --since="{self.date_since}" HEAD'
        )
        stats['commits_count'] = int(commit_count) if commit_count else 0
        
        # Linhas adicionadas e removidas usando git log
        log_output = self.run_git_command(
            f'git log --since="{self.date_since}" --numstat --pretty=format:""'
        )
        
        lines_added = 0
        lines_removed = 0
        files_set = set()
        
        for line in log_output.split('\n'):
            if line.strip() and '\t' in line:
                parts = line.strip().split('\t')
                if len(parts) >= 3:
                    try:
                        added = int(parts[0]) if parts[0] != '-' else 0
                        removed = int(parts[1]) if parts[1] != '-' else 0
                        filename = parts[2]
                        
                        lines_added += added
                        lines_removed += removed
                        files_set.add(filename)
                    except ValueError:
                        continue
        
        stats['lines_added'] = lines_added
        stats['lines_removed'] = lines_removed
        stats['files_changed'] = len(files_set)
        
        # Número de committers únicos
        committers = self.run_git_command(
            f'git log --since="{self.date_since}" --format="%an" | sort | uniq'
        )
        stats['committers_count'] = len(committers.split('\n')) if committers else 0
        
        return stats
    
    def get_most_modified_files(self, limit=10):
        """Retorna os arquivos mais modificados no último mês"""
        file_changes = self.run_git_command(
            f'git log --since="{self.date_since}" --name-only --pretty=format: | sort | uniq -c | sort -nr | head -{limit}'
        )
        
        files = []
        for line in file_changes.split('\n'):
            if line.strip():
                parts = line.strip().split(' ', 1)
                if len(parts) == 2:
                    count = parts[0]
                    filename = parts[1]
                    files.append({'file': filename, 'changes': int(count)})
        
        return files
    
    def get_activity_by_hour(self):
        """Analisa os horários de maior atividade de commits"""
        hours_data = self.run_git_command(
            f'git log --since="{self.date_since}" --format="%ad" --date=format:"%H" | sort | uniq -c | sort -nr'
        )
        
        activity = {}
        for line in hours_data.split('\n'):
            if line.strip():
                parts = line.strip().split()
                if len(parts) == 2:
                    count = int(parts[0])
                    hour = int(parts[1])
                    activity[hour] = count
        
        return activity
    
    def get_file_types_stats(self):
        """Analisa os tipos de arquivo mais modificados"""
        extensions_data = self.run_git_command(
            f'git log --since="{self.date_since}" --name-only --pretty=format: | grep -E "\\.[^/]*$" | sed "s/.*\\.//g" | sort | uniq -c | sort -nr | head -10'
        )
        
        extensions = {}
        for line in extensions_data.split('\n'):
            if line.strip():
                parts = line.strip().split(' ', 1)
                if len(parts) == 2:
                    count = int(parts[0])
                    ext = parts[1]
                    extensions[ext] = count
        
        return extensions
    
    def get_commit_size_stats(self):
        """Calcula estatísticas sobre o tamanho dos commits"""
        commits_data = self.run_git_command(
            f'git log --since="{self.date_since}" --numstat --pretty=format:"---COMMIT---"'
        )
        
        commit_sizes = []
        current_commit_lines = 0
        
        for line in commits_data.split('\n'):
            line = line.strip()
            
            if line == "---COMMIT---":
                if current_commit_lines > 0:
                    commit_sizes.append(current_commit_lines)
                current_commit_lines = 0
            elif line and '\t' in line:
                parts = line.split('\t')
                if len(parts) >= 2:
                    try:
                        added = int(parts[0]) if parts[0] != '-' else 0
                        removed = int(parts[1]) if parts[1] != '-' else 0
                        current_commit_lines += added + removed
                    except ValueError:
                        continue
        
        # Adicionar o último commit se houver
        if current_commit_lines > 0:
            commit_sizes.append(current_commit_lines)
        
        if commit_sizes:
            return {
                'average_size': round(sum(commit_sizes) / len(commit_sizes), 1),
                'max_size': max(commit_sizes),
                'min_size': min(commit_sizes),
                'total_commits': len(commit_sizes)
            }
        else:
            return {
                'average_size': 0,
                'max_size': 0,
                'min_size': 0,
                'total_commits': 0
            }
    
    def get_yearly_git_trends(self):
        """Coleta dados de commits e linhas alteradas ao longo do último ano (por mês)"""
        print("📈 Analisando tendências do último ano...")
        
        today = datetime.now()
        monthly_data = []
        
        for month_offset in range(12, 0, -1):
            # Calcular início e fim do mês
            end_date = today - timedelta(days=30 * (month_offset - 1))
            start_date = today - timedelta(days=30 * month_offset)
            
            month_label = start_date.strftime('%b/%y')
            
            # Commits no período
            commit_count = self.run_git_command(
                f'git rev-list --count --since="{start_date.strftime("%Y-%m-%d")}" --until="{end_date.strftime("%Y-%m-%d")}" HEAD'
            )
            commits = int(commit_count) if commit_count else 0
            
            # Linhas adicionadas e removidas
            log_output = self.run_git_command(
                f'git log --since="{start_date.strftime("%Y-%m-%d")}" --until="{end_date.strftime("%Y-%m-%d")}" --numstat --pretty=format:""'
            )
            
            lines_added = 0
            lines_removed = 0
            
            for line in log_output.split('\n'):
                if line.strip() and '\t' in line:
                    parts = line.strip().split('\t')
                    if len(parts) >= 2:
                        try:
                            added = int(parts[0]) if parts[0] != '-' else 0
                            removed = int(parts[1]) if parts[1] != '-' else 0
                            lines_added += added
                            lines_removed += removed
                        except ValueError:
                            continue
            
            monthly_data.append({
                'month': month_label,
                'commits': commits,
                'lines_added': lines_added,
                'lines_removed': lines_removed,
                'lines_changed': lines_added + lines_removed
            })
        
        return monthly_data
    
    def get_repository_info(self):
        """Obtém informações gerais do repositório"""
        repo_name = self.run_git_command('basename `git rev-parse --show-toplevel`')
        current_branch = self.run_git_command('git branch --show-current')
        total_commits = self.run_git_command('git rev-list --count HEAD')
        
        return {
            'name': repo_name,
            'current_branch': current_branch,
            'total_commits': int(total_commits) if total_commits else 0
        }
    
    def generate_markdown_report(self, stats, repo_info, most_modified, activity, file_types, commit_sizes, pr_report="", yearly_trends=None):
        """Gera o relatório final em Markdown"""
        
        # Cabeçalho adaptado para seção Status Codeplay
        report = f"""## Status Codeplay

### 📊 Estatísticas Git - Último Mês ({repo_info['name']})

**Período analisado:** {self.date_since} até {self.today.strftime('%Y-%m-%d')} (últimos 30 dias)  
**Branch:** `{repo_info['current_branch']}`  
**Última atualização:** {self.today.strftime('%Y-%m-%d %H:%M:%S')}

#### 📈 Resumo das Atividades

| Métrica | Valor |
|---------|--------|
| 🔄 Commits no período | **{stats['commits_count']}** |
| 👥 Committers únicos | **{stats['committers_count']}** |
| ➕ Linhas adicionadas | **{stats['lines_added']:,}** |
| ➖ Linhas removidas | **{stats['lines_removed']:,}** |
| 📁 Arquivos modificados | **{stats['files_changed']}** |
| 🔢 Total de commits no repo | **{repo_info['total_commits']:,}** |

"""

        # Adicionar seção de Pull Requests se disponível
        if pr_report:
            report += pr_report

        # Estatísticas de tamanho dos commits
        if commit_sizes['total_commits'] > 0:
            report += f"""
#### 📏 Análise dos Commits (últimos 30 dias)

| Métrica | Valor |
|---------|--------|
| 📊 Tamanho médio (linhas) | **{commit_sizes['average_size']:.1f}** |
| 🔼 Maior commit (linhas) | **{commit_sizes['max_size']:,}** |
| 🔽 Menor commit (linhas) | **{commit_sizes['min_size']:,}** |

"""

        # Arquivos mais modificados
        if most_modified:
            report += """
#### 📁 Arquivos Mais Modificados (últimos 30 dias)

| Arquivo | Modificações |
|---------|-------------|
"""
            for file_info in most_modified[:10]:
                report += f"| `{file_info['file']}` | {file_info['changes']} |\n"

        # Atividade por horário com Mermaid
        if activity:
            report += """
#### ⏰ Distribuição de Commits por Horário (últimos 30 dias)

```mermaid
xychart-beta
    title "Atividade de Commits por Hora"
    x-axis [0h, 1h, 2h, 3h, 4h, 5h, 6h, 7h, 8h, 9h, 10h, 11h, 12h, 13h, 14h, 15h, 16h, 17h, 18h, 19h, 20h, 21h, 22h, 23h]
    y-axis "Número de Commits" 0 --> """
            
            max_commits = max(activity.values()) if activity else 1
            report += f"{max_commits}\n"
            
            # Dados do gráfico
            commits_data = []
            for hour in range(24):
                commits_data.append(str(activity.get(hour, 0)))
            
            report += f"    bar [{', '.join(commits_data)}]\n```\n"
            
            # Tabela resumo para horários mais ativos
            top_hours = sorted(activity.items(), key=lambda x: x[1], reverse=True)[:5]
            if top_hours:
                report += "\n**Horários mais ativos:**\n"
                for hour, commits in top_hours:
                    if commits > 0:
                        report += f"- **{hour:02d}h**: {commits} commits\n"

        # Tipos de arquivo
        if file_types:
            report += """
#### 📄 Tipos de Arquivo Mais Modificados (últimos 30 dias)

| Extensão | Modificações |
|----------|-------------|
"""
            for ext, count in list(file_types.items())[:10]:
                report += f"| `.{ext}` | {count} |\n"

        # Tendências anuais
        if yearly_trends and len(yearly_trends) > 0:
            report += """
#### 📊 Tendências do Último Ano

##### 📈 Volume de Atividade (Commits e Linhas de Código)

```mermaid
xychart-beta
    title "Commits e Alterações de Código - Últimos 12 Meses"
    x-axis ["""
            
            # Adicionar labels dos meses
            month_labels = [f'"{trend["month"]}"' for trend in yearly_trends]
            report += ', '.join(month_labels)
            report += """]
    y-axis "Quantidade"
"""
            
            # Dados de commits
            commits_data = [str(trend['commits']) for trend in yearly_trends]
            report += f"    line [{', '.join(commits_data)}]\n"
            
            report += "```\n\n"
            
            # Gráfico de linhas adicionadas vs removidas
            report += """
##### ➕➖ Linhas Adicionadas vs Removidas - Últimos 12 Meses

```mermaid
xychart-beta
    title "Evolução de Linhas de Código"
    x-axis ["""
            
            report += ', '.join(month_labels)
            report += """]
    y-axis "Linhas de Código"
"""
            
            # Dados de linhas
            added_data = [str(trend['lines_added']) for trend in yearly_trends]
            removed_data = [str(trend['lines_removed']) for trend in yearly_trends]
            
            report += f"    line [{', '.join(added_data)}]\n"
            report += f"    line [{', '.join(removed_data)}]\n"
            
            report += "```\n\n"
            
            # Análise de tendência
            recent_commits = sum(trend['commits'] for trend in yearly_trends[-3:])
            older_commits = sum(trend['commits'] for trend in yearly_trends[:3])
            
            if recent_commits > older_commits:
                trend_analysis = "📈 **Tendência crescente** na atividade de desenvolvimento"
            elif recent_commits < older_commits:
                trend_analysis = "📉 **Tendência decrescente** na atividade de desenvolvimento"
            else:
                trend_analysis = "➡️ **Atividade estável** de desenvolvimento"
            
            report += f"**Análise:** {trend_analysis}\n\n"

        # Rodapé
        report += f"""
---

> **📝 Observação:** Estatísticas coletadas automaticamente do repositório Git referentes aos últimos 30 dias  
> **🔍 Comando para detalhes:** `git log --since="{self.date_since}"`  
> **📅 Dados atualizados até:** {self.today.strftime('%d/%m/%Y às %H:%M')}
"""

        return report


class AzureDevOpsPRAnalyzer:
    """
    Classe para análise de Pull Requests via Azure DevOps API
    Requer variáveis de ambiente:
    - AZURE_DEVOPS_ORG: Nome da organização (ex: 'vivo-ti')
    - AZURE_DEVOPS_PROJECT: Nome do projeto
    - AZURE_DEVOPS_REPO: Nome do repositório
    - AZURE_DEVOPS_PAT: Personal Access Token com permissão de leitura
    """
    
    def __init__(self, days=30):
        self.org = os.getenv('AZURE_DEVOPS_ORG', 'telefonica-vivo-brasil')
        self.project = os.getenv('AZURE_DEVOPS_PROJECT', 'DevOps')
        self.repo = os.getenv('AZURE_DEVOPS_REPO', 'Vivo.Codeplay.Pipelines')
        self.pat = os.getenv('AZURE_DEVOPS_PAT')
        
        self.today = datetime.now()
        self.date_since = self.today - timedelta(days=days)
        
        # Configurar autenticação
        if self.pat:
            auth_string = f":{self.pat}"
            auth_bytes = auth_string.encode('ascii')
            base64_auth = base64.b64encode(auth_bytes).decode('ascii')
            self.headers = {
                'Authorization': f'Basic {base64_auth}',
                'Content-Type': 'application/json'
            }
        else:
            self.headers = None
            
        # Configurar URL base (somente se projeto estiver configurado)
        if self.org and self.project:
            self.base_url = f"https://dev.azure.com/{self.org}/{quote(self.project)}/_apis"
        else:
            self.base_url = None
        self.api_version = "7.1-preview.1"
    
    def is_configured(self):
        """Verifica se todas as configurações necessárias estão presentes"""
        return all([self.org, self.project, self.repo, self.pat])
    
    def _make_request(self, endpoint, params=None):
        """Faz uma requisição para a API do Azure DevOps"""
        if not self.is_configured():
            return None
        
        try:
            url = f"{self.base_url}{endpoint}"
            if params is None:
                params = {}
            params['api-version'] = self.api_version
            
            response = requests.get(url, headers=self.headers, params=params, timeout=30)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"⚠️  Erro ao acessar API: {e}")
            return None
    
    def get_pull_requests(self, status='all'):
        """
        Busca Pull Requests do repositório
        status: 'all', 'active', 'completed', 'abandoned'
        """
        endpoint = f"/git/repositories/{self.repo}/pullrequests"
        params = {
            'searchCriteria.status': status,
            '$top': 1000  # Limite máximo
        }
        
        result = self._make_request(endpoint, params)
        if result and 'value' in result:
            # Filtrar PRs do último mês
            prs = []
            for pr in result['value']:
                created_date = datetime.fromisoformat(pr['creationDate'].replace('Z', '+00:00'))
                if created_date.replace(tzinfo=None) >= self.date_since:
                    prs.append(pr)
            return prs
        return []
    
    def get_pr_threads(self, pr_id):
        """Busca threads (comentários) de um PR"""
        endpoint = f"/git/repositories/{self.repo}/pullRequests/{pr_id}/threads"
        result = self._make_request(endpoint)
        if result and 'value' in result:
            return result['value']
        return []
    
    def get_pr_commits(self, pr_id):
        """Busca commits de um PR"""
        endpoint = f"/git/repositories/{self.repo}/pullRequests/{pr_id}/commits"
        result = self._make_request(endpoint)
        if result and 'value' in result:
            return result['value']
        return []
    
    def get_prs_by_period(self, start_date, end_date):
        """Busca PRs em um período específico"""
        endpoint = f"/git/repositories/{self.repo}/pullrequests"
        params = {
            'searchCriteria.status': 'all',
            '$top': 1000
        }
        
        result = self._make_request(endpoint, params)
        if result and 'value' in result:
            prs = []
            for pr in result['value']:
                created_date = datetime.fromisoformat(pr['creationDate'].replace('Z', '+00:00'))
                if start_date <= created_date.replace(tzinfo=None) < end_date:
                    prs.append(pr)
            return prs
        return []
    
    def get_comparative_stats(self):
        """Obtém estatísticas comparativas dos últimos 3 meses"""
        if not self.is_configured():
            return None
        
        print("📊 Coletando estatísticas comparativas dos últimos 3 meses...")
        
        comparative = []
        today = datetime.now()
        
        for month_offset in range(3):
            # Calcular início e fim do período
            if month_offset == 0:
                end_date = today
                start_date = today - timedelta(days=30)
                period_label = "Últimos 30 dias"
            elif month_offset == 1:
                end_date = today - timedelta(days=30)
                start_date = today - timedelta(days=60)
                period_label = "30-60 dias atrás"
            else:
                end_date = today - timedelta(days=60)
                start_date = today - timedelta(days=90)
                period_label = "60-90 dias atrás"
            
            prs = self.get_prs_by_period(start_date, end_date)
            
            if not prs:
                comparative.append({
                    'period': period_label,
                    'total': 0,
                    'completed': 0,
                    'avg_merge_time_hours': 0
                })
                continue
            
            completed = sum(1 for pr in prs if pr.get('status') == 'completed')
            
            # Calcular tempo médio de merge
            merge_times = []
            for pr in prs:
                if pr.get('status') == 'completed' and pr.get('closedDate') and pr.get('creationDate'):
                    try:
                        created = datetime.fromisoformat(pr['creationDate'].replace('Z', '+00:00'))
                        closed = datetime.fromisoformat(pr['closedDate'].replace('Z', '+00:00'))
                        merge_time_hours = (closed - created).total_seconds() / 3600
                        merge_times.append(merge_time_hours)
                    except:
                        continue
            
            avg_merge_time = sum(merge_times) / len(merge_times) if merge_times else 0
            
            comparative.append({
                'period': period_label,
                'total': len(prs),
                'completed': completed,
                'completion_rate': (completed / len(prs) * 100) if len(prs) > 0 else 0,
                'avg_merge_time_hours': avg_merge_time
            })
        
        return comparative
    
    def get_yearly_pr_trends(self):
        """Obtém dados de PRs ao longo do último ano (por mês)"""
        if not self.is_configured():
            return None
        
        print("📊 Coletando dados de PRs do último ano...")
        
        monthly_data = []
        today = datetime.now()
        
        for month_offset in range(12, 0, -1):
            # Calcular início e fim do mês
            end_date = today - timedelta(days=30 * (month_offset - 1))
            start_date = today - timedelta(days=30 * month_offset)
            
            month_label = start_date.strftime('%b/%y')
            
            prs = self.get_prs_by_period(start_date, end_date)
            
            if not prs:
                monthly_data.append({
                    'month': month_label,
                    'total': 0,
                    'completed': 0
                })
                continue
            
            completed = sum(1 for pr in prs if pr.get('status') == 'completed')
            
            monthly_data.append({
                'month': month_label,
                'total': len(prs),
                'completed': completed
            })
        
        return monthly_data
    
    def analyze_prs(self):
        """Realiza análise completa dos PRs do último mês"""
        if not self.is_configured():
            return None
        
        print("🔍 Buscando Pull Requests do Azure DevOps...")
        
        # Buscar PRs por status
        all_prs = self.get_pull_requests('all')
        
        if not all_prs:
            print("⚠️  Nenhum PR encontrado no período")
            return None
        
        stats = {
            'total': len(all_prs),
            'completed': 0,
            'active': 0,
            'abandoned': 0,
            'by_author': defaultdict(int),
            'by_reviewer': defaultdict(int),
            'merge_times': [],
            'comment_counts': [],
            'lines_changed': [],
            'votes_summary': defaultdict(int),
            'pr_details': []
        }
        
        print(f"📊 Analisando {len(all_prs)} Pull Requests...")
        
        for i, pr in enumerate(all_prs, 1):
            if i % 10 == 0:
                print(f"   Processando PR {i}/{len(all_prs)}...")
            
            try:
                pr_status = pr.get('status', 'unknown')
                pr_id = pr.get('pullRequestId')
                
                if not pr_id:
                    continue
                
                # Contadores por status
                if pr_status == 'completed':
                    stats['completed'] += 1
                elif pr_status == 'active':
                    stats['active'] += 1
                elif pr_status == 'abandoned':
                    stats['abandoned'] += 1
                
                # Autor
                created_by = pr.get('createdBy', {})
                author = created_by.get('displayName', 'Desconhecido') if created_by else 'Desconhecido'
                stats['by_author'][author] += 1
                
                # Reviewers
                reviewers = pr.get('reviewers', [])
                if reviewers:
                    for reviewer in reviewers:
                        if not reviewer:
                            continue
                        reviewer_name = reviewer.get('displayName', 'Desconhecido')
                        stats['by_reviewer'][reviewer_name] += 1
                        
                        # Votos (aprovações)
                        vote = reviewer.get('vote', 0)
                        if vote == 10:  # Aprovado
                            stats['votes_summary']['approved'] += 1
                        elif vote == -10:  # Rejeitado
                            stats['votes_summary']['rejected'] += 1
                        elif vote == 5:  # Aprovado com sugestões
                            stats['votes_summary']['approved_with_suggestions'] += 1
                        elif vote == -5:  # Aguardando autor
                            stats['votes_summary']['waiting_for_author'] += 1
                
                # Tempo de merge (se completado)
                creation_date = pr.get('creationDate')
                closed_date = pr.get('closedDate')
                
                if pr_status == 'completed' and creation_date and closed_date:
                    created = datetime.fromisoformat(creation_date.replace('Z', '+00:00'))
                    closed = datetime.fromisoformat(closed_date.replace('Z', '+00:00'))
                    merge_time_hours = (closed - created).total_seconds() / 3600
                    stats['merge_times'].append(merge_time_hours)
                
                # Comentários
                threads = self.get_pr_threads(pr_id)
                stats['comment_counts'].append(len(threads) if threads else 0)
                
                # Detalhes do PR para tabela
                pr_title = pr.get('title', 'Sem título')
                pr_detail = {
                    'id': pr_id,
                    'title': pr_title[:50] + '...' if len(pr_title) > 50 else pr_title,
                    'author': author,
                    'status': pr_status,
                    'created': datetime.fromisoformat(creation_date.replace('Z', '+00:00')).strftime('%Y-%m-%d') if creation_date else 'N/A',
                    'comments': len(threads) if threads else 0
                }
                stats['pr_details'].append(pr_detail)
                
            except Exception as e:
                print(f"⚠️  Erro ao processar PR #{pr.get('pullRequestId', 'unknown')}: {e}")
                continue
        
        # Calcular médias
        if stats['merge_times']:
            stats['avg_merge_time_hours'] = sum(stats['merge_times']) / len(stats['merge_times'])
            stats['median_merge_time_hours'] = sorted(stats['merge_times'])[len(stats['merge_times']) // 2]
        else:
            stats['avg_merge_time_hours'] = 0
            stats['median_merge_time_hours'] = 0
        
        if stats['comment_counts']:
            stats['avg_comments'] = sum(stats['comment_counts']) / len(stats['comment_counts'])
        else:
            stats['avg_comments'] = 0
        
        # Top autores
        stats['top_authors'] = sorted(stats['by_author'].items(), key=lambda x: x[1], reverse=True)[:10]
        
        # Top reviewers
        stats['top_reviewers'] = sorted(stats['by_reviewer'].items(), key=lambda x: x[1], reverse=True)[:10]
        
        print("✅ Análise de PRs concluída!")
        return stats
    
    def generate_pr_report_section(self, pr_stats, comparative_stats=None, yearly_pr_trends=None):
        """Gera a seção de PRs para o relatório Markdown"""
        if not pr_stats:
            return """
### 🔀 Pull Requests (Azure DevOps)

> ⚠️ **Análise de PRs não disponível**  
> Configure as variáveis de ambiente para habilitar:
> - `AZURE_DEVOPS_ORG`
> - `AZURE_DEVOPS_PROJECT`
> - `AZURE_DEVOPS_REPO`
> - `AZURE_DEVOPS_PAT`

---

"""
        
        report = f"""
### 🔀 Pull Requests - Análise Detalhada (últimos 30 dias)

#### 📊 Resumo Geral de Pull Requests

| Métrica | Valor |
|---------|--------|
| 🔢 Total de PRs | **{pr_stats['total']}** |
| ✅ PRs Completados (Merged) | **{pr_stats['completed']}** ({pr_stats['completed']/pr_stats['total']*100 if pr_stats['total'] > 0 else 0:.1f}%) |
| 🔄 PRs Ativos | **{pr_stats['active']}** |
| ❌ PRs Abandonados | **{pr_stats['abandoned']}** |
| 💬 Média de comentários/PR | **{pr_stats['avg_comments']:.1f}** |

"""

        # Tempo de merge
        if pr_stats['completed'] > 0 and pr_stats['avg_merge_time_hours'] > 0:
            avg_days = pr_stats['avg_merge_time_hours'] / 24
            median_days = pr_stats['median_merge_time_hours'] / 24
            
            report += f"""
#### ⏱️ Tempo de Merge (PRs Completados)

| Métrica | Valor |
|---------|--------|
| ⏱️ Tempo médio de merge | **{avg_days:.1f} dias** ({pr_stats['avg_merge_time_hours']:.1f}h) |
| 📊 Tempo mediano de merge | **{median_days:.1f} dias** ({pr_stats['median_merge_time_hours']:.1f}h) |
| 🏃 Merge mais rápido | **{min(pr_stats['merge_times']):.1f}h** |
| 🐢 Merge mais lento | **{max(pr_stats['merge_times']):.1f}h** |

"""

        # Aprovações
        if pr_stats['votes_summary']:
            total_votes = sum(pr_stats['votes_summary'].values())
            report += f"""
#### 👍 Aprovações e Reviews

| Status | Quantidade |
|--------|-----------|
| ✅ Aprovados | **{pr_stats['votes_summary'].get('approved', 0)}** |
| ⭐ Aprovados com sugestões | **{pr_stats['votes_summary'].get('approved_with_suggestions', 0)}** |
| ⏳ Aguardando autor | **{pr_stats['votes_summary'].get('waiting_for_author', 0)}** |
| ❌ Rejeitados | **{pr_stats['votes_summary'].get('rejected', 0)}** |
| 📊 Total de votos | **{total_votes}** |

"""

        # Top Autores
        if pr_stats['top_authors']:
            report += """
#### 👨‍💻 Top Autores de Pull Requests

| Autor | PRs Criados |
|-------|-------------|
"""
            for author, count in pr_stats['top_authors'][:10]:
                report += f"| {author} | **{count}** |\n"

        # Gráfico de distribuição de status
        if pr_stats['total'] > 0:
            report += """
#### 📈 Distribuição de Status dos PRs

```mermaid
pie title "Status dos Pull Requests (últimos 30 dias)"
"""
            report += f'    "Completados" : {pr_stats["completed"]}\n'
            report += f'    "Ativos" : {pr_stats["active"]}\n'
            if pr_stats['abandoned'] > 0:
                report += f'    "Abandonados" : {pr_stats["abandoned"]}\n'
            report += "```\n\n"

        # Tendências anuais de PRs
        if yearly_pr_trends and len(yearly_pr_trends) > 0:
            report += """
#### 📊 Evolução de Pull Requests - Último Ano

```mermaid
xychart-beta
    title "Pull Requests Criados e Completados - Últimos 12 Meses"
    x-axis ["""
            
            # Adicionar labels dos meses
            month_labels = [f'"{trend["month"]}"' for trend in yearly_pr_trends]
            report += ', '.join(month_labels)
            report += """]
    y-axis "Quantidade de PRs"
"""
            
            # Dados de PRs
            total_data = [str(trend['total']) for trend in yearly_pr_trends]
            completed_data = [str(trend['completed']) for trend in yearly_pr_trends]
            
            report += f"    line [{', '.join(total_data)}]\n"
            report += f"    line [{', '.join(completed_data)}]\n"
            
            report += "```\n\n"

        # Comparação com meses anteriores
        if comparative_stats and len(comparative_stats) > 0:
            report += """
#### 📊 Comparação com Meses Anteriores

| Período | Total PRs | PRs Completados | Taxa de Conclusão | Tempo Médio de Merge |
|---------|-----------|-----------------|-------------------|---------------------|
"""
            for stat in comparative_stats:
                avg_days = stat['avg_merge_time_hours'] / 24 if stat['avg_merge_time_hours'] > 0 else 0
                report += f"| {stat['period']} | **{stat['total']}** | **{stat['completed']}** | **{stat['completion_rate']:.1f}%** | **{avg_days:.1f}d** ({stat['avg_merge_time_hours']:.1f}h) |\n"
            
            # Análise de tendência
            if len(comparative_stats) >= 2:
                if comparative_stats[0]['total'] > comparative_stats[1]['total']:
                    trend = "📈 **Tendência crescente** no volume de PRs"
                elif comparative_stats[0]['total'] < comparative_stats[1]['total']:
                    trend = "📉 **Tendência decrescente** no volume de PRs"
                else:
                    trend = "➡️ **Tendência estável** no volume de PRs"
                
                report += f"\n**Análise:** {trend}\n"

        report += "\n---\n\n"
        return report


def main():
    """Função principal"""
    print("🔍 Extraindo estatísticas do Git...")
    
    # Verificar se estamos em um repositório Git
    try:
        subprocess.run(['git', 'rev-parse', '--git-dir'], 
                      capture_output=True, check=True)
    except subprocess.CalledProcessError:
        print("❌ Erro: Este diretório não é um repositório Git.")
        sys.exit(1)
    
    # Inicializar o extrator
    extractor = GitStatsExtractor()
    
    print("📊 Coletando dados básicos...")
    stats = extractor.get_basic_stats()
    repo_info = extractor.get_repository_info()
    
    print("📁 Analisando arquivos mais modificados...")
    most_modified = extractor.get_most_modified_files()
    
    print("⏰ Calculando atividade por horário...")
    activity = extractor.get_activity_by_hour()
    
    print("📄 Analisando tipos de arquivo...")
    file_types = extractor.get_file_types_stats()
    
    print("📏 Calculando estatísticas de commits...")
    commit_sizes = extractor.get_commit_size_stats()
    
    print("📊 Coletando tendências anuais...")
    yearly_trends = extractor.get_yearly_git_trends()
    
    # Análise de Pull Requests do Azure DevOps
    pr_report = ""
    print("\n🔀 Iniciando análise de Pull Requests do Azure DevOps...")
    pr_analyzer = AzureDevOpsPRAnalyzer(days=30)
    
    if pr_analyzer.is_configured():
        try:
            pr_stats = pr_analyzer.analyze_prs()
            comparative_stats = pr_analyzer.get_comparative_stats()
            yearly_pr_trends = pr_analyzer.get_yearly_pr_trends()
            
            if pr_stats:
                pr_report = pr_analyzer.generate_pr_report_section(pr_stats, comparative_stats, yearly_pr_trends)
                print(f"✅ {pr_stats['total']} PRs analisados com sucesso!")
            else:
                print("⚠️  Nenhum PR encontrado no período")
                pr_report = pr_analyzer.generate_pr_report_section(None, None, None)
        except Exception as e:
            print(f"⚠️  Erro ao analisar PRs: {e}")
            pr_report = pr_analyzer.generate_pr_report_section(None, None, None)
    else:
        print("⚠️  Azure DevOps não configurado. Defina as variáveis de ambiente:")
        print("   - AZURE_DEVOPS_ORG")
        print("   - AZURE_DEVOPS_PROJECT")
        print("   - AZURE_DEVOPS_REPO")
        print("   - AZURE_DEVOPS_PAT")
        pr_report = pr_analyzer.generate_pr_report_section(None, None, None)
    
    print("\n📝 Gerando relatório...")
    report = extractor.generate_markdown_report(
        stats, repo_info, most_modified, activity, file_types, commit_sizes, pr_report, yearly_trends
    )
    
    # Salvar o relatório
    output_file = f"git_stats_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(report)
    
    print(f"✅ Relatório gerado com sucesso: {output_file}")
    print(f"📄 {stats['commits_count']} commits analisados no último mês")
    
    # Mostrar prévia do relatório
    print("\n" + "="*60)
    print("📋 PRÉVIA DO RELATÓRIO:")
    print("="*60)
    print(report)

if __name__ == "__main__":
    main()