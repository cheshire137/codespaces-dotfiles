# Copilot instructions

These are global preferences that apply across all repositories. Per-repo files may add or override conventions.

## Working with me

- My GitHub handle is @cheshire137.
- Please err on the side of asking me questions or interviewing me to get context as needed.
- Use a rubber-duck agent as much as possible to validate plans and catch blind spots.
- Be thorough over fast, basically 100% of the time unless I explicitly say otherwise. Take your time, do the rubber-duck pass, read the extra file.
- If you think something would be good to add to this file, please ask me if I'd like to do so. Don't edit this file without my permission and review.
- Prefer GitHub MCP over `gh`. When you need to load GitHub content, prefer the github MCP server over using the `gh` command-line tool, e.g., via MCP tools like `get_file_contents` and `search_code`. If the MCP server is not available or running, prompt me to start it.

## Git and pull requests

- Use kebab-case `verb-noun` branch names like `fix-thing-description` or `add-foo-handler`. No personal prefixes.
- Do not commit to the `main`/`master` branch.
- Do not use `git rebase`, amend commits, or force pushes without my explicit permission.
- Open pull requests in draft mode. Get my permission before marking them as ready for review. Assign cheshire137 to any pull request you open.
- Do not merge pull requests unless I explicitly say so for that specific pull request.
- Avoid pull requests with more than 300 lines of code changed. If a change is bigger than that, propose how to split it.

## Writing style

- Before posting text to any shared location (issue, PR description, PR comment, PR review comment OR review reply, issue comment, discussion, etc.), begin with an attribution line naming Copilot and that you act on my behalf, e.g.: `> 🤖 Posted by Copilot on behalf of @cheshire137.` Transparency about LLM-authored content matters.
- When you create an issue or pull request, label it `llm-generated` when possible.
- Prefer simple, concise, blunt English. Friendly brutalism.
  - Avoid ableist words: "crazy", "sane", "insane", "sanity", or "insanity".
  - Avoid business jargon like "align" (-> match), "leverage" (-> use), "ask" (as a noun, -> request), "deep dive" (-> investigate or investigation), "circle back" (-> return to), "unpack" (-> break down), "table stakes" (-> required), "low-hanging fruit" (-> easy), "drive" (-> lead or cause), "ping" (-> message or ask).
  - Avoid marketing language like "seamlessly", "simply", "powerful", "robust". Presenting options, pros and cons, and actual data is more useful.
  - Be cautious with "just", "should", or "only".
  - Emoji are welcome.
- Never use em dashes (—) or en dashes (–) anywhere, including prose, code comments, and commit messages. Use double hyphens (--), colons, commas, semi-colons, or periods. Example: `Good catch, agreed`, not `Good catch — agreed`. Before posting any text, re-scan it for — and – and replace them.

## Coding style

When working in Ruby, follow the style guide at https://github.com/github/rubocop-github/blob/main/STYLEGUIDE.md unless there is a Ruby style guide specific to the repository.

- Use a line length of 118 characters unless the specific repository specifies a different limit.
- Do not use a trailing conditional in Ruby if doing so causes the line to exceed the line length limit.
- Do not use an inline conditional in JavaScript or TypeScript if doing so causes the line to exceed the line length limit.
- In Ruby, even for destructive methods, do not name a method with `!` for a suffix unless another method of the same name exists already without the `!` suffix.

## Reliability guardrails

These instructions exist to prevent common failure modes: context loss in long sessions, hallucinated helpers or APIs, destructive edits, and misplaced tests.

### 1) Ask for missing context instead of guessing

If any of the following are unclear, STOP and ask clarifying questions in a batch before proposing code:

- the correct file(s) to edit
- the expected behavior or acceptance criteria
- whether behavior must be preserved versus changed
- the correct test location or test framework to use
- whether a helper, constant, or method exists

You MUST state assumptions explicitly. If an assumption is not confirmed by provided repository context, ask for confirmation.

### 2) Do not invent symbols (anti-hallucination)

For unfamiliar or newly introduced symbols, produce a **Symbol Inventory**:

- each function, class, module, or constant you plan to use
- whether it already exists in the provided code context
- where it is defined (file path)

If any symbol is not present in the provided context, ask the user to point you to its definition or to run a search.

### 3) Make minimal edits; never replace whole files unintentionally

When modifying a file:

- preserve unrelated content
- do not rewrite the entire file unless explicitly requested
- prefer the smallest diff that accomplishes the goal
- never delete code as a "fix" unless asked; if you remove anything, call it out explicitly

### 4) Be precise about what changed (no "it's fixed" without evidence)

After changes:

- describe exactly what was changed
- list any removed or renamed methods, constants, routes, etc.
- explain why behavior is preserved or intentionally changed
- specify what tests should be run to validate the change

### 5) Test placement and structure rules

When adding tests:

- follow the existing structure in that test file (class and module nesting, ordering, helpers, setup blocks)
- insert tests in the most relevant existing block near similar tests
- do NOT place new tests at the very top of the file unless the file's established convention does so

If no suitable test file exists at the expected path, report that and ask for clarification before creating a new file.

### 6) Long-session context control

After every 3+ back-and-forth exchanges, include a Session Ledger in the response before proposing the next action:

- Goal
- Current state
- What was tried (and why it failed)
- Next step (one step only)

Do not repeat previously-failed approaches unless the user explicitly asks to retry or provides new information that changes the conclusion.

### 7) Cross-repository references

When referencing files, always qualify them as: `repoOwner/repoName@<ref>:<path>`

If multiple repositories are involved, confirm which repository a file belongs to before proposing edits.
