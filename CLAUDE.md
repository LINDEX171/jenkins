# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Educational Jenkins CI/CD project (ICDE848 course) implementing a Java online store order management system. Pure Java 17, Maven build, no web framework.

## Build Commands

```bash
# Compile only
mvn clean compile -B

# Unit tests only (*Test.java via Surefire)
mvn clean test -B

# Integration tests only (*IT.java via Failsafe, skips unit tests)
mvn verify -Dsurefire.skip=true -B

# Unit + integration tests + JaCoCo coverage report
mvn clean verify -B

# Code quality analysis (individual)
mvn checkstyle:checkstyle
mvn pmd:pmd pmd:cpd
mvn spotbugs:spotbugs

# Full build (mirrors what Jenkinsfile runs)
mvn clean verify checkstyle:checkstyle pmd:pmd pmd:cpd spotbugs:spotbugs -B
```

Quality reports are generated to `target/`: `checkstyle-result.xml`, `pmd.xml`, `cpd.xml`, `spotbugsXml.xml`.

## Architecture

Three-layer structure under `src/main/java/fr/epsi/`:

- **Model layer** (`model/`): `Article` (nom, prix) and `Panier` (Map<Article, Integer>)
- **Service layer** (`service/`): `CommandeService` with three methods:
  - `calculerTotal(Panier)` – sums price × quantity; throws if empty/null
  - `appliquerRemise(double total, int pct)` – applies % discount (0–100); throws if invalid
  - `categoriserCommande(double total)` – returns `"PETITE"` (<50€), `"MOYENNE"` (50–199€), or `"GRANDE"` (≥200€)

Tests under `src/test/java/fr/epsi/service/`:
- `CommandeServiceTest.java` – 11 unit tests (method isolation)
- `CommandeServiceIT.java` – 3 integration tests (full pipeline: panier → total → discount → category)

JaCoCo enforces a **70% minimum line coverage**; the build fails if not met.

## Code Style (checkstyle.xml)

- Max line length: 120 characters
- Max method length: 50 lines
- Max parameters: 7
- Naming: PascalCase for classes, camelCase for methods/variables, SCREAMING_SNAKE_CASE for constants
- No empty catch blocks, no wildcard imports, no unused imports
- Braces required even for single-line blocks (Java standard style)
- Overriding `equals()` requires overriding `hashCode()`

## Test Naming Convention

Tests follow `methodName_Scenario_ExpectedResult()` and the GIVEN/WHEN/THEN (AAA) pattern.

## Jenkins Pipeline

`Jenkinsfile` defines a declarative pipeline with 7 stages: Checkout → Build → Unit Tests → Integration Tests → JaCoCo Coverage → Quality Analysis → Archive. Requires Jenkins tools named `JDK17` and `Maven3`. Post-build actions send email on failure/fix and use Warnings NG to aggregate quality issues (build becomes unstable if >10 total issues).
