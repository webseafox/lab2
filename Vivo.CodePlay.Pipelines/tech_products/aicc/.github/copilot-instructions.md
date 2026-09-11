# AICC Coding Standards

Apply these rules to every code change, new file, refactor, and bug fix.

---

## Universal Rules

### Code Quality

- LBYL over EAFP: check conditions before executing; make the happy path explicit.
- Functions must have a single responsibility and stay small. Avoid long parameter lists.
- Write no comments. If a comment feels necessary, rename or restructure the code instead.
- No magic numbers. No dead code. Meaningful names throughout.
- Use classes when there is state or associated behavior. Apply SOLID where the domain justifies it.

### Dependencies

- Pin exact versions for new dependencies (`requirements.txt`, `pyproject.toml`, `package.json`). No `^`, `~`, or `>=`.
- Do not tighten existing version ranges on unrelated PRs.
- Production dependencies go in `dependencies`; dev tools go in `devDependencies` / `dev` group.

### Changes

- Keep changes as small and self-contained as possible. Unit tests travel with the code change they cover.

### Testing

- Follow FIRST: Fast, Independent, Repeatable, Self-validating, Timely.
- Structure each test as Arrange → Act → Assert.
- One concept per test. No branching (`if`/`for`) inside tests.
- Test behavior, not implementation. Do not reach into private methods or internals.
- Mock only uncontrolled external dependencies (third-party APIs, databases, filesystem, time).
- Reset mock state between tests.
- Semantic test names that describe the scenario and expectation.

### Logging

- Log only what the runtime does not already emit: business-meaningful events, decisions, fallback paths, recoverable failures.
- Log message must be a constant string. Variable data goes as structured fields, never interpolated into the message.
- One log call per event. Levels: DEBUG (dev only) / INFO (notable events) / WARN (recoverable) / ERROR (needs review) / FATAL (process must stop).
- Keep non-DEBUG logs lean. Never include large payloads at INFO or above.

### API Design

- Define the OpenAPI 3.1 (or AsyncAPI) spec before implementing. Generate server code from it.
- All paths include the version: `/api/v1/...`.
- Path segments: kebab-case. Path params and query params: snake_case. Schema components: PascalCase.
- Listing endpoints use page-based pagination (`page`, `size`, `sort`). Response envelope: `{ pagination: {...}, items: [...] }`.
- All API and DB fields use snake_case. Acronyms go lowercase (`isbn`, `url`, `api_key`). Dates in ISO 8601 UTC with `Z` suffix.
- Group internal fields into a `metadata` object; omit it from consumer-facing responses by default.

### Error Handling

- Operational errors (network, validation, not-found) → handle gracefully.
- Programming errors (bugs) → fail fast, let them surface.
- Do not scatter try/catch. Let errors propagate to a central handler. Only intercept locally when retrying, enriching, or transforming.
- Always preserve the stack trace when re-throwing.
- Reuse existing error types before creating new ones. Create a subtype only when you need to catch it selectively or carry context the existing type cannot.

### HTTP Error Responses

- All HTTP errors follow RFC 7807 (`application/problem+json`). Use the SDK error classes — never build the envelope manually or set status codes by hand.

### Environment Variables

Standard names for shared infrastructure: `APP_HOST`, `APP_PORT`, `APP_PRE_SHUTDOWN_WAIT_MS`, `LOG_LEVEL`, `MONGODB_URI`, `MONGODB_USERNAME`, `MONGODB_PASSWORD`, `MONGODB_SSL_ENABLED`, `REDIS_HOST`, `REDIS_PORT`, `REDIS_USERNAME`, `REDIS_PASSWORD`, `REDIS_TLS_ENABLED`. Do not redeclare variables the SDK already parses.

Group config into a nested schema by domain. Never flatten everything into one object.

---

## Team Libraries and Templates

Before implementing any cross-cutting concern from scratch, check whether a team library covers it. Local checkouts: `../aicc-platform-utilities` (libs) and `../aicc-platform-templates` (templates).

- **Python** (`aicc-platform-utilities/python/`): `vvia-sdk-ai-core-api` (HTTP bootstrap), `vvia-sdk-ai-fastapi-codegen` (OpenAPI→FastAPI scaffold), `vvia-sdk-ai-obs` (logging+OTel), `vvia-sdk-ai-persistence` (MongoDB), `vvia-sdk-ai-pubsub` (Event Hubs).
- **TypeScript** (`aicc-platform-utilities/typescript/`): `@vvia/sdk-ai-core-api` (HTTP bootstrap), `@vvia/sdk-ai-fastify-codegen` (OpenAPI→Fastify scaffold), `@vvia/eslint-config-vvia` (shared ESLint — extend, do not override), `@vvia/sdk-ai-async` (Service Bus workers), `@vvia/sdk-ai-common` (Node.js utils+DI), `@vvia/sdk-ai-obs` (OTel+Pino), `@vvia/sdk-ai-persistence` (MongoDB), `@vvia/sdk-ai-pubsub` (Event Hubs), `@vvia/sdk-ai-ui` (frontend utils).
- **Templates** (`aicc-platform-templates/`): start every new project from the canonical template — never scaffold from scratch. Python: `example-api-python-package` (API), `library-template` (lib). TypeScript: `api-template` (API), `library-template` (lib).

