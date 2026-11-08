# Default instructions for every repository

These are the defaults. A repository's own CLAUDE.md (or project memory) may override any of them, and wins where they differ.

## Asking

Unless something is absolutely unambiguous (which is rarely the case), ask rather than assume. This applies above all to rules and permissions: when clarifying instructions, every open point is a question. Proposing a default is fine ("I'd read it as X — is that right?"), but it stays a question until answered, and isn't acted on.

## Pushing back

Don't agree with me by default. Treat my claims, opinions and suggestions as things to check, not settled facts:

- Check them against the evidence before going along with them: the code, docs, data, or a quick experiment.
- If the evidence contradicts me, or there's a well-established consensus against what I've said, tell me plainly and show the evidence, before acting on it. Disagreeing is welcome; quietly complying isn't.
- If you can't tell whether I'm right, ask questions instead of assuming either way.

## Git workflow

"The default branch" is the repository's default branch, whatever it's called (`main`, `master`, ...).

1. Create a new branch for the work.
2. Work on it. Committing, and pushing the branch (even before it has a pull request), are allowed as needed, without asking.
3. Open a pull request targeting the default branch (or another branch, to stack pull requests) — **only with the user's approval first**. Existing pull requests may be updated or fixed up (including force pushes) without asking.
4. Once the pull request's CI passes, fast-forward the default branch to it without asking: `git push origin <branch>:<default-branch>`. This keeps the commits' hashes (GitHub's "rebase and merge" rewrites them, even when a fast-forward is possible, and it has no fast-forward merge method), and GitHub marks the pull request merged. Then switch to the default branch, pull, and delete the branch locally (and remotely, if GitHub didn't).
   - Check that CI passed on the exact commit being pushed, and that the push is a plain fast-forward.
   - If the repository has no CI, ask before merging, and suggest setting CI up.
   - If the repository has other collaborators, follow its required-review rules: wait for the approving reviews it requires, and never merge past them with admin rights.

**A working branch's commits are mutable until merged; the default branch is immutable.**

- Any change to what an earlier commit on the branch did (a mistake, review feedback, a better approach) is a fixup commit (`git commit --fixup=<commit>`), autosquashed right away (`GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash <commit>^`), then force-pushed with `--force-with-lease` if the branch has been pushed. A separate change is a new commit.
- With stacked branches, a fix to a commit on the (unmerged) base branch is a fixup there, force-pushed; then the stacked branch is rebased onto it and force-pushed too.
- A mistake already on the default branch is fixed on a new branch, with a new pull request (which needs approval, as any does). Never force-push the default branch unless the user explicitly asks.
- Stage tracked changes with `git add -u` and name each new file explicitly (check `git status` first); never `git add -A` or `git add .`, which sweep up stray untracked files. This applies to agents committing on your behalf too.

## Commit messages and pull requests

No attribution lines (e.g. `Co-Authored-By`, "Generated with ...") in commit messages or pull request descriptions.

## Code

- Comments (code, SQL, migrations) never cite design or plan documents by section ("spec §4.1", "see plan.md"). Readers of the code often can't open those documents, and a rationale kept away from the code drifts when the code changes. State the reason inline, or leave it out.
- C++: an argument that must not be null is a reference, not a pointer, so the type states the precondition (no null check or comment needed). Pointers stay where null means something (an optional argument), or where the pointer is stored as a member, since a reference member makes the type non-assignable. Apply this to code written or touched, without sweeping existing code.
- Format Go with gofumpt, not gofmt. Use the repository's formatter setup (e.g. through golangci-lint) when it has one, and don't gate on `gofmt -l`.
- Don't give Go types a `now func() time.Time` field just so tests can fake time. Call `time.Now()`, and use `testing/synctest` in tests that need controlled time. Tests comparing with a database's `now()` should age rows in SQL instead, since synctest doesn't move the database's clock. Only inject a clock where the package already does.

## Tests

- Go test names follow what they test. Each method gets its own top-level function, `TestType_Method`; never group a type's methods under one `TestType` with a subtest per method. More cases for the same method go inside its function, as table entries or `t.Run` subtests. Tests of an unexported function keep its casing: `Test_runMigrations`, not `TestRunMigrations`.
- Keep each case's setup visible in the case. Don't extract helpers that hide what a case sets up (e.g. "a database with a member without a membership"). A shared test-environment helper must earn its place by carrying state that many tests and helper methods use.
- Don't write tests whose only effect is showing that the database enforces a constraint we declared (a foreign key, `NOT NULL`, `UNIQUE`); review the migration and the schema diff instead. Do test constraints that encode our own logic, such as `CHECK` expressions.
