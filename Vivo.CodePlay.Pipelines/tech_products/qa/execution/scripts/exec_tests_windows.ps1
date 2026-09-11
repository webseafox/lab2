$root_dir="src/main/java"


$MAX_PARALLEL_SCENARIOS=10
$MAX_MEMORY_PER_PROCESS=3
$MEMORY_SAFETY_MARGIN=5

# Verificação de variáveis de ambiente
if (-not $env:DOCKER_IMAGE) {
    Write-Host "DOCKER_IMAGE is not set." -ForegroundColor Red
    exit 1
}
if (-not $env:SCENARIOS) {
    Write-Host "SCENARIOS is not set." -ForegroundColor Red
    exit 1
}
if (-not $env:OPTIONALS) {
    Write-Host "OPTIONALS is not set, using default value." -ForegroundColor Yellow
    $env:OPTIONALS = ""  # Define um valor padrão ou tome outra ação
}
if (-not $env:FRAMEWORK) {
    Write-Host "FRAMEWORK is not set." -ForegroundColor Red
    exit 1
}
if (-not $env:ENVIRONMENT) {
    Write-Host "ENVIRONMENT is not set." -ForegroundColor Red
    exit 1
}
if (-not $env:ALM_USER -or -not $env:ALM_PASSWORD) {
    Write-Host "ALM_USER or ALM_PASSWORD is not set." -ForegroundColor Red
    exit 1
}
# Exibir informações do ambiente
Write-Host "DOCKER_IMAGE: " -NoNewline
Write-Host $env:DOCKER_IMAGE
Write-Host "SCENARIOS: " -NoNewline
Write-Host $env:SCENARIOS
Write-Host "OPTIONALS: " -NoNewline
Write-Host $env:OPTIONALS
Write-Host "FRAMEWORK: " -NoNewline
Write-Host $env:FRAMEWORK
Write-Host "ENVIRONMENT: " -NoNewline
Write-Host $env:ENVIRONMENT

# Controle do LeanFT
if ($env:DOCKER_IMAGE -eq "windows") {
    Write-Host "Restarting LeanFT..." -ForegroundColor Cyan
    & leanft.bat stop | Out-Null
    Start-Sleep -Seconds 2
    & leanft.bat start
}

# Montar os argumentos do Maven em um Array
$mavenArgs = @(
    "clean", "install", "-U", "-X",
    "-f", "pom.xml",
    "-s", "settings.xml",
    "-Denvironment=$env:ENVIRONMENT",
    "-Dalm_user=$env:ALM_USER",
    "-Dalm_password=$env:ALM_PASSWORD",
    "-Dtest=$env:SCENARIOS",
    "-Dignore.test.failure=false",
    "-Dmaven.repo.local=$env:USERPROFILE\.m2\repository",
    "-Dorg.slf4j.simpleLogger.showDateTime=true",
    "-Dstyle.color=never"
)

#Se houver opcionais, dividimos a string por espaços e adicionamos ao array
if (-not [string]::IsNullOrWhiteSpace($env:OPTIONALS)) {
    # Cada "-Dprop=value" vira um item independente no array
    $optionalArgs = $env:OPTIONALS -split ' ' | Where-Object { $_ -ne "" }
    $mavenArgs += $optionalArgs
}

# Exibir o comando Maven
Write-Host "Executando Maven: mvn $($mavenArgs -join ' ')" -ForegroundColor Cyan

# Executar o comando Maven usando o operador &
& mvn $mavenArgs

# Captura o código de saída do Maven imediatamente após a execução
$mavenExitCode = $LASTEXITCODE

# Bloco de Finalização/Limpeza
if ($env:DOCKER_IMAGE -eq "windows") {
    Write-Host "Limpando processos Leanft..." -ForegroundColor Yellow
    & leanft.bat stop | Out-Null
}

# Verificar o código de saída capturado
if ($mavenExitCode -ne 0) {
    Write-Host "Maven build failed with exit code: $mavenExitCode" -ForegroundColor Red
    Set-Content -Path ".\failed_tests.txt" -Value $env:SCENARIOS
    exit $mavenExitCode
}

Write-Host "Maven build finished successfully!" -ForegroundColor Green
