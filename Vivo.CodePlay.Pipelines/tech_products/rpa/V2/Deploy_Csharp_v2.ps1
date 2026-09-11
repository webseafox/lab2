[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [object]$listDestination,
    [Parameter(Mandatory = $true)]
    [string]$PathFile,
    [Parameter(Mandatory = $true)]
    [string]$ArquivoProjeto,
    [Parameter(Mandatory = $false)]
    [string]$usuario,
    [Parameter(Mandatory = $false)]
    [string]$senha,
    [Parameter(Mandatory = $false)]
    [System.Security.SecureString]$Password,
    [Parameter(Mandatory = $false)]
    [switch]$AllowPlainPassword,
    [Parameter(Mandatory = $false)]
    [string]$logFile,
    [Parameter(Mandatory = $false)]
    [System.Management.Automation.PSCredential]$Credential
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-DeployLogPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BasePath,
        [string]$RequestedLogPath
    )

    if ([string]::IsNullOrWhiteSpace($RequestedLogPath)) {
        return Join-Path -Path $BasePath -ChildPath "logCopyZip.txt"
    }

    if ([System.IO.Path]::IsPathRooted($RequestedLogPath)) {
        return $RequestedLogPath
    }

    return Join-Path -Path $BasePath -ChildPath $RequestedLogPath
}

function Write-DeployLog {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
    try {
        Add-Content -Path $script:DestinationLogFile -Value $entry -Encoding utf8
    } catch {
        Write-Host "AVISO: Falha ao gravar no log '$script:DestinationLogFile': $($_.Exception.Message)"
    }

    Write-Host $entry
}

function Get-SafeErrorMessage {
    param([Parameter(Mandatory = $true)][System.Exception]$Exception)

    $message = $Exception.Message
    if ([string]::IsNullOrWhiteSpace($message)) {
        return "Erro não detalhado."
    }

    # Reduz ruído e remove potenciais segredos em mensagens
    $sanitized = $message -replace '(?i)(password|senha|token|secret)\s*[:=]\s*[^;,\s]+', '$1=***'
    $sanitized = $sanitized -replace '\s+', ' '
    return $sanitized.Trim()
}

function Normalize-DestinationList {
    param([Parameter(Mandatory = $true)][object]$RawList)

    $rawText = if ($RawList -is [System.Array]) {
        ($RawList | ForEach-Object { "$_" }) -join ","
    } else {
        "$RawList"
    }

    return $rawText -split '[,;\s\r\n]+' |
        ForEach-Object { $_.Trim().Trim("'`"") } |
        Where-Object { $_ -ne "" -and -not $_.StartsWith('#') }
}

function New-DeployCredential {
    param(
        [System.Management.Automation.PSCredential]$ProvidedCredential,
        [string]$UserName,
        [string]$PlainPassword,
        [System.Security.SecureString]$SecurePassword,
        [bool]$PlainPasswordAllowed
    )

    if ($null -ne $ProvidedCredential) {
        return $ProvidedCredential
    }

    if ([string]::IsNullOrWhiteSpace($UserName)) {
        throw "Informe -Credential ou usuário em -usuario."
    }

    if ($null -ne $SecurePassword) {
        return New-Object System.Management.Automation.PSCredential($UserName, $SecurePassword)
    }

    if ([string]::IsNullOrWhiteSpace($PlainPassword)) {
        throw "Informe -Credential ou -Password (SecureString)."
    }

    if (-not $PlainPasswordAllowed) {
        throw "Uso de -senha bloqueado por padrão. Use -Credential, -Password (SecureString) ou habilite -AllowPlainPassword."
    }

    Write-DeployLog "AVISO: parâmetro -senha em texto plano está obsoleto; prefira -Password (SecureString) ou -Credential."
    $securePassword = ConvertTo-SecureString $PlainPassword -AsPlainText -Force
    return New-Object System.Management.Automation.PSCredential($UserName, $securePassword)
}

function Invoke-RemoteZipExtract {
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory = $true)]
        [string]$ProjectName
    )

    Invoke-Command -Session $Session -ScriptBlock {
        param($RemoteProjectName)

        $extractPath = "C:\$RemoteProjectName"
        $zipPath = "C:\$RemoteProjectName.zip"

        if (-not (Test-Path -Path $zipPath -PathType Leaf)) {
            throw "Arquivo zip remoto não encontrado em '$zipPath'."
        }

        if (Test-Path -Path $extractPath -PathType Container) {
            if ($extractPath -notmatch '^[A-Za-z]:\\[^\\]+') {
                throw "Diretório remoto inválido para limpeza: '$extractPath'."
            }
            Remove-Item -Path (Join-Path $extractPath '*') -Recurse -Force -ErrorAction Stop
        } else {
            New-Item -Path $extractPath -ItemType Directory -Force | Out-Null
        }

        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $archive = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
        try {
            $basePath = [System.IO.Path]::GetFullPath($extractPath)
            foreach ($entry in $archive.Entries) {
                if ([string]::IsNullOrWhiteSpace($entry.FullName)) { continue }

                $entryTargetPath = Join-Path $extractPath $entry.FullName
                $normalizedTargetPath = [System.IO.Path]::GetFullPath($entryTargetPath)
                if (-not $normalizedTargetPath.StartsWith($basePath, [System.StringComparison]::OrdinalIgnoreCase)) {
                    throw "Entrada inválida no zip (path traversal): '$($entry.FullName)'."
                }

                if ($entry.FullName.EndsWith('/') -or $entry.FullName.EndsWith('\') -or [string]::IsNullOrWhiteSpace($entry.Name)) {
                    if (-not (Test-Path -Path $normalizedTargetPath -PathType Container)) {
                        New-Item -Path $normalizedTargetPath -ItemType Directory -Force | Out-Null
                    }
                    continue
                }

                $entryDir = Split-Path -Path $normalizedTargetPath -Parent
                if (-not (Test-Path -Path $entryDir -PathType Container)) {
                    New-Item -Path $entryDir -ItemType Directory -Force | Out-Null
                }

                [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $normalizedTargetPath, $true)
            }
        } finally {
            $archive.Dispose()
        }
    } -ArgumentList $ProjectName -ErrorAction Stop
}

