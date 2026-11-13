# Security Policy

## Supported Versions

This repository holds T-SQL example scripts and their documentation. There are no packages and no
versioned releases; only the current `main` branch is supported.

The scripts are teaching examples. They create and drop objects in the `AdventureWorks2022` sample
database and are meant for a development SQL Server instance, never a production one.

## Reporting a Vulnerability

If you discover a security vulnerability (for example, a script that could damage data outside the
`Demo` schema it creates, or a secret committed to the repository), please follow these steps:

1. **Do not** create a public issue on this repository.
2. Open the private report form: https://github.com/Chris-Wolfgang/Sql-RowVersionDemo/security/advisories/new
   (or, from the repository's **Security** tab, click **Report a vulnerability**).
   GitHub's guide to this process: https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability
3. Fill out the provided form with:
   - A description of the vulnerability
   - Steps to reproduce the issue
   - Potential impact
   - Suggested fix (if you have one)

## Response Timeline

This is a single-maintainer project; the commitments below are realistic for that, not aspirational.

| Stage | Target |
|-------|--------|
| Acknowledgement of the report | Within 48 hours |
| Initial assessment (confirmed / not a vulnerability / need more information) and severity | Within 7 days |
| Fix for **Critical** or **High** severity | Within 30 days |
| Fix for **Medium** or **Low** severity | Within 90 days |

If a target is going to slip, you will hear that from the maintainer in the advisory thread before
the deadline passes, not after.

## Disclosure Process

1. **Report** - you open a private advisory (above). Only the repository owner, anyone with the
   repository's admin role, and collaborators explicitly added to the advisory can see it.
2. **Triage** - the maintainer confirms the issue and assigns a severity, discussed with you in the
   advisory thread.
3. **Fix** - the fix is developed in a temporary private fork attached to the advisory, so nothing
   about the vulnerability is visible in public pull requests until it is merged.
4. **Publish** - the fix is merged to `main` and the advisory is published. Publication happens when
   the fix is merged, or 90 days after the initial report if no fix is possible, whichever comes first.

Please keep the details private until the advisory is published.

## Credit

Reporters are credited in the published advisory, unless you ask not to be.
Tell us in the report how you would like to be named.
