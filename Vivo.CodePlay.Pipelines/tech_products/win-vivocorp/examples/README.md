# Exemplo de uso do script exemplo.bat

## Como usar com o pipeline prod-new.yml

### 1. Pipeline básico (azure-pipelines.yml)

```yaml
trigger: none

resources:
  repositories:
    - repository: Vivo.CodePlay.Pipelines
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: refs/heads/master

extends:
  template: /tech_products/win-vivocorp/prod-new.yml@Vivo.CodePlay.Pipelines
  parameters:
    command: 'exemplo.bat'
    environment: 'prod'
    timeout: 30000
```

### 2. Pipeline com validação condicional

```yaml
trigger: none

parameters:
- name: validateEnvironment
  displayName: 'Validar Ambiente?'
  type: boolean
  default: true
- name: targetEnvironment
  displayName: 'Ambiente de Destino'
  type: string
  default: 'prod'
  values:
  - 'prod'
  - 'hml'
  - 'dev'

resources:
  repositories:
    - repository: Vivo.CodePlay.Pipelines
      name: DevOps/Vivo.CodePlay.Pipelines
      type: git
      ref: refs/heads/master

stages:
# Stage de validação (condicional)
- ${{ if eq(parameters.validateEnvironment, true) }}:
  - template: /tech_products/win-vivocorp/prod-new.yml@Vivo.CodePlay.Pipelines
    parameters:
      command: 'exemplo.bat'
      environment: ${{ parameters.targetEnvironment }}
      timeout: 30000

# Stage principal (sempre executa)
- template: /tech_products/win-vivocorp/prod-new.yml@Vivo.CodePlay.Pipelines
  parameters:
    command: 'seu_script_principal.bat'
    environment: ${{ parameters.targetEnvironment }}
    timeout: 60000
```

## O que o exemplo.bat faz

### Funcionalidades:

1. **Validação de Diretório**: Verifica se está no ambiente Siebel DevOps correto
2. **Listagem de Arquivos**: Executa `dir` e mostra o conteúdo atual
3. **Verificação de Scripts**: Procura por arquivos .bat, .cmd e .ps1
4. **Espaço em Disco**: Verifica espaço livre disponível
5. **Logs Estruturados**: Saída formatada com níveis [INFO], [SUCCESS], [WARNING]
6. **Códigos de Saída**: Retorna 0 (sucesso) ou 1 (warning) para o pipeline

### Output Esperado:

```
[INFO] Iniciando validacao do diretorio atual...
[INFO] Data/Hora: 03/07/2025 14:30:25
[INFO] Diretorio atual: C:\Siebel_Devops\paliativo\prod
[INFO] Listando conteudo do diretorio atual:
-------------------------------------------------------------------------
exemplo.bat
git_prod.bat
deploy_prod.bat
config.xml
-------------------------------------------------------------------------
[INFO] Validando diretorio...
[SUCCESS] Diretorio validado - Estamos no ambiente Siebel DevOps
[INFO] Verificando arquivos de configuracao...
[INFO] Encontrados arquivos .bat no diretorio
exemplo.bat
git_prod.bat
deploy_prod.bat
[INFO] Verificando espaco em disco...
[INFO] Espaco livre no disco: 50,234,567,890 bytes
=========================================================================
[RESULTADO] Validacao concluida com status: SUCCESS
[INFO] Diretorio: C:\Siebel_Devops\paliativo\prod
[INFO] Total de arquivos/pastas: 4
=========================================================================
[INFO] Script executado com sucesso
```

## Localização no Servidor

O script deve ser colocado em:
```
C:\Siebel_Devops\paliativo\prod\exemplo.bat
C:\Siebel_Devops\paliativo\hml\exemplo.bat
C:\Siebel_Devops\paliativo\dev\exemplo.bat
```

## Personalização

Para criar seus próprios scripts, use este como template e modifique:
- As validações específicas (linhas 24-31)
- Os arquivos a procurar (linhas 40-52)
- Os critérios de sucesso/falha (linhas 78-85)

## Troubleshooting

### Script não encontrado
```
[ERROR] 'exemplo.bat' is not recognized as an internal or external command
```
**Solução**: Verificar se o arquivo existe no caminho correto no servidor

### Permissões insuficientes
```
[ERROR] Access denied
```
**Solução**: Verificar permissões do usuário SSH no diretório de destino

### Timeout
```
[ERROR] SSH connection timed out
```
**Solução**: Aumentar o parâmetro `timeout` no pipeline
