# Win-VivoCorp Siebel Provisioners

Pipeline de CI/CD para compilação e deploy de aplicações Siebel no ambiente VivoCorp.

## 📋 Visão Geral

Este provisioner gerencia o processo de:
- Importação de arquivos SIF/XML
- Compilação Siebel
- Administração de ADMs (Application Deployment Manager)
- Deploy em múltiplos ambientes

## 🔧 Variáveis Obrigatórias

### `scriptsPath`

**Descrição:** Caminho base onde estão localizados os scripts de pipeline Siebel.

| Propriedade | Valor |
|-------------|-------|
| **Tipo** | String |
| **Obrigatório** | ✅ Sim |
| **Valor Padrão Esperado** | `C:\Siebel_Devops` |
| **Onde Configurar** | Variable Group: `PIPELINE_VARIABLES` ou `SIBEL_SERVER_COMMON_VARIABLES` |

**Exemplo de uso:**
```yaml
variables:
  scriptsPath: 'C:\Siebel_Devops'
```

**Estrutura esperada:**
```
$(scriptsPath)/
├── pipeline_azure/
│   ├── dev1/
│   │   └── copy_xml_files.ps1
│   ├── qa1/
│   │   └── copy_xml_files.ps1
│   └── ...
├── scripts/
│   ├── replace_dev1.ps1
│   ├── replace_qa1.ps1
│   └── ...
└── log/
```

> ⚠️ **Importante:** Se a variável `scriptsPath` não estiver definida, o pipeline falhará com uma mensagem de erro clara indicando como configurá-la.

---

### `SIEBEL_PRIVATE_KEY`

**Descrição:** Chave privada SSH para autenticação nos servidores Siebel.

| Propriedade | Valor |
|-------------|-------|
| **Tipo** | String (Secret) |
| **Obrigatório** | ✅ Sim |
| **Onde Configurar** | Variable Group como **Secret Variable** ou Azure Key Vault |

**Boas Práticas de Segurança:**
1. ✅ Sempre marcar como **Secret** no Azure DevOps
2. ✅ Nunca expor em logs (evitar `Write-Host` ou `echo` com o valor)
3. ✅ Considerar uso de **Secure Files** para maior segurança
4. ✅ Rotacionar periodicamente as chaves

**Configuração recomendada:**
```yaml
# Em Variable Group (marcado como secret)
SIEBEL_PRIVATE_KEY: $(KeyVault.SiebelPrivateKey)
```

---

## ⏱️ Configurações de Timeout

### Job: MonitorCompilation

| Configuração | Valor | Justificativa |
|--------------|-------|---------------|
| `timeoutInMinutes` | 240 (4 horas) | Compilações Siebel podem levar entre 90-180 minutos em cenários complexos |

**Histórico de Duração (QA):**
- Compilação simples: ~30-60 minutos
- Compilação média: ~90-120 minutos
- Compilação complexa (múltiplos objetos): ~150-180 minutos
- Picos observados: até 200 minutos

> 💡 O timeout de 240 minutos oferece margem de segurança para cenários de pico sem encerrar builds válidos prematuramente.

---

## 📁 Estrutura de Arquivos

```
provisioners/
├── README.md              # Esta documentação
├── provisioner_entry.yml  # Ponto de entrada do provisioner
├── scripts/               # Scripts auxiliares
├── stages/
│   └── default/
│       ├── adm.yml        # Stage de ADM get/import
│       ├── build.yml      # Stage de compilação Siebel
│       └── import.yml     # Stage de importação de arquivos
└── variables/
    └── load.yml           # Carregamento de variable groups
```

---

## 🚀 Ambientes Suportados

| Ambiente | Variable Group |
|----------|----------------|
| dev1 | `DEV1_VARIABLES` |
| qa1 | `QA1_VARIABLES` |
| qa2 | `QA2_VARIABLES` |
| pp | `PP_VARIABLES` |
| ppl | `PPL_VARIABLES` |
| prod_new | `PROD_NEW_VARIABLES` |
| prd | `PRD_VARIABLES` |

---

## 🔍 Troubleshooting

### Erro: "scriptsPath variável não definida"

**Causa:** A variável `scriptsPath` não está configurada no pipeline.

**Solução:**
1. Acesse o Variable Group `PIPELINE_VARIABLES` no Azure DevOps
2. Adicione a variável `scriptsPath` com valor `C:\Siebel_Devops`
3. Salve e execute o pipeline novamente

### Erro: Timeout durante compilação

**Causa:** Compilação excedeu o limite de tempo configurado.

**Solução:**
1. Verifique se há problemas de performance no agente
2. Analise os logs para identificar possíveis hangs
3. Se necessário, aumente o timeout no arquivo `build.yml`

---

## 📝 Changelog

### 2026-01-30
- Adicionada validação obrigatória da variável `scriptsPath`
- Documentação do timeout de compilação (240 min)
- Removida duplicação de `timeoutInMinutes` entre job e task
- Criada documentação completa do provisioner
