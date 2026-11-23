# Java / Spring Boot Backend Dictator Bans

AI agents love generating verbose Spring boilerplate, swallowing checked exceptions, and hiding transactional bugs. Enforce these hard rules:

## 1. Constructor Injection Only (Ban Field Injection)
- **Banned:** `@Autowired` on fields (breaks immutability, hides dependencies, complicates unit testing).
- **Required:** `private final` fields with constructor injection (or Lombok `@RequiredArgsConstructor`).

## 2. Zero Exception Swallowing or `printStackTrace`
- **Banned:** Empty `catch (Exception e) {}`, `e.printStackTrace()`, or catching generic `Throwable`/`Exception` without rethrowing a domain exception.
- **Required:** Catch specific exceptions, log once at the boundary with structured context (`log.error("Failed orderId={}", orderId, e)`), and wrap with a meaningful domain exception.

## 3. Transaction & Persistence Pitfalls
- **Banned:** Calling a `@Transactional` method from another method inside the same class (`this.saveOrder()` bypasses Spring AOP proxy), database queries inside `for` loops (N+1), or returning JPA `@Entity` objects directly from REST controllers.
- **Required:** Map entities to immutable Java `record` DTOs at the service/controller boundary. Use `JOIN FETCH` or batch queries.

## 4. Modern Java & Complexity Ceilings
- Prefer Java `record` for immutable DTOs/value objects, `Optional` return types instead of returning `null` collections, and `Objects.requireNonNull` at boundaries.
- Maximum method length: **50 lines**; maximum nesting depth: **3 levels** (guard clauses first); cyclomatic complexity <= **10**.
