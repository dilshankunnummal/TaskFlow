# TaskFlow — Dependency Reference

## Runtime

| Package | Why it's here |
|---|---|
| `flutter_bloc` | Bloc/Cubit state management for every feature list/detail screen (initial/loading/success/empty/error). |
| `equatable` | Value equality for Bloc states, events, and entities without boilerplate `==`/`hashCode`. |
| `get_it` | Service locator backing dependency injection across data/domain/presentation layers. |
| `injectable` | Annotation-driven codegen layer over `get_it`, so feature modules register themselves declaratively. |
| `go_router` | Declarative, URL-based routing with typed paths (`/projects/:projectId`, etc.). |
| `freezed_annotation` | Marks immutable model/entity classes for the `freezed` code generator (unions, copyWith, equality). |
| `json_annotation` | Marks model fields for `json_serializable` so datasource models map cleanly to/from the mock JSON (and later REST JSON). |
| `flutter_secure_storage` | Encrypted at-rest storage for auth tokens — passwords are never stored, tokens never logged. |
| `hive` / `hive_flutter` | Lightweight local cache for last-successful project/task data used in the offline "may be stale" state. |
| `shared_preferences` | Small key-value store for non-sensitive app preferences (theme mode, debug offline toggle). |
| `google_fonts` | Loads Inter for the typography scale without bundling font files manually. |
| `intl` | Date/time formatting used by `DateFormatter`. |
| `uuid` | Generates stable local IDs for mock-created entities before a backend would assign one. |
| `connectivity_plus` | Real device connectivity signal feeding `NetworkInfo` / `ConnectivityCubit`. |

## Dev / Tooling

| Package | Why it's here |
|---|---|
| `bloc_test` | Bloc/Cubit unit testing (`blocTest`) covering state sequences. |
| `mocktail` | Mocking repositories/datasources in unit tests without code generation. |
| `build_runner` | Runs the `freezed` / `json_serializable` / `injectable_generator` / `hive_generator` generators. |
| `freezed` | Generates immutable data classes, unions, and `copyWith` for models/entities. |
| `json_serializable` | Generates `fromJson`/`toJson` for data-layer models. |
| `injectable_generator` | Generates `injection.config.dart` from `@injectable`/`@module` annotations added per feature. |
| `hive_generator` | Generates Hive `TypeAdapter`s for cached models. |
| `flutter_lints` | Baseline lint set, tightened in `analysis_options.yaml`. |

## Notes

- No HTTP client is included yet by design — the `data` layer only talks to `MockJsonLoader` today. When a real API is introduced, add `dio` or `http` behind the existing repository interfaces; nothing in `domain` or `presentation` needs to change.
- `dartz`/`fpdart` were intentionally **not** added — `core/error/result.dart` defines a small sealed `Result<T>` (`Success` / `ResultFailure`) that serves the same purpose as `Either<Failure, T>` without the extra dependency.
