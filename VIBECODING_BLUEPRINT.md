# Agent Revival v6 - VibeCoding Blueprint

## Project Overview
Continue the supplied Agent Revival v6 source and repair error 1026 by removing service-role dependence, enforcing scoped backend access, and preserving the existing user experience.

## Three Design Directions
### Direction 1: Existing resilient workspace
**Summary:** Keep the current dense dark application shell and focus changes on backend reliability.
**Probability:** 0.90

### Direction 2: Simplified operations console
**Summary:** Reduce visual density while retaining the same session workflow.
**Probability:** 0.07

### Direction 3: Light developer workbench
**Summary:** Move to a restrained light interface with equivalent functionality.
**Probability:** 0.03

## Selected Direction: Existing resilient workspace
The request is a functional continuation and bug fix, so preserving the established interface minimizes risk and keeps effort focused on the failing backend path.

## Design Principles
- Preserve the existing v6 interaction model.
- Prefer explicit recovery states over generic connection failures.
- Keep credentials and privileged access server-side.
- Make startup and reconnect behavior deterministic.

## Color Philosophy
- Preserve the existing charcoal workspace and violet/teal status accents.
- Use red only for actionable failures and warnings.

## Layout Paradigm
- Preserve the existing left session rail and main chat workspace.
- Keep setup in a focused modal.
- Do not redesign unrelated screens during the repair.

## Interaction Philosophy
- Keep session creation and navigation immediate.
- Preserve background-run reconciliation behavior.
- Distinguish browser connectivity from backend request failure.

## Typography System
- Preserve the existing compact sans-serif application hierarchy.
- Use monospace only for model names, identifiers, and technical status details.

## Page Structure
### 1. Agent workspace
Persistent session rail, active conversation, status banners, and session setup dialog.

### 2. Access flow
Authentication and callback handling required for scoped backend ownership.

## First Version Implementation Scope
- Import and preserve the supplied v6 UI and session workflow.
- Replace service-role database access with authenticated request-scoped access.
- Update schema grants and RLS policies for ownership enforcement.
- Improve startup error classification and retry behavior.
- Run tests, production build, and browser verification.

## Acceptance Criteria
- The site loads without error code 1026.
- A new session can be created without a service-role key.
- Existing session listing, snapshots, messaging, and archiving remain functional.
- Database access is restricted to the current authenticated workspace identity.
- The production worker build passes source-policy and runtime checks.

## Enhancement Suggestions
### Diagnostic recovery state
- **Category:** Reliability
- **Description:** Show a precise retryable backend status when session loading is temporarily unavailable instead of treating every failure as an offline browser.
- **Recommended:** Yes
- **Requires backend:** No
- **Implementation notes:** Classify server-function failures and expose a retry action without leaking backend details.

### Encrypted provider credentials
- **Category:** Security
- **Description:** Encrypt provider API keys at rest rather than storing plaintext values in the session row.
- **Recommended:** No
- **Requires backend:** Yes
- **Backend modules:** server_functions.secure_action, database.crud
- **Implementation notes:** Use a secure server function and deployment secret to seal/unseal provider keys.

### Stale run recovery
- **Category:** Workflow
- **Description:** Add a safe reconnect action for sessions left in a running state after a worker interruption.
- **Recommended:** No
- **Requires backend:** Yes
- **Backend modules:** database.crud, server_functions.secure_action
- **Implementation notes:** Detect stale running timestamps and allow an explicit status reconciliation.

### Request correlation IDs
- **Category:** Observability
- **Description:** Attach a short request correlation ID to user-facing failures for easier diagnosis.
- **Recommended:** No
- **Requires backend:** No
- **Implementation notes:** Generate IDs in server functions, log them server-side, and return only the ID and safe message.

## Backend Recommendation
Provision a real backend with modules: auth.email_password, database.crud, server_functions.secure_action.

<!-- ottermind:vibecoding-blueprint-decision:start -->
## Generation Confirmation Record

Status: Pending user confirmation
- Backend mode: Pending
- Login/auth: Pending
- Database persistence: Pending
- File upload/storage: Pending
- Selected enhancements: Pending
- Choice: Pending
- Source: Pending
- Updated at: Pending
<!-- ottermind:vibecoding-blueprint-decision:end -->
