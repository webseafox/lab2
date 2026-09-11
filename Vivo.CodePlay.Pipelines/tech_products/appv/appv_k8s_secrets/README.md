# Pipeline: Kubernetes Sealed Secrets

This pipeline creates secrets in Kubernetes and seals them using Sealed Secrets for secure storage and GitOps integration.

## Features

- Creates generic secrets in Kubernetes
- Seals secrets using Sealed Secrets Controller (kubeseal)
- Publishes sealed secrets to GitOps repository
- Supports multiple environments (pre-production, production)
- Validation mode (dry-run) for testing without changes

- **General secrets**: Supports shared secrets without app association
- **Merge support**: Add new keys to existing secrets

## Parameters

### Required Parameters

| Parameter           | Type   | Description                                                |
| ------------------- | ------ | ---------------------------------------------------------- |
| `targetEnvironment` | string | Target namespace/environment (e.g., `dev`, `prod-ms`)      |
| `secretName`        | string | Full secret name (e.g., `fb-app-vivo-benefits-ms-secrets`) |
| `secretsJson`       | string | JSON object with key-value pairs (see format below)        |

### Optional Parameters

| Parameter              | Type    | Default | Description                                                               |
| ---------------------- | ------- | ------- | ------------------------------------------------------------------------- |
| `gitRepoName`          | string  | `""`    | Repository name (loads variable group). If empty, creates general secret. |
| `overrideExistingKeys` | boolean | `false` | If `true`, overwrite existing keys. If `false`, skip them.                |
| `dryRun`               | boolean | `false` | Run validation only, no changes applied                                   |

## Secret Types

| Type         | `gitRepoName` | GitOps Path                                  | Use Case                            |
| ------------ | ------------- | -------------------------------------------- | ----------------------------------- |
| App-specific | Provided      | `src/{environment}/apps/{app_name}/secrets/` | Secrets belonging to a specific app |
| General      | Empty         | `src/{environment}/secrets/`                 | Shared secrets, infrastructure      |

## Merge Behavior

When a secret already exists:

| Input Key Status | `overrideExistingKeys=false` | `overrideExistingKeys=true` |
| ---------------- | ---------------------------- | --------------------------- |
| Key is NEW       | ADD                          | ADD                         |
| Key EXISTS       | SKIP (keep old value)        | OVERRIDE (use new value)    |

## Secrets Format

The `secrets` parameter accepts a **JSON object** with key-value pairs:

```json
{
  "DATABASE_URL": "postgres://localhost:5432/app",
  "API_KEY": "abc123",
  "JWT_SECRET": "my-secret-key"
}
```

## Usage

### Example: Input in Azure DevOps UI

#### App-Specific Secret

| Parameter              | Value                                                             |
| ---------------------- | ----------------------------------------------------------------- |
| Target Environment     | `preprod-ms`                                                      |
| Git Repository Name    | `src.src-fb-app-vivo-benefits-ms`                                 |
| Secret Name            | `fb-app-vivo-benefits-ms-secrets`                                 |
| Secrets JSON           | `{"DATABASE_URL":"postgres://db:5432/app","API_KEY":"secret123"}` |
| Override Existing Keys | `false`                                                           |
| Dry Run                | `false`                                                           |

**Result**: Secret saved to `src/preprod-ms/apps/fb-app-vivo-benefits-ms/secrets/fb-app-vivo-benefits-ms-secrets-sealed.yml`

#### General Secret

| Parameter              | Value                                                   |
| ---------------------- | ------------------------------------------------------- |
| Target Environment     | `prod-ms`                                               |
| Git Repository Name    | _(leave empty)_                                         |
| Secret Name            | `shared-database-secrets`                               |
| Secrets JSON           | `{"POSTGRES_PASSWORD":"secret","REDIS_URL":"redis://"}` |
| Override Existing Keys | `false`                                                 |
| Dry Run                | `false`                                                 |

**Result**: Secret saved to `src/prod-ms/secrets/shared-database-secrets-sealed.yml`

### Example: Adding a New Key to Existing Secret

If secret `fb-app-vivo-benefits-ms-secrets` already has keys `DB_URL` and `API_KEY`:

| Parameter              | Value                     |
| ---------------------- | ------------------------- |
| Secrets JSON           | `{"NEW_VAR":"new-value"}` |
| Override Existing Keys | `false`                   |

**Result**: Secret now has `DB_URL`, `API_KEY`, and `NEW_VAR`. Original keys unchanged.

### Example: Updating an Existing Key

| Parameter              | Value                       |
| ---------------------- | --------------------------- |
| Secrets JSON           | `{"API_KEY":"new-api-key"}` |
| Override Existing Keys | `true`                      |

**Result**: `API_KEY` is updated to `new-api-key`. Other keys unchanged.

## GitOps Repository Structure

Sealed secrets are committed with the following naming convention:

**File naming**: `{secretName}-sealed.yml`

### App-Specific Secrets (gitRepoName provided)

```
src/{environment}/apps/{app_name}/secrets/{secretName}-sealed.yml
```

### General Secrets (gitRepoName empty)

```
src/{environment}/secrets/{secretName}-sealed.yml
```

The pipeline automatically selects the correct GitOps repository:

- **Pre-Production**: `infra.infra-devops-aks-preprod`
- **Production**: `infra.infra-devops-aks-prod` (for `prod-*` or `darklaunch-*` environments)
