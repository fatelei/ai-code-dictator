# Rust Backend & Systems Dictator Bans

As Lauren Tan highlighted, Rust's strict compiler and borrow checker make it ideal for AI-driven development—**provided you forbid `unsafe` and ban panic-inducing shortcuts**. Enforce these hard rules:

## 1. Forbid `unsafe` Code (`unsafe_code = "forbid"`)
- **Banned:** Any `unsafe { ... }` block or `unsafe fn` in application and service crates.
- **Required:** Use safe standard library or audited crate abstractions. If FFI is strictly unavoidable, isolate it in a dedicated micro-crate with `// SAFETY:` proofs reviewed by a human.

## 2. Zero `.unwrap()`, `.expect()`, or `panic!()` in Production Paths
- **Banned:** `.unwrap()`, `.expect(...)`, `panic!(...)`, `todo!()`, `unimplemented!()`, and `dbg!()` outside `#[cfg(test)]` modules (AI agents constantly use `.unwrap()` as a shortcut to bypass `Result`/`Option` handling).
- **Required:** Propagate errors with `?`, domain `thiserror` enums in libraries, or `anyhow::Context` at application boundaries. Use `.ok_or_else(...)` for `Option` to `Result` conversions.

## 3. Ban Borrow-Checker Pacification via `.clone()` Spam
- **Banned:** Reflexively calling `.clone()` on `String`, `Vec`, or large structs just to silence borrow checker errors, or wrapping everything in `Arc<Mutex<T>>` without shared cross-task mutation need.
- **Required:** Borrow slices (`&str`, `&[T]`), pass references (`&T`), or transfer ownership cleanly.

## 4. Async Runtime Hygiene (Tokio)
- **Banned:** Blocking calls (`std::fs`, `std::thread::sleep`, synchronous mutexes held across `.await`) inside `async fn`.
- **Required:** Use `tokio::fs`, `tokio::time::sleep`, `tokio::task::spawn_blocking` for CPU-bound work, and bounded `tokio::sync::mpsc::channel(capacity)` instead of unbounded channels.

## 5. Complexity & Size Ceilings
- Maximum function length: **50 lines**; cognitive complexity <= **12**; maximum nesting depth: **3 levels** (use `let ... else` early returns).