---

## Python

**Toolchain:** Python 3.13, `uv`, `poe`, `ruff`, `mypy`, FastAPI, `pytest` + `pytest-asyncio`.

**Validation:** `uv run poe validate` (mypy → ruff → pytest). Run before considering any task done.

### Naming

- Variables, functions: `snake_case`. Classes: `PascalCase`. Constants: `UPPER_CASE`.
- Protected members: `_single_underscore`. Private members: `__double_underscore`.

### Style

- One import per line. Order: stdlib → third-party → local. Never `from module import *`.
- Prefer keyword arguments over positional for clarity.
- Type hints required on all function/method signatures. Use `list[str]`, `dict[str, int]` (Python 3.10+ style). Avoid `Any`.

### Class Structure

Order class members: class constants → public class variables → protected class variables → private class variables → private methods → protected methods → `__new__` / `__init__` → magic methods → static methods → class methods → public methods → properties.

### Configuration

Use `pydantic-settings`. One nested `BaseSettings` per logical area. Use `SettingsConfigDict` with `env_prefix`, `env_nested_delimiter='__'`, `extra='ignore'`. Attributes use `snake_case`. Use `field_validator` for normalization.

### HTTP Service

Use `vvia-sdk-ai-core-api` (`ApiService.builder()`). Do not reimplement bootstrap, logging, OTel, DI, error handling, or the liveness endpoint.

Error hierarchy: `ApiError → ClientError (BadRequestError, ValidationError, UnauthorizedError, ForbiddenError, NotFoundError, ConflictError, TooManyRequestsError) | ServerError (NotImplementedFeatureError, ExternalServiceError, ServiceUnavailableError)`.

### Error Handling in Business Logic

Return a `(data, error)` tuple for expected recoverable failures. The caller checks for the error before using the data (LBYL). For critical failures, raise exceptions and preserve context with `raise MyError("msg") from original_err`. Use `e.add_note(...)` to enrich an exception without wrapping it.

### Testing

Use `pytest`. Prefer class-based test organization. One test file per source file. All test types for a module go in the same file. Tests must cover functionality and edge cases.

### Project Structure

Deployable services: `<package_name>/` at the project root (snake_case), with `main.py`, `settings.py`, `providers.py`, `api/`, `services/`, and a `tests/` directory mirroring the package.

Reusable libraries: use src-layout (`src/<package_name>/`). `__init__.py` is the only public surface.

---

## TypeScript (Backend)

**Toolchain:** Node.js 22 LTS, TypeScript `~5.9.x`, `npm`, ESLint 9 + `@vvia/eslint-config-vvia`, Prettier, Jest + ts-jest.

**Module system:** CommonJS (`"type": "commonjs"`). Do not switch to ESM.

**Validation:** `npm run validate` (typecheck → lint → test). Run before considering any task done.

### Naming

- Files and folders: `kebab-case`. Classes and interfaces: `PascalCase` (no `I` prefix). Functions and variables: `camelCase`. Constants: `UPPER_SNAKE_CASE`.

### TypeScript Config

`strict: true` is non-negotiable. Never use `any`; use `unknown` and narrow explicitly. Treat compiler warnings as real problems.

### ESLint Rules (enforced by `@vvia/eslint-config-vvia`)

- `complexity: 8` — refactor when exceeded.
- One class per file.
- Every Promise must be awaited or explicitly handled.
- Do not mutate function parameters.
- Use the injected logger (`LoggerToken`), never `console.log`.
- JSDoc required on every `FunctionDeclaration`, `MethodDefinition`, and `FunctionExpression` — include `@param` and `@returns`.

### HTTP Service

Use `@vvia/sdk-ai-core-api` (`ApiService.builder()`). Do not reimplement bootstrap, Pino logging, OTel, DI, error handling, or graceful shutdown.

Throw via `ApiError` static factories: `.badRequest`, `.validationError`, `.unauthorized`, `.forbidden`, `.notFound`, `.tooManyRequests`, `.internal`, `.notImplemented`, `.serviceUnavailable`. Never build the JSON envelope manually.

Inject dependencies via tsyringe. Use `LoggerToken` for the logger and `ConfigToken` for parsed config. Resolve request-scoped dependencies via `request.ctx(Token)`.

### Error Handling in Business Logic

Use `Result<T, E> = { success: true; data: T } | { success: false; error: E }` with `ok()` / `err()` helpers for expected recoverable failures. The caller checks `result.success` before using the data. For critical failures, let exceptions propagate. Preserve the cause: `new Error("msg", { cause: originalErr })`.

### Testing

Tests live in `__test__/unit/`, mirroring `src/`. One test file per source file. `describe` and `it` descriptions in English, conditional form. `clearMocks: true` resets mocks between tests automatically. Use `test.each` for data-driven cases.

### Project Structure

Services: `src/` with `index.ts`, `instrumentation.ts`, `configuration.ts`, `types.ts`, and `api/<feature>/` grouping router + services/DAOs. Tests in `__test__/unit/` mirroring `src/`.

Libraries: `src/index.ts` is the only public surface. Consumers must not import from deep paths.
