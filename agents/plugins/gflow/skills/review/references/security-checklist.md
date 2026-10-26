# Security checklist (OWASP Top 10:2025)

Load this file in the security lens. Walk the diff against each category, and report every finding against its category ID (for example `A01`) with the usual claim, scenario, and evidence.

Only report what the diff makes visible. Where the answer depends on infrastructure, runtime state, or code outside the change, say so in the finding's evidence or in the coverage notes. Update this list deliberately when OWASP publishes a new edition.

First find how the project already does each thing (authorization, authentication, crypto, logging, input handling), then compare the change to it. A new path that departs from the project's established mechanism is the strongest signal.

## A01 Broken access control (includes SSRF)

- Endpoints, queries, jobs, channels, and exports that skip the check their siblings perform
- Lookups by ID with no ownership or tenant scope (IDOR); list, search, and aggregate queries not scoped to the viewer
- Checks done in the UI or client but not on the server; function-level checks missing on admin or internal routes
- Privilege escalation through role, ownership, or parameter changes; mass assignment of protected fields
- Responses, serializers, errors, logs, webhooks, events, and caches that expose more than the viewer may see
- Server-side requests to a URL the user influences (SSRF): allowlists, internal address and metadata endpoint access, redirects
- CORS, CSRF, and path or file access that let one user reach another's data

## A02 Security misconfiguration

- Debug or verbose modes, default or sample credentials, and unsafe defaults that reach production
- Permissive CORS, missing security headers, cookies without `Secure`, `HttpOnly`, or `SameSite`
- TLS or certificate verification disabled, wildcard IAM or bucket policies, open ports, admin interfaces exposed
- Security-relevant settings added in code but not declared where the project declares configuration (see the configuration lens)

## A03 Software supply chain failures

- New or changed dependencies: necessity, maintenance, popularity, and name similarity to well-known packages (typosquatting)
- Version ranges and unpinned versions, lockfile changes that do not match manifest changes, registries or sources that changed
- Install or build scripts, vendored binaries, and code fetched at build or run time
- CI/CD changes: broadened token or workflow permissions, unpinned third-party actions, secrets exposed to forks or untrusted input, new deploy steps

## A04 Cryptographic failures

- Weak or obsolete algorithms, unsalted or fast hashes for passwords, home-grown crypto, ECB mode, static or reused IVs and nonces
- Hardcoded keys or secrets, keys committed or logged, weak key derivation
- Predictable randomness where unpredictability matters (tokens, IDs, resets)
- Sensitive data stored or transmitted in plaintext, missing TLS, sensitive data in URLs or caches

## A05 Injection

- SQL, NoSQL, OS command, template, LDAP, and header injection: string-built queries or commands from untrusted input
- Cross-site scripting: unescaped output, `innerHTML`, `dangerouslySetInnerHTML`, unsafe URL schemes, rendering of user content
- Path traversal and unsafe file operations; unvalidated redirects; XML external entities
- Validation done on the wrong side of a trust boundary or after use

## A06 Insecure design

- Abuse cases: missing rate limits, enumeration, brute force, replay, and resource exhaustion on new endpoints or flows
- Business-logic flaws: skipped steps, race conditions on balances, quotas, or state transitions, trust in client-supplied prices, roles, or state
- Missing separation of duties, missing re-authentication for sensitive actions, and security decisions that rest on a single check
- Data collected or retained beyond what the feature needs

## A07 Authentication failures

- Session handling: fixation, missing rotation or invalidation on login, logout, and password change; predictable or long-lived tokens
- Token and JWT validation: signature, algorithm, expiry, audience, and issuer checks
- Credential handling: password storage and policy, reset and recovery flows, MFA bypass, credential stuffing exposure, account enumeration through messages or timing
- Authentication state trusted from client input or headers that a caller can set

## A08 Software or data integrity failures

- Deserialization of untrusted data and unsafe object loading
- Updates, plugins, or artifacts fetched or run without integrity verification
- Data from other systems, queues, or the client trusted without validation or signature checks
- Build and deploy paths that let unreviewed code reach production

## A09 Logging and alerting failures

- Security-relevant events not recorded: authentication results, access-control denials, privilege changes, sensitive operations
- Logs missing the context needed to investigate (who, what, when, from where), or open to injection through unsanitized input
- Sensitive data, tokens, or personal information written to logs
- Failures that are swallowed silently so nothing can alert on them

## A10 Mishandling of exceptional conditions

- Failing open: an error, timeout, or missing value that grants access or skips a check
- Exceptions that leak internals to the caller, or leave state half-written, locks held, or resources unreleased
- Unhandled paths on malformed, empty, oversized, or unexpected input, and resource exhaustion through repeated errors
- Catch-all handlers that hide security-relevant failures, and retries that repeat a non-idempotent action
