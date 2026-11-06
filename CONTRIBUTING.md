# Contributing to WikiGo

WikiGo has two faces: a self-hostable wiki, and a **Rails reference app** —
living documentation of how modern Rails is written, in a small readable
codebase. That second face decides everything here. Before proposing a
change, internalize one standard:

> **Rails 本体が推奨しているか。読者に 1 分で説明できるか。**
> (Does Rails itself recommend it? Can you explain it to a reader in one minute?)

If the honest answer to either is no, the change does not belong in main —
regardless of how good it is in production.

## The contract, and how to change it

The README's 採用 / Non-goals tables are the policy contract, each row
evidenced by an issue number. That means:

- **Adopting something new** (a gem, a pattern, a datastore) requires an
  issue arguing the Rails-recommended route first, and the README row moves
  with the implementing PR.
- **Dropping something** leaves the non-goal row behind with its issue
  number — the decision stays readable, not just reverted.
- **Account/vendor-specific surface does not ship in main.** The
  Rails-side interface does; the vendor half lives on an `example/*` branch
  (`example/ai-editing` is the template). See #117.
- No silent scope creep: a PR grows to its issue, not past it.

## What makes this repo useful to a reader

- **Tests are the specification, and the spec is itself exemplary.** Plain
  minitest + fixtures — no RSpec, no FactoryBot, no mocking frameworks.
  Every test should read as the canonical way to test that thing (see
  `test/services/*` for the service-object pattern, the system suite for
  rack_test journeys, the Option tests for registry semantics).
- **No placeholders.** No `assert true` stand-ins, no dead config, no
  vestigial columns ("which column is the source of truth?" is a question a
  reference app must not raise — see #116).
- **No compatibility shims.** When the framework changes, the code follows
  the framework (the Devise → authentication-generator swap in #110 is the
  model: delete the old half, record the sharp edges in the PR).
- **No input-driven dispatch.** Settings-style APIs take declared names,
  never `send`/`method_missing` over user input (#114; the same class of bug
  as #105's privilege escalation).
- **Secrets ride the declared registry** (`Option::KNOWN_KEYS`) and are
  encrypted at rest (#113).
- **Dependencies:** every gem must survive the 1-minute test. Dependabot
  policy is in-tree (`.github/dependabot.yml`); security alerts are triaged
  by a human, freshness bumps are their own PRs.

## Workflow

```bash
bin/ci            # the gate: setup, gem audit, brakeman, tests, seeds, system
bin/setup         # from a clean clone
```

- Branch from `main`; PR body answers *why* against the standard above;
  issue numbers link both directions.
- CI (`bin/ci` locally, Actions per PR) is the merge gate; the post-merge
  push/pull run on master is the authority.
- Releasing is how the reference gets citable — the ritual is in
  `CLAUDE.md` (Releases & the Reference Point) with `CHANGELOG.md` as the
  ledger: changelog section first, then the tag, then the release.

## For AI agents

Start with `CLAUDE.md`: it carries the command matrix, the environment
notes, and the house conventions in an executable form.
