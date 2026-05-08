# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

行程DIY规划 (Trip DIY Planner) — a full-stack trip planning app. Java/Spring Boot 3.2 backend + Vue 3/TypeScript frontend.

## Build & Run

### Server (`trip-planner-server/`)

```bash
# Run with dev profile (requires MySQL at localhost:3306/trip_planner)
cd trip-planner-server && mvn spring-boot:run -Dspring-boot.run.profiles=dev

# Run tests
cd trip-planner-server && mvn test

# Package
cd trip-planner-server && mvn package -DskipTests
```

### Web (`trip-planner-web/`)

```bash
cd trip-planner-web && npm run dev      # Dev server on :3000, proxies /api to :8080
cd trip-planner-web && npm run build    # Type-check + production build
cd trip-planner-web && npm run preview  # Preview production build
```

## Architecture

### Backend (`com.tripplanner`)

Three-layer modular architecture under `module/`:
- **Controller** (`@RequestMapping`) → **Service** (interface + `impl/`) → **Mapper** (MyBatis-Plus)
- Each module has its own `entity/` and `dto/` packages

**Modules:** `auth`, `trip`, `day`, `item`, `transport`, `budget`, `checklist`, `export`, `user`

All endpoints are under `/api/v1/` and return `Result<T>` wrappers (code, message, data). Authenticated endpoints get the current user via `UserContextHolder.getUserId()` (ThreadLocal, set by JWT filter).

**Key patterns:**
- All entities extend `BaseEntity` (id, createTime, updateTime, deleted — soft delete via MyBatis-Plus)
- Ownership validation: every service checks the authenticated user owns the resource before operating
- Item sortOrder uses gaps of 1000 to allow insertions without full reindexing
- Transport connectors exist only between adjacent items in a day; reordering automatically prunes non-adjacent transports
- JWT stateless auth: Bearer token in localStorage, injected by Axios interceptor; `POST /api/v1/auth/**` is public

**Config files:** `application.yml` (common), `application-dev.yml`, `application-prod.yml`

### Frontend (`trip-planner-web/src/`)

- **Router** (`router/index.ts`): lazy-loaded routes, navigation guard checks token for non-public routes
- **Stores** (Pinia): `user` (auth state, persisted), `trip` (current trip), `planner` (days/items/transports)
- **API layer** (`api/`): Axios instance with interceptors that unwrap `Result.data` on success; typed API functions per module
- **Views**: `PlannerView` is the most complex — day tabs, drag-and-drop item list, transport connectors, side summary

**UI framework:** Element Plus (Chinese locale), with vuedraggable + SortableJS for drag-and-drop reordering.

**Path alias:** `@/` → `src/` (configured in both `vite.config.ts` and `tsconfig.json`)

### Database

MySQL database `trip_planner`. Tables: `user`, `trip`, `trip_day`, `trip_item`, `item_transport`, `checklist`. All tables use logical delete (`deleted` column).