if (-not (Test-Path -Path $PathFile -PathType Container)) {
    throw "Diretório de artefatos inválido: '$PathFile'."
}

$sourceZipPath = Join-Path -Path $PathFile -ChildPath "$ArquivoProjeto.zip"
if (-not (Test-Path -Path $sourceZipPath -PathType Leaf)) {
    throw "Arquivo de deploy não encontrado em '$sourceZipPath'."
}

$script:DestinationLogFile = Resolve-DeployLogPath -BasePath $PathFile -RequestedLogPath $logFile
$logDir = Split-Path -Path $script:DestinationLogFile -Parent
if (-not (Test-Path -Path $logDir -PathType Container)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}
"Log de Deploy - $(Get-Date -Format o)" | Out-File -FilePath $script:DestinationLogFile -Encoding utf8

$destinations = @(Normalize-DestinationList -RawList $listDestination)
if ($destinations.Count -eq 0) {
    Write-DeployLog "RESOURCE:Local:FAILED:Nenhum destino informado."
    exit 1
}

$deployCredential = New-DeployCredential -ProvidedCredential $Credential -UserName $usuario -PlainPassword $senha -SecurePassword $Password -PlainPasswordAllowed $AllowPlainPassword.IsPresent
$failedResources = New-Object System.Collections.Generic.List[string]

foreach ($hostName in $destinations) {
    $session = $null
    try {
        Write-DeployLog "Conectando em $hostName..."
        $sessionOption = New-PSSessionOption -ProxyAccessType NoProxyServer
        $session = New-PSSession -ComputerName $hostName -Credential $deployCredential -SessionOption $sessionOption -ErrorAction Stop

        $processRunning = Invoke-Command -Session $session -ScriptBlock {
            param($ProcessName)
            return (Get-Process -Name $ProcessName -ErrorAction Ignore) -ne $null
        } -ArgumentList $ArquivoProjeto -ErrorAction Stop

        if ($processRunning) {
            $message = "Processo '$ArquivoProjeto.exe' está em execução em '$hostName'."
            Write-DeployLog "RESOURCE:$hostName:FAILED:$message"
            $failedResources.Add($hostName) | Out-Null
            continue
        }

        Copy-Item -Path $sourceZipPath -Destination "C:\$ArquivoProjeto.zip" -ToSession $session -Force -ErrorAction Stop
        Write-DeployLog "$hostName - ZIP copiado com sucesso."

        Invoke-RemoteZipExtract -Session $session -ProjectName $ArquivoProjeto
        Write-DeployLog "RESOURCE:$hostName:SUCCEEDED:Deploy concluído."
    } catch {
        Write-DeployLog "RESOURCE:$hostName:FAILED:$(Get-SafeErrorMessage -Exception $_.Exception)"
        $failedResources.Add($hostName) | Out-Null
    } finally {
        if ($null -ne $session) {
            Remove-PSSession -Session $session -ErrorAction SilentlyContinue
        }
    }
}

$totalResources = $destinations.Count
$failCount = $failedResources.Count
Write-DeployLog "Resumo: total=$totalResources sucesso=$($totalResources - $failCount) falha=$failCount"

if ($failCount -eq $totalResources) {
    exit 1
}

if ($failCount -gt 0) {
    Write-Host "##vso[task.logissue type=warning]Deploy parcial: $failCount de $totalResources recurso(s) falharam."
    Write-Host "##vso[task.complete result=SucceededWithIssues;]Deploy parcial concluído com avisos."
}

exit 0
