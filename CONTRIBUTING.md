# Contributing to SQL-Server-Row-Version-Demo

Thank you for your interest in improving these SQL Server `rowversion` examples! Contributions are welcome.

## How Can You Contribute?

- Reporting a script that fails, or a ReadMe step that does not match what the script does
- Suggesting a new example (for example, a different way to consume `rowversion` changes)
- Submitting pull requests that fix or extend an example
- Improving the explanations in the ReadMe files

**Please note:** before writing a new example or another large change, open an issue and get agreement on it first. Pull requests are much more likely to be merged when the change has been agreed.

---

## Getting Started

1. **Fork the repository** and clone it locally.
2. Set up a SQL Server instance you can experiment on (a local or Developer edition instance, never a
   production server) with the `AdventureWorks2022` sample database. The README's
   [Getting Started](README.md#getting-started) section lists the prerequisites.
3. Enable the secret-scanning pre-commit hook (needs the [gitleaks](https://github.com/gitleaks/gitleaks#installing)
   CLI on PATH; without it the hook warns and lets the commit through):

   ```bash
   git config core.hooksPath .githooks
   ```

4. Create a branch for your change, make it, and open a pull request against `main`.

---

## Testing Your Change

Example 1 has an automated check, `tests/run-example-01.sh`, that runs on every pull request (the
`Test example 01 (SQL Server)` job in `.github/workflows/tests.yaml`). It builds a small stand-in
`AdventureWorks2022` (`tests/stub-adventureworks.sql`), runs the example's scripts in order, and
compares `Demo.Source` with `Demo.Destination` after each step. The README's
[Testing](README.md#testing) section shows how to run it locally in a throwaway SQL Server container.

Before you open a pull request:

1. If you changed example 1, run `tests/run-example-01.sh` and make sure it passes. When the change
   alters what the scripts do, update the checks in the test in the same pull request.
2. If you added an example, add a matching `tests/run-example-NN.sh` that runs its scripts from setup
   to teardown and checks the results the example's ReadMe promises. Wiring it into
   `.github/workflows/tests.yaml` is a workflow change, so it goes in a pull request of its own.
3. Also run the example by hand against the real `AdventureWorks2022` (the stub holds only a few
   rows of `Person.Person`): every script, in numeric order, should complete without errors and give
   the results the ReadMe describes, and the teardown script should leave the database as it was, so
   the example can be run again from the start.

---

## Writing Guidelines

- Each example lives in its own folder under `example/`, named `example-NN-short-description`, with a
  `ReadMe.md` that explains what it shows and the order to run the scripts in.
- Number the scripts in the order they are run (`1 - Setup.sql`, `2 - ...`), and end with a teardown
  script that removes everything the setup created.
- Keep the scripts inside their own schema (the existing example uses `Demo`), so they never touch the
  sample database's own tables except to read from them.
- When you change a script, update the matching step in the example's ReadMe in the same pull request.
- Link a new example from the root `README.md`.

---

## Pull Requests

- Keep each pull request focused on one change.
- Reference the related issue in the description.
- Changes to workflow files under `.github/workflows/` go in a pull request of their own.
- Respond to review feedback in a timely manner.

---

## Code of Conduct

Please be respectful and considerate in all interactions. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for our community guidelines.

---

Thank you for contributing!
