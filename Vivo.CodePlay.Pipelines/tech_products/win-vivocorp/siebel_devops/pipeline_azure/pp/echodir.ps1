# Script PowerShell elaborado para fechamento de pacote
# Autor: Pipeline DevOps Vivo
# Data: 26/06/2025
# Descrição: Script responsável por exibir informações de fechamento do pacote

param(
    [string]$Environment = "DEFAULT",
    [switch]$ShowFullInfo
)

# Função para formatar data/hora no padrão Vivo
function Get-FormattedDateTime {
    $datetime = Get-Date
    $formattedDate = $datetime.ToString("yyyy_MM_dd_HH_mm_ss")
    return $formattedDate
}

# Função principal do script
function Invoke-PackageCloseInfo {
    try {
        # Obtém informações do ambiente
        $currentDirectory = Get-Location
        $currentUser = $env:USERNAME
        $machineName = $env:COMPUTERNAME
        $datetime = Get-FormattedDateTime
        
        # Exibe cabeçalho
        Write-Host "=" * 60 -ForegroundColor Cyan
        Write-Host "       VIVO DEVOPS - FECHAMENTO DE PACOTE" -ForegroundColor Yellow
        Write-Host "=" * 60 -ForegroundColor Cyan
        
        # Informações básicas
        Write-Host "Ambiente: $Environment" -ForegroundColor Green
        Write-Host "Diretório atual: $currentDirectory" -ForegroundColor White
        Write-Host "Usuário: $currentUser" -ForegroundColor White
        Write-Host "Máquina: $machineName" -ForegroundColor White
        
        if ($ShowFullInfo) {
            Write-Host "Sistema Operacional: $($env:OS)" -ForegroundColor Gray
            Write-Host "Processador: $($env:PROCESSOR_ARCHITECTURE)" -ForegroundColor Gray
        }
        
        Write-Host "-" * 60 -ForegroundColor Cyan
        
        # Mensagem principal de sucesso
        $successMessage = "Conseguimos fechar o pacote $datetime"
        Write-Host $successMessage -ForegroundColor Green -BackgroundColor Black
        
        Write-Host "=" * 60 -ForegroundColor Cyan
        
        # Log para arquivo (opcional)
        $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $successMessage - Dir: $currentDirectory"
        
        # Retorna objeto estruturado
        return @{
            Success = $true
            Message = $successMessage
            DateTime = $datetime
            Directory = $currentDirectory.Path
            Environment = $Environment
            User = $currentUser
            Machine = $machineName
            Timestamp = Get-Date
            LogEntry = $logMessage
        }
        
    } catch {
        Write-Host "ERRO: Falha ao executar script de fechamento" -ForegroundColor Red
        Write-Host "Detalhes: $($_.Exception.Message)" -ForegroundColor Red
        
        return @{
            Success = $false
            Message = "Erro ao fechar pacote"
            Error = $_.Exception.Message
            DateTime = Get-FormattedDateTime
        }
    }
}

# Executa a função principal
$result = Invoke-PackageCloseInfo

# Para compatibilidade com pipelines, também exibe a mensagem simples
Write-Output $result.Message
