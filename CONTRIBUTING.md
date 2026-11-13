# Contributing to Sql-RowVersionDemo

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
3. Create a branch for your change, make it, and open a pull request against `main`.

---

## Testing Your Change

There is no automated test suite. Before you open a pull request, run the affected example from
start to finish against `AdventureWorks2022`:

1. Run every script of the example in numeric order, including the teardown script.
2. Check that each script completes without errors and that the results match what the example's
   ReadMe says they will be.
3. Run the teardown script and confirm the database is back to its original state, so the example can
   be run again from the start.

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
