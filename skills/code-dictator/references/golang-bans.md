# Golang Backend Dictator Bans

AI agents frequently write "Java-in-Go" boilerplate, leak goroutines, or silently discard errors. Enforce these hard rules:

## 1. Zero Ignored or Unwrapped Errors
- **Banned:** `_ = someFunc()`, `if err != nil { return err }` without context on external boundaries, or `panic()` in library/service code.
- **Required:** Wrap errors with `fmt.Errorf("fetch user %s: %w", id, err)` so call chains remain debuggable. Always check `defer rows.Close()` / `defer resp.Body.Close()` errors or handle explicitly.

## 2. Bounded Concurrency & Context Propagation
- **Banned:** Fire-and-forget `go func() { ... }()` without lifecycle ownership, or creating `context.Background()` / `context.TODO()` inside HTTP/gRPC request paths.
- **Required:** Pass `ctx context.Context` as the first parameter of every I/O function. Use `golang.org/x/sync/errgroup` (`errgroup.WithContext(ctx)`) for concurrent fan-out and always `defer cancel()` after `context.WithTimeout` / `context.WithCancel`.

## 3. Ban Premature Interfaces & `any` Abuse
- **Banned:** Defining `type UserService interface { ... }` in the producer package when only one struct implements it (AI loves generating Java-style interfaces everywhere), or using `interface{}` / `any` where generics or concrete structs work.
- **Required:** Accept interfaces, return concrete structs. Define small interfaces at the consumer site only when needed for mocking or multiple implementations.

## 4. Package Boundary Isolation (`depguard`)
- `internal/domain` must never import `internal/transport`, `database/sql`, or external HTTP SDKs.
- Enforce import boundaries in `.golangci.yml` via `depguard`.
