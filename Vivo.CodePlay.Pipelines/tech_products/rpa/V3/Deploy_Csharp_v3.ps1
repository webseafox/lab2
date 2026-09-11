[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$listDestination,
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
    [switch]$VerboseLogs,
    [Parameter(Mandatory = $false)]
    [System.Management.Automation.PSCredential]$Credential
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-LogPath {
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

function Write-Log {
    param([Parameter(Mandatory = $true)][string]$Message)
    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
    try {
        Add-Content -Path $script:DestinationLogFile -Value $entry -Encoding utf8
    } catch {
        Write-Host "AVISO: Falha ao escrever em '$script:DestinationLogFile': $($_.Exception.Message)"
    }
    Write-Host $entry
}

function Write-VerboseLog {
    param([Parameter(Mandatory = $true)][string]$Message)
    if ($VerboseLogs.IsPresent) {
        Write-Log "VERBOSE: $Message"
    }

}

function Get-SafeErrorMessage {
    param([Parameter(Mandatory = $true)][System.Exception]$Exception)

    $message = $Exception.Message
    if ([string]::IsNullOrWhiteSpace($message)) {
        return "Erro não detalhado."
    }

    $sanitized = $message -replace '(?i)(password|senha|token|secret)\s*[:=]\s*[^;,\s]+', '$1=***'
    $sanitized = $sanitized -replace '\s+', ' '
    return $sanitized.Trim()
}

function Normalize-DestinationList {
    param([Parameter(Mandatory = $true)][string]$RawList)
    return $RawList -split '[,;\s\r\n]+' |
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

    Write-Log "AVISO: parâmetro -senha em texto plano está obsoleto; prefira -Password (SecureString) ou -Credential."
    $securePassword = ConvertTo-SecureString $PlainPassword -AsPlainText -Force
    return New-Object System.Management.Automation.PSCredential($UserName, $securePassword)
}

function Test-SafePathForCleanup {
    param([Parameter(Mandatory = $true)][string]$Path)

    if ($Path -match '^[A-Za-z]:\\[^\\]+') { return $true }
    if ($Path -match '^\\\\[^\\]+\\[^\\]+\\[^\\]+') { return $true }
    return $false
}

function Test-RemoteProcessByCim {
    param(
        [Parameter(Mandatory = $true)][string]$ComputerName,
        [Parameter(Mandatory = $true)][System.Management.Automation.PSCredential]$Cred,
        [Parameter(Mandatory = $true)][string]$ProcessName
    )

    try {
        $process = Get-CimInstance -ClassName Win32_Process -ComputerName $ComputerName -Credential $Cred -Filter ("Name='{0}.exe'" -f $ProcessName) -ErrorAction Stop
        return $null -ne $process
    } catch {
        Write-VerboseLog "Falha ao consultar processo via CIM em '$ComputerName': $($_.Exception.Message)"
        return $false
    }
}

if (-not (Test-Path -Path $PathFile -PathType Container)) {
    throw "Diretório de artefatos inválido: '$PathFile'."
}

$script:DestinationLogFile = Resolve-LogPath -BasePath $PathFile -RequestedLogPath $logFile
$logDir = Split-Path -Path $script:DestinationLogFile -Parent
if (-not (Test-Path -Path $logDir -PathType Container)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}
"Log de Deploy - $(Get-Date -Format o)" | Out-File -FilePath $script:DestinationLogFile -Encoding utf8

$destinations = @(Normalize-DestinationList -RawList $listDestination)
if ($destinations.Count -eq 0) {
    Write-Log "RESOURCE:Local:FAILED:Nenhum destino de deploy foi especificado."
    exit 1
}

$deployCredential = New-DeployCredential -ProvidedCredential $Credential -UserName $usuario -PlainPassword $senha -SecurePassword $Password -PlainPasswordAllowed $AllowPlainPassword.IsPresent
$sourcePath = Join-Path $PathFile "$ArquivoProjeto.zip"
$remoteZipPath = "C:\$ArquivoProjeto.zip"
$remoteExtractPath = "C:\$ArquivoProjeto"

if (-not (Test-Path -Path $sourcePath -PathType Leaf)) {
    Write-Log "RESOURCE:Local:FAILED:Arquivo de origem não encontrado em '$sourcePath'."
    exit 1
}

$sourceHash = (Get-FileHash -Path $sourcePath -Algorithm SHA256).Hash
$srcInfo = Get-Item -Path $sourcePath -ErrorAction Stop
Write-Log "Origem: $($srcInfo.FullName) ($([math]::Round($srcInfo.Length / 1KB, 2)) KB, SHA256: $($sourceHash.Substring(0, 12))...)"

$failedResources = New-Object System.Collections.Generic.List[string]

foreach ($destination in $destinations) {
    Write-Log "--- Iniciando deploy para '$destination' ---"
    $session = $null
    $tempExtractPath = $null

    try {
        $sessionOption = New-PSSessionOption -ProxyAccessType NoProxyServer
        $session = New-PSSession -ComputerName $destination -Credential $deployCredential -SessionOption $sessionOption -ErrorAction Stop

        $processRunning = Invoke-Command -Session $session -ScriptBlock {
            param($ProcessName)
            return (Get-Process -Name $ProcessName -ErrorAction Ignore) -ne $null
        } -ArgumentList $ArquivoProjeto -ErrorAction Stop

        if ($processRunning) {
            throw "Processo '$ArquivoProjeto.exe' já está em execução."
        }

        Copy-Item -Path $sourcePath -Destination $remoteZipPath -ToSession $session -Force -ErrorAction Stop
        $remoteHashResult = Invoke-Command -Session $session -ScriptBlock {
            param($ZipPath)
            if (-not (Test-Path -Path $ZipPath -PathType Leaf)) {
                throw "Arquivo remoto não encontrado em '$ZipPath'."
            }
            return @{
                Hash = (Get-FileHash -Path $ZipPath -Algorithm SHA256).Hash
                Size = (Get-Item -Path $ZipPath).Length
            }
        } -ArgumentList $remoteZipPath -ErrorAction Stop

        if ($remoteHashResult.Hash -ne $sourceHash) {
            throw "Falha de integridade após cópia remota (hash divergente)."
        }

        Invoke-Command -Session $session -ScriptBlock {
            param($ZipPath, $ExtractPath)
            if (Test-Path -Path $ExtractPath -PathType Container) {
                if ($ExtractPath -notmatch '^[A-Za-z]:\\[^\\]+') {
                    throw "Diretório remoto inválido para limpeza: '$ExtractPath'."
                }
                Remove-Item -Path (Join-Path $ExtractPath '*') -Recurse -Force -ErrorAction Stop
            } else {
                New-Item -Path $ExtractPath -ItemType Directory -Force | Out-Null
            }

            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $archive = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
            try {
                $basePath = [System.IO.Path]::GetFullPath($ExtractPath)
                foreach ($entry in $archive.Entries) {
                    if ([string]::IsNullOrWhiteSpace($entry.FullName)) { continue }

                    $entryTargetPath = Join-Path $ExtractPath $entry.FullName
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
        } -ArgumentList $remoteZipPath, $remoteExtractPath -ErrorAction Stop

        Write-Log "RESOURCE:$destination:SUCCEEDED:Deploy concluído via PSSession."
    } catch {
        $psSessionError = Get-SafeErrorMessage -Exception $_.Exception
        Write-Log "Aviso: Falha no deploy por PSSession em '$destination': $psSessionError"
        Write-Log "Tentando fallback via SMB/UNC para '$destination'..."

        try {
            if (Test-RemoteProcessByCim -ComputerName $destination -Cred $deployCredential -ProcessName $ArquivoProjeto) {
                throw "Processo '$ArquivoProjeto.exe' em execução (CIM)."
            }

            $uncDestinationPath = "\\$destination\c$\$ArquivoProjeto"
            if (-not (Test-SafePathForCleanup -Path $uncDestinationPath)) {
                throw "Caminho UNC inválido para deploy: '$uncDestinationPath'."
            }

            $tempExtractPath = Join-Path $PathFile "temp_extract_$($ArquivoProjeto)_$(Get-Random)"
            New-Item -Path $tempExtractPath -ItemType Directory -Force | Out-Null
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $archive = [System.IO.Compression.ZipFile]::OpenRead($sourcePath)
            try {
                $basePath = [System.IO.Path]::GetFullPath($tempExtractPath)
                foreach ($entry in $archive.Entries) {
                    if ([string]::IsNullOrWhiteSpace($entry.FullName)) { continue }

                    $entryTargetPath = Join-Path $tempExtractPath $entry.FullName
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

            if (Test-Path -Path $uncDestinationPath -PathType Container) {
                Get-ChildItem -Path $uncDestinationPath -Force -ErrorAction Stop | Remove-Item -Recurse -Force -ErrorAction Stop
            } else {
                New-Item -Path $uncDestinationPath -ItemType Directory -Force | Out-Null
            }

            Copy-Item -Path (Join-Path $tempExtractPath '*') -Destination $uncDestinationPath -Recurse -Force -ErrorAction Stop
            Write-Log "RESOURCE:$destination:SUCCEEDED:Deploy concluído via SMB."
        } catch {
            $failedResources.Add($destination) | Out-Null
            Write-Log "RESOURCE:$destination:FAILED:$(Get-SafeErrorMessage -Exception $_.Exception)"
        }
    } finally {
        if ($null -ne $session) {
            Remove-PSSession -Session $session -ErrorAction SilentlyContinue
        }
        if ($null -ne $tempExtractPath -and (Test-Path -Path $tempExtractPath -PathType Container)) {
            if (Test-SafePathForCleanup -Path $tempExtractPath) {
                Remove-Item -Path $tempExtractPath -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        Write-Log "--- Deploy para '$destination' finalizado ---"
    }
}

$totalResources = $destinations.Count
$failCount = $failedResources.Count
Write-Log "Resumo: total=$totalResources sucesso=$($totalResources - $failCount) falha=$failCount"
if ($failCount -gt 0) {
    Write-Log "Recursos com falha: $($failedResources -join ', ')"
}

try {
    $failedListPath = Join-Path -Path $logDir -ChildPath "failed_resources.txt"
    if ($failCount -gt 0) {
        ($failedResources -join "`n") | Out-File -FilePath $failedListPath -Encoding utf8 -Force
    } elseif (Test-Path -Path $failedListPath -PathType Leaf) {
        Remove-Item -Path $failedListPath -Force -ErrorAction Stop
    }
} catch {
    Write-Log "AVISO: Não foi possível atualizar failed_resources.txt: $(Get-SafeErrorMessage -Exception $_.Exception)"
}

if ($failCount -eq $totalResources) {
    exit 1
}
if ($failCount -gt 0) {
    Write-Host "##vso[task.logissue type=warning]Deploy parcial: $failCount de $totalResources recurso(s) falharam."
    Write-Host "##vso[task.complete result=SucceededWithIssues;]Deploy parcial concluído com avisos."
}
exit 0
