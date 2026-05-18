---
name: explain
description: Explain a piece of code, a file, a function, or a concept in plain language for a non-technical reader. Strips jargon, focuses on what it does and why it matters, and keeps the answer short.
allowed-tools: Glob(*), Grep(*), Read(*), Bash(git:*)
argument-hint: [code snippet, file path, function name, or concept]
---

## Context

You are explaining $ARGUMENTS to someone who is **not a software engineer**. Imagine a product manager, designer, customer support teammate, or executive — smart, curious, but unfamiliar with code.

If $ARGUMENTS is empty, ask the user what they want explained and stop.

## What to do

1. **Locate the subject.** Resolve $ARGUMENTS to something concrete:
   - A file path → read it
   - A function / symbol name → grep the codebase, read the definition
   - A pasted snippet → use it directly
   - A concept (e.g. "Oban", "GraphQL subscriptions") → explain from your own knowledge, grounded in how this repo uses it if relevant
2. **Understand it well enough to translate it.** Read enough surrounding code to know *what it does* and *why it exists* — not just line-by-line mechanics.
3. **Write the explanation.** Follow the rules below.

## Rules for the explanation

- **Lead with the punchline.** One sentence: what this thing does, in human terms. No preamble.
- **No jargon.** Avoid words like *function*, *method*, *class*, *struct*, *callback*, *async*, *mutation*, *schema*, *endpoint*, *query*, *params*, *args*, *return value*, *boolean*, *null*, *enum*, *hash*, *array*, *thread*, *process*, *cache*, *deserialize*. If you must use a technical word, define it inline in 4 words or fewer.
- **Use analogies sparingly.** One good analogy beats three weak ones. Skip them entirely if the plain explanation is already clear.
- **Keep it short.** Target 3–6 sentences total, or a short bulleted list. If the subject is genuinely complex, you may go longer — but justify every extra sentence.
- **Focus on *what* and *why*, not *how*.** The reader doesn't care that you used a hash map; they care what problem it solves.
- **No code in the explanation.** Don't paste snippets back. Don't reference variable names. Don't say "line 42."
- **Don't editorialize.** No "this is a really cool pattern" or "this is straightforward." Just explain.

## Output shape

```
**[Subject] in plain language**

[The punchline sentence.]

[2–5 more sentences, or a short bulleted list, expanding on what it does and why it matters.]
```

That's it. No headers beyond the title line. No "let me know if you have questions." No summary of what you just said.

## When to push back

- If $ARGUMENTS is too vague to locate (e.g. "the thing in axon"), ask one clarifying question and stop.
- If the subject genuinely *requires* a technical concept to make sense (e.g. explaining a database index), define that one concept in plain terms and move on — don't refuse.
