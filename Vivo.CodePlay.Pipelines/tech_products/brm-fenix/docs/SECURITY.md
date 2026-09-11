# Guia de Segurança - BRM Fenix

> **Políticas e procedimentos de segurança para o framework BRM Fenix**

## 📋 Índice

- [Visão Geral de Segurança](#visão-geral-de-segurança)
- [Secret Management](#secret-management)
- [Autenticação e Autorização](#autenticação-e-autorização)
- [Network Security](#network-security)
- [Container Security](#container-security)
- [Code Security](#code-security)
- [Compliance e Auditoria](#compliance-e-auditoria)
- [Incident Response](#incident-response)

---

## 🔐 Visão Geral de Segurança

### Princípios de Segurança

1. **Defense in Depth** - Múltiplas camadas de segurança
2. **Least Privilege** - Acesso mínimo necessário
3. **Zero Trust** - Nunca confie, sempre verifique
4. **Security by Design** - Segurança desde o início
5. **Continuous Monitoring** - Monitoramento constante
6. **Compliance First** - Conformidade com regulações (LGPD, PCI-DSS)

### Security Stack

```
┌─────────────────────────────────────────────────────────────────────────┐
│                  Layer 1 - Application Security                         │
│                                                                          │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐     │
│  │  Code Scanning   │  │ Dependency Check │  │ Secret Detection │     │
│  │    SonarQube     │  │   Fortify SCA    │  │    Git Hooks     │     │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘     │
└───────────┼──────────────────────┼──────────────────────┼───────────────┘
            │                      │                      │
            ↓                      ↓                      ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                  Layer 2 - Container Security                            │
│                                                                          │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐     │
│  │ Image Scanning   │  │ Runtime          │  │ Registry         │     │
│  │     Trivy        │  │ Protection       │  │ Security         │     │
│  │                  │  │    Falco         │  │     ACR          │     │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘     │
└───────────┼──────────────────────┼──────────────────────┼───────────────┘
            │                      │                      │
            ↓                      ↓                      ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                Layer 3 - Orchestration Security                          │
│                                                                          │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐     │
│  │      RBAC        │  │ Network Policies │  │  Pod Security    │     │
│  │   Kubernetes     │  │     Calico       │  │   Admission      │     │
│  │                  │  │                  │  │   Controller     │     │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘     │
└───────────┼──────────────────────┼──────────────────────┼───────────────┘
            │                      │                      │
            ↓                      ↓                      ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                Layer 4 - Infrastructure Security                         │
│                                                                          │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐     │
│  │  Bastion Host    │  │ Private Networks │  │    Firewall      │     │
│  │   SSH Gateway    │  │     OCI VCN      │  │ Security Lists   │     │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘     │
└───────────┼──────────────────────┼──────────────────────┼───────────────┘
            │                      │                      │
            ↓                      ↓                      ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                  Layer 5 - Identity & Access                             │
│                                                                          │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐     │
│  │    Azure AD      │  │     OCI IAM      │  │  Kubernetes RBAC │     │
│  │      MFA         │  │    Policies      │  │ Service Accounts │     │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘     │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🔑 Secret Management

### Tipos de Secrets

| Tipo | Exemplos | Storage | Acesso |
|------|----------|---------|--------|
| **Credentials** | Database passwords, API keys | Azure Key Vault | Service Principal |
| **Certificates** | SSL/TLS certs, client certs | Azure Key Vault | Automated rotation |
| **SSH Keys** | Bastion access, git deploy keys | Secure Files (Azure DevOps) | Pipeline-only |
| **Config Files** | OCI config, kubeconfig | Secure Files (Azure DevOps) | Pipeline-only |
| **Tokens** | GitHub PAT, Azure DevOps PAT | Variable Groups (encrypted) | Build agents |

### Azure DevOps Secure Files

#### Configuração

```bash
# 1. Upload Secure File
# Azure DevOps > Pipelines > Library > Secure files > + Secure file

# Files necessários:
- oci_config_brm_fenix           # OCI CLI config
- oci_api_key_brm_fenix.pem      # OCI API private key
- ssh_key_bastion_brm_fenix      # SSH key para bastion
- kubeconfig_brm_hml             # Kubernetes config HML
- kubeconfig_brm_prd             # Kubernetes config PRD
```

#### Uso em Pipeline

```yaml
# Download secure file
- task: DownloadSecureFile@1
  name: ociConfig
  inputs:
    secureFile: 'oci_config_brm_fenix'

# Usar caminho do arquivo
- script: |
    echo "Config path: $(ociConfig.secureFilePath)"
    cp $(ociConfig.secureFilePath) ~/.oci/config
    chmod 600 ~/.oci/config
```

### Azure Key Vault Integration

#### Configuração

```bash
# 1. Criar Key Vault (se não existir)
az keyvault create \
  --name kv-brm-fenix \
  --resource-group rg-brm-fenix \
  --location brazilsouth

# 2. Adicionar secrets
az keyvault secret set \
  --vault-name kv-brm-fenix \
  --name brm-db-password-prd \
  --value 'S3cur3P@ssw0rd!'

# 3. Dar acesso ao Service Principal do Azure DevOps
az keyvault set-policy \
  --name kv-brm-fenix \
  --spn <service-principal-id> \
  --secret-permissions get list
```

#### Uso em Pipeline

```yaml
# Link Key Vault to Variable Group
# Azure DevOps > Pipelines > Library > + Variable group
# - Name: brm-fenix-secrets
# - Link secrets from Azure Key Vault

# No pipeline:
variables:
  - group: brm-fenix-secrets  # Contém brm-db-password-prd

steps:
  - script: |
      echo "Connecting to database..."
      export DB_PASSWORD=$(brm-db-password-prd)
      # Usar $DB_PASSWORD na conexão
    displayName: 'Deploy Database'
```

### Variable Groups (Encrypted)

#### Estrutura

```yaml
# Variable Group: brm-fenix-global
DOCKER_REGISTRY: 'acrvivofenix.azurecr.io'
ACR_USERNAME: 'acrvivofenix'
ACR_PASSWORD: <encrypted>  # ⚠️ Secret variable

# Variable Group: brm-fenix-prd
OCI_COMPARTMENT_ID: 'ocid1.compartment.oc1..xxx'
OCI_USER_ID: 'ocid1.user.oc1..yyy'
OCI_TENANCY_ID: 'ocid1.tenancy.oc1..zzz'
OCI_FINGERPRINT: <encrypted>  # ⚠️ Secret variable
DB_CONNECTION_STRING: <encrypted>  # ⚠️ Secret variable
```

#### Boas Práticas

✅ **DO:**
- Marcar variáveis sensíveis como **Secret**
- Usar Variable Groups específicos por ambiente
- Rotacionar secrets regularmente (90 dias)
- Auditar acesso aos Variable Groups
- Usar Azure Key Vault para secrets críticos

❌ **DON'T:**
- Commitar secrets no Git
- Logar valores de secrets (usar `##vso[task.setvariable variable=X;issecret=true]`)
- Compartilhar Variable Groups entre projetos não relacionados
- Usar secrets hardcoded em YAML
- Expor secrets em outputs de pipeline

### Secret Rotation

#### Calendário de Rotação

| Secret | Frequência | Responsável | Processo |
|--------|------------|-------------|----------|
| **Database Passwords** | 90 dias | DBA Team | Automated via script |
| **API Keys** | 90 dias | DevOps Team | Manual rotation |
| **SSH Keys** | 180 dias | DevOps Team | Regenerate + update Secure Files |
| **Certificates** | 365 dias | Security Team | Automated via Let's Encrypt |
| **Service Principal** | 365 dias | Platform Team | Azure AD rotation |

#### Processo de Rotação

```bash
# 1. Gerar novo secret
NEW_PASSWORD=$(openssl rand -base64 32)

# 2. Atualizar em todos os ambientes
for ENV in DEV HML PRE PRD; do
  az keyvault secret set \
    --vault-name kv-brm-fenix \
    --name brm-db-password-$ENV \
    --value "$NEW_PASSWORD"
done

# 3. Atualizar applications (rolling restart)
kubectl set env deployment/brm-dm \
  DB_PASSWORD="$NEW_PASSWORD" -n brm-prd

# 4. Validar conectividade
kubectl exec -it deployment/brm-dm -n brm-prd -- \
  curl localhost:8080/health/database

# 5. Revogar secret antigo
# (após 24h de validação)
```

---

## 👤 Autenticação e Autorização

### Azure DevOps RBAC

#### Roles e Permissões

| Role | Permissões | Membros |
|------|------------|---------|
| **Project Administrator** | Full access | Platform Team (5 pessoas) |
| **Build Administrator** | Manage pipelines, variable groups | DevOps Team (10 pessoas) |
| **Contributor** | Queue builds, view logs | Development Team (50 pessoas) |
| **Reader** | View-only | QA Team, Managers (20 pessoas) |

#### Configuração

```bash
# Azure DevOps > Project Settings > Permissions

# Criar grupo personalizado
# - Name: "BRM-Deployers"
# - Permissions:
#   ✅ Queue builds
#   ✅ Edit build pipeline
#   ❌ Delete build pipeline
#   ✅ View variable groups
#   ❌ Administer variable groups
```

### OCI IAM Policies

#### Service-Specific Policies

```hcl
# Policy: brm-fenix-pipeline-policy
# Permite pipelines gerenciar OKE, compute, networking

Allow group BRM-DevOps-Group to manage cluster-family in compartment BRM-Fenix
Allow group BRM-DevOps-Group to manage instance-family in compartment BRM-Fenix
Allow group BRM-DevOps-Group to use virtual-network-family in compartment BRM-Fenix
Allow group BRM-DevOps-Group to read all-resources in compartment BRM-Fenix
```

#### Least Privilege

```hcl
# Policy: brm-fenix-pipeline-readonly
# Para pipelines que apenas leem informações

Allow group BRM-Pipeline-Readonly to read instance-family in compartment BRM-Fenix
Allow group BRM-Pipeline-Readonly to read cluster-family in compartment BRM-Fenix
```

### Kubernetes RBAC

#### Service Account para Pipeline

```yaml
# serviceaccount-brm-deployer.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: brm-deployer
  namespace: brm-prd

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: brm-deployer-role
  namespace: brm-prd
rules:
  # Deployments
  - apiGroups: ["apps"]
    resources: ["deployments", "replicasets"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
  
  # Pods
  - apiGroups: [""]
    resources: ["pods", "pods/log"]
    verbs: ["get", "list", "watch"]
  
  # Services
  - apiGroups: [""]
    resources: ["services"]
    verbs: ["get", "list", "watch", "create", "update"]
  
  # ConfigMaps & Secrets (read-only)
  - apiGroups: [""]
    resources: ["configmaps", "secrets"]
    verbs: ["get", "list"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: brm-deployer-binding
  namespace: brm-prd
subjects:
  - kind: ServiceAccount
    name: brm-deployer
    namespace: brm-prd
roleRef:
  kind: Role
  name: brm-deployer-role
  apiGroup: rbac.authorization.k8s.io
```

#### Uso em Pipeline

```yaml
# Gerar kubeconfig com service account token
- script: |
    # Extrair token do service account
    TOKEN=$(kubectl get secret \
      $(kubectl get sa brm-deployer -n brm-prd -o jsonpath='{.secrets[0].name}') \
      -n brm-prd -o jsonpath='{.data.token}' | base64 -d)
    
    # Configurar kubectl
    kubectl config set-credentials brm-deployer --token=$TOKEN
    kubectl config set-context brm-prd \
      --cluster=oke-brm-prd \
      --user=brm-deployer \
      --namespace=brm-prd
    kubectl config use-context brm-prd
  displayName: 'Configure kubectl with Service Account'
```

---

## 🌐 Network Security

### Network Architecture

```
                          ┌──────────────────────┐
                          │   Public Internet    │
                          │                      │
                          │   ┌────────────┐     │
                          │   │   Users    │     │
                          │   └──────┬─────┘     │
                          └──────────┼───────────┘
                                     │
                                     │ HTTPS 443
                                     ↓
┌────────────────────────────────────────────────────────────────────┐
│                        OCI - Public Subnet                          │
│                                                                     │
│   ┌─────────────────────┐              ┌─────────────────────┐    │
│   │   Load Balancer     │              │   Bastion Host      │    │
│   │    Public IP        │              │    Public IP        │←───┼──SSH 22
│   └──────────┬──────────┘              └──────────┬──────────┘    │  (Azure DevOps)
└──────────────┼─────────────────────────────────────┼───────────────┘
               │                                     │
               │                                     │ kubectl
               ↓                                     ↓
┌──────────────────────────────────┐  ┌──────────────────────────────────┐
│  OCI - Private Subnet 1          │  │  OCI - Private Subnet 2          │
│  (10.0.1.0/24)                   │  │  (10.0.2.0/24)                   │
│                                  │  │                                  │
│  ┌────────────────┐              │  │  ┌────────────────┐              │
│  │  OKE Nodes     │←─────────────┼──┼─→│  OKE Nodes     │              │
│  └────────┬───────┘              │  │  └────────┬───────┘              │
│           │                      │  │           │                      │
│           │ SQL                  │  │           │ SQL                  │
│           ↓                      │  │           ↓                      │
│  ┌────────────────┐              │  │  ┌────────────────┐              │
│  │   Database     │              │  │  │   Database     │              │
│  │   Primary      │──Replication─┼──┼─→│   Standby      │              │
│  │  10.0.1.100    │              │  │  │  10.0.2.100    │              │
│  └────────────────┘              │  │  └────────────────┘              │
└──────────────────────────────────┘  └──────────────────────────────────┘
```

### Security Lists (Firewall Rules)

#### Public Subnet

```hcl
# Ingress Rules
resource "oci_core_security_list" "public_sl" {
  ingress_security_rules {
    # Load Balancer - HTTPS
    protocol    = "6"  # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 443
      max = 443
    }
  }
  
  ingress_security_rules {
    # Bastion - SSH (restricted to Azure DevOps IPs)
    protocol    = "6"  # TCP
    source      = "20.42.134.0/23"  # Azure DevOps IP range
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 22
      max = 22
    }
  }
  
  # Egress Rules
  egress_security_rules {
    # Allow all outbound (NAT Gateway)
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}
```

#### Private Subnet

```hcl
resource "oci_core_security_list" "private_sl" {
  # Ingress Rules
  ingress_security_rules {
    # OKE API Server (from bastion)
    protocol    = "6"  # TCP
    source      = "10.0.0.0/24"  # Public subnet (bastion)
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 6443
      max = 6443
    }
  }
  
  ingress_security_rules {
    # Database (from OKE nodes)
    protocol    = "6"  # TCP
    source      = "10.0.1.0/24"  # Private subnet 1
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 1521
      max = 1521
    }
  }
  
  # Egress Rules
  egress_security_rules {
    # Allow to same VCN
    protocol         = "all"
    destination      = "10.0.0.0/16"
    destination_type = "CIDR_BLOCK"
  }
}
```

### Network Policies (Kubernetes)

```yaml
# networkpolicy-brm-default-deny.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: brm-prd
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress

---
# networkpolicy-brm-gateway.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: brm-gateway-allow
  namespace: brm-prd
spec:
  podSelector:
    matchLabels:
      app: brm-gateway
  policyTypes:
    - Ingress
    - Egress
  ingress:
    # Allow from Load Balancer
    - from:
        - namespaceSelector: {}
      ports:
        - protocol: TCP
          port: 8080
  egress:
    # Allow to BRM-DM
    - to:
        - podSelector:
            matchLabels:
              app: brm-dm
      ports:
        - protocol: TCP
          port: 8080
    
    # Allow to Database
    - to:
        - podSelector: {}
      ports:
        - protocol: TCP
          port: 1521
    
    # Allow DNS
    - to:
        - namespaceSelector: {}
      ports:
        - protocol: UDP
          port: 53
```

---

## 🐳 Container Security

### Image Scanning (Trivy)

#### Pipeline Integration

```yaml
# Stage: Security Scan
- stage: SecurityScan
  jobs:
    - job: TrivyScan
      steps:
        - script: |
            # Instalar Trivy
            wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
            echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
            sudo apt-get update
            sudo apt-get install trivy
          displayName: 'Install Trivy'
        
        - script: |
            # Scan Docker image
            trivy image \
              --severity HIGH,CRITICAL \
              --exit-code 1 \
              --format json \
              --output trivy-report.json \
              $(DOCKER_REGISTRY)/brm-gateway:$(DOCKER_IMAGE_TAG)
          displayName: '🔍 Trivy Security Scan'
          continueOnError: false
        
        - task: PublishBuildArtifacts@1
          inputs:
            pathToPublish: 'trivy-report.json'
            artifactName: 'trivy-scan'
```

### Dockerfile Hardening

```dockerfile
# ✅ SECURE Dockerfile

# 1. Use specific version (not latest)
FROM eclipse-temurin:17-jre-alpine@sha256:abc123...

# 2. Run as non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# 3. Set working directory
WORKDIR /app

# 4. Copy only necessary files
COPY --chown=appuser:appgroup target/brm-gateway.jar app.jar

# 5. Use read-only filesystem
RUN chmod 555 /app

# 6. Expose only necessary port
EXPOSE 8080

# 7. Health check
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# 8. Run application
ENTRYPOINT ["java", "-jar", "app.jar"]

# 9. Security options (set in deployment.yaml)
# securityContext:
#   runAsNonRoot: true
#   runAsUser: 1000
#   allowPrivilegeEscalation: false
#   readOnlyRootFilesystem: true
#   capabilities:
#     drop:
#       - ALL
```

### Pod Security Standards

```yaml
# pod-security-policy.yaml (deprecated, use Pod Security Admission)
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: brm-restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
  readOnlyRootFilesystem: true
```

---

## 🔍 Code Security

### Static Application Security Testing (SAST)

#### SonarQube Integration

```yaml
# Stage: Code Quality & Security
- stage: CodeAnalysis
  jobs:
    - job: SonarQubeAnalysis
      steps:
        - task: SonarQubePrepare@5
          inputs:
            SonarQube: 'SonarQube-BRM'
            scannerMode: 'CLI'
            configMode: 'manual'
            cliProjectKey: 'brm-fenix'
            cliProjectName: 'BRM Fenix'
            cliSources: 'src'
            extraProperties: |
              sonar.java.binaries=target/classes
              sonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
        
        - script: mvn clean verify sonar:sonar
          displayName: 'Maven Build + SonarQube Analysis'
        
        - task: SonarQubePublish@5
          inputs:
            pollingTimeoutSec: '300'
        
        - script: |
            # Verificar Quality Gate
            QUALITY_GATE=$(curl -s -u $SONAR_TOKEN: \
              "$SONAR_URL/api/qualitygates/project_status?projectKey=brm-fenix" \
              | jq -r '.projectStatus.status')
            
            if [ "$QUALITY_GATE" != "OK" ]; then
              echo "##vso[task.logissue type=error]Quality Gate failed: $QUALITY_GATE"
              exit 1
            fi
          displayName: '✅ Validate Quality Gate'
```

#### Fortify SCA Integration

```yaml
# Stage: Security Scan
- stage: FortifyScan
  jobs:
    - job: FortifyAnalysis
      steps:
        - script: |
            # Fortify SCA scan
            sourceanalyzer -b brm-gateway \
              -jdk 17 \
              mvn clean package -DskipTests
            
            sourceanalyzer -b brm-gateway \
              -scan \
              -f brm-gateway.fpr
          displayName: '🔒 Fortify Security Scan'
        
        - script: |
            # Upload results to Fortify SSC
            fortifyclient uploadFPR \
              -file brm-gateway.fpr \
              -application "BRM Fenix" \
              -applicationVersion "1.0"
          displayName: 'Upload to Fortify SSC'
```

### Dependency Vulnerability Scanning

```yaml
# Stage: Dependency Check
- stage: DependencyCheck
  jobs:
    - job: OWASPDependencyCheck
      steps:
        - script: |
            # OWASP Dependency Check
            dependency-check \
              --project "BRM Fenix" \
              --scan . \
              --format HTML \
              --format JSON \
              --failOnCVSS 7 \
              --suppression dependency-check-suppression.xml
          displayName: '🔍 OWASP Dependency Check'
        
        - task: PublishBuildArtifacts@1
          inputs:
            pathToPublish: 'dependency-check-report.html'
            artifactName: 'dependency-check'
```

---

## 📜 Compliance e Auditoria

### Compliance Frameworks

| Framework | Aplicável | Status | Evidências |
|-----------|-----------|--------|------------|
| **LGPD** | ✅ Sim | ✅ Compliant | Data masking, encryption at rest |
| **PCI-DSS** | ✅ Sim (pagamentos) | ✅ Compliant | Network segmentation, access logs |
| **SOC 2** | ❌ Não | N/A | - |
| **ISO 27001** | ⚠️ Planejado | 🔄 In Progress | Security policies documented |

### Audit Logging

#### Azure DevOps Audit

```bash
# Habilitar Auditing
# Azure DevOps > Organization Settings > Auditing > Enable

# Eventos auditados:
- Pipeline executions (start, complete, approve, cancel)
- Variable group access (view, edit, delete)
- Secure file downloads
- Service connection usage
- RBAC changes (permissions granted/revoked)
```

#### OCI Audit Logs

```bash
# Buscar eventos de compute instance
oci audit event list \
  --compartment-id $OCI_COMPARTMENT_ID \
  --start-time "2025-01-01T00:00:00Z" \
  --end-time "2025-01-31T23:59:59Z" \
  --query 'data[?contains("data.resourceName", `brm`)]'

# Eventos auditados:
- Instance START/STOP actions
- Node pool scaling
- Cluster updates
- IAM policy changes
```

#### Kubernetes Audit

```yaml
# kube-apiserver audit policy
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  # Log all secret access
  - level: RequestResponse
    resources:
      - group: ""
        resources: ["secrets"]
  
  # Log all RBAC changes
  - level: RequestResponse
    resources:
      - group: "rbac.authorization.k8s.io"
        resources: ["roles", "rolebindings", "clusterroles", "clusterrolebindings"]
  
  # Log deployment changes
  - level: Request
    resources:
      - group: "apps"
        resources: ["deployments", "statefulsets", "daemonsets"]
    verbs: ["create", "update", "patch", "delete"]
```

### Data Protection (LGPD)

#### PII Handling

```yaml
# ✅ Dados Pessoais Identificados:
- CPF (customers table)
- Email (customers table)
- Phone (customers table)
- Address (customers table)

# 🔒 Medidas de Proteção:
1. Encryption at Rest (TDE - Transparent Data Encryption)
2. Encryption in Transit (TLS 1.3)
3. Data Masking (non-production environments)
4. Access Control (RBAC - need-to-know basis)
5. Audit Logging (all PII access logged)
6. Retention Policy (delete after 5 years)
```

#### Data Masking Script

```sql
-- Masking para ambiente HML/DEV
CREATE OR REPLACE FUNCTION mask_cpf(cpf VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  RETURN REGEXP_REPLACE(cpf, '(\d{3})(\d{3})(\d{3})(\d{2})', '\1.***.***-\4');
END;
/

UPDATE customers SET
  cpf = mask_cpf(cpf),
  email = CONCAT('user', customer_id, '@example.com'),
  phone = '(11) 9****-****'
WHERE environment = 'HML';
```

---

## 🚨 Incident Response

### Incident Response Plan

```
                   ┌────────────────────┐
                   │ Incident Detected  │
                   └──────────┬─────────┘
                              │
                              ↓
                        ┌───────────┐
                        │Severity?  │
                        └─────┬─────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ↓                     ↓                     ↓
   ┌─────────┐          ┌──────────┐          ┌──────────┐
   │P1-Crit. │          │ P2-High  │          │P3-Medium │
   │Immediate│          │ 4h Resp  │          │24h Resp  │
   └────┬────┘          └─────┬────┘          └────┬─────┘
        │                     │                     │
        │                     │                     │
        └──────────┬──────────┘                     │
                   │                                │
                   ↓                                ↓
            ┌────────────┐                   ┌──────────────┐
            │  War Room  │                   │ Investigation│
            └──────┬─────┘                   └──────┬───────┘
                   │                                │
                   └────────────┬───────────────────┘
                                │
                                ↓
                         ┌─────────────┐
                         │ Containment │
                         └──────┬──────┘
                                │
                                ↓
                         ┌─────────────┐
                         │ Eradication │
                         └──────┬──────┘
                                │
                                ↓
                         ┌─────────────┐
                         │  Recovery   │
                         └──────┬──────┘
                                │
                                ↓
                         ┌─────────────┐
                         │Post-Mortem  │
                         └─────────────┘

Nota: P4-Low (Weekly Review) → Investigation → Containment → ...
```

### Severity Levels

| Priority | Definition | Examples | Response Time | Notification |
|----------|------------|----------|---------------|--------------|
| **P1 - Critical** | Production down, data breach | Database compromised, secrets leaked | Immediate (24/7) | C-Level, Security Team |
| **P2 - High** | Major feature broken, security vulnerability | Payment API down, CVE-2025-XXXX | 4 hours | DevOps Team, Product Owner |
| **P3 - Medium** | Minor feature broken, performance degradation | Reports slow, cache miss rate high | 24 hours | DevOps Team |
| **P4 - Low** | Cosmetic issue, documentation | UI bug, typo in logs | Next sprint | Team backlog |

### Security Incident Playbooks

#### Playbook 1: Suspected Secret Leak

```bash
# 🚨 INCIDENT: Secret leaked in Git commit

# STEP 1: CONTAINMENT (Immediate)
# 1.1. Revoke compromised secret
az keyvault secret set \
  --vault-name kv-brm-fenix \
  --name brm-db-password-prd \
  --value "$(openssl rand -base64 32)"

# 1.2. Force rotation in all systems
kubectl set env deployment/brm-dm \
  DB_PASSWORD="NEW_PASSWORD" -n brm-prd

# STEP 2: ERADICATION (1 hour)
# 2.1. Remove secret from Git history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch config/secrets.yaml" \
  --prune-empty --tag-name-filter cat -- --all

# 2.2. Force push (notify team)
git push origin --force --all

# STEP 3: INVESTIGATION (4 hours)
# 3.1. Check audit logs for secret usage
az monitor activity-log list \
  --resource-id /subscriptions/.../resourceGroups/rg-brm-fenix

# 3.2. Review database access logs
oci audit event list \
  --compartment-id $OCI_COMPARTMENT_ID \
  --start-time "2025-01-15T00:00:00Z"

# STEP 4: POST-MORTEM (1 week)
# Document in: docs/incidents/2025-01-15-secret-leak.md
```

#### Playbook 2: Suspicious Activity in Kubernetes

```bash
# 🚨 INCIDENT: Unexpected pod created in brm-prd namespace

# STEP 1: CONTAINMENT (Immediate)
# 1.1. Delete suspicious pod
kubectl delete pod suspicious-pod -n brm-prd --force

# 1.2. Review recent deployments
kubectl get events -n brm-prd --sort-by='.lastTimestamp'

# STEP 2: INVESTIGATION
# 2.1. Check who created the pod
kubectl get events -n brm-prd \
  --field-selector involvedObject.name=suspicious-pod \
  -o yaml

# 2.2. Review Kubernetes audit logs
kubectl logs -n kube-system kube-apiserver-xxx \
  | grep "suspicious-pod"

# 2.3. Check RBAC permissions
kubectl get rolebindings -n brm-prd -o yaml

# STEP 3: ERADICATION
# 3.1. Revoke compromised credentials
kubectl delete serviceaccount suspicious-sa -n brm-prd

# 3.2. Update RBAC policies
kubectl apply -f rbac-hardened.yaml

# STEP 4: RECOVERY
# 4.1. Verify legitimate workloads
kubectl get pods -n brm-prd -l app=brm-gateway

# 4.2. Restore normal operations
```

---

## 📚 Security Resources

### Internal Documentation

- [Security Policies](./security-policies.md) *(Corporate Security Policies - to be created)*
- [Incident Response Playbooks](./incidents/) *(Corporate IR Playbooks - to be created)*
- [Compliance Checklists](./compliance/) *(Corporate Compliance Docs - to be created)*

### External References

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [Azure DevOps Security Best Practices](https://learn.microsoft.com/azure/devops/organizations/security/)
- [OCI Security Best Practices](https://docs.oracle.com/iaas/Content/Security/Concepts/security_guide.htm)

### Training

- **Security Awareness:** Monthly training (mandatory)
- **Secure Coding:** Quarterly workshops
- **Incident Response:** Yearly drills

---

## 📞 Security Contacts

| Role | Team | Contact |
|------|------|---------|
| **Security Lead** | InfoSec Team | security@vivo.com |
| **DevOps Lead** | BRM Fenix Team | brm-devops@vivo.com |
| **DBA** | Database Team | dba-team@vivo.com |
| **CISO** | Executive | ciso@vivo.com |

**Emergency Hotline:** +55 11 9999-9999 (24/7)

---

**Última Atualização:** 2 de Janeiro de 2026  
**Versão:** 1.1.0  
**Classificação:** CONFIDENCIAL  
**Mantido por:** BRM Fenix Security Team
