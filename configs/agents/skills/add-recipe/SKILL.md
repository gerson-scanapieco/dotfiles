---
name: add-recipe
description: Add a recipe to the "Receitas da Semana" Notion database from a YouTube video link or a recipe webpage. Pulls the recipe from the video description/transcript or the page content, then creates a Notion page with the recipe name, source link, ingredients, and steps.
allowed-tools: ToolSearch(*), WebFetch(*), Bash(curl:*), mcp__claude_ai_Notion__notion-fetch(*), mcp__claude_ai_Notion__notion-query-data-sources(*), mcp__claude_ai_Notion__notion-create-pages(*)
argument-hint: [youtube or recipe URL]
---

## Context

You are adding one recipe to the Notion database **🥗 Receitas da Semana**.

Data source: `collection://65c41482-3f17-4378-91a2-181b7ea3ba73`
Schema: only three properties exist —
- `Nome` (title) — the recipe name
- `URL` (url) — link to the source, video or webpage. In page-update/create calls this property must be addressed as `userDefined:URL` (Notion's naming rule for a property literally called "URL").
- `Tipo` (select) — the recipe's category. Current options: `Frango`, `Carne`, `Massa`, `Salada`, `Sobremesa`, `Frutos do Mar`. Pick the closest existing option; if none fit, choose the single best short Portuguese category name for a new option (the property accepts new select values).

Everything else about the recipe (ingredients, steps, servings, time, source link) goes in the **page content**, written as Notion markdown.

The database is in Brazilian Portuguese. Translate the recipe name and full content to Brazilian Portuguese (pt-BR) regardless of the source's original language — don't leave English/other-language recipes untranslated.

If the deferred Notion/WebFetch tools aren't loaded yet, load them first with one `ToolSearch` call:
`select:mcp__claude_ai_Notion__notion-fetch,mcp__claude_ai_Notion__notion-query-data-sources,mcp__claude_ai_Notion__notion-create-pages,WebFetch`

## Input

$ARGUMENTS should be a URL. If it's empty or not a URL, ask the user for the recipe link and stop.

## Steps

1. **Classify the URL.** YouTube (`youtube.com/watch`, `youtu.be/`, `youtube.com/shorts/`) vs. a regular webpage.

2. **Extract the recipe.**
   - **YouTube:**
     a. `WebFetch` the video URL with a prompt asking for: video title, channel name, and the **full** video description verbatim (cooking channels usually put the whole recipe — ingredients and steps — in the description).
     b. If the description contains a usable recipe (ingredient list and/or steps), use it.
     c. If the description is thin (e.g. just hashtags/links), try the transcript as a fallback: extract the video ID and fetch the caption track directly, e.g.
        `curl -s "https://video.google.com/timedtext?lang=en&v=<VIDEO_ID>"` (try `lang=en`, then the video's apparent spoken language, then `kind=asr` variants if the plain call returns empty). Strip the XML tags to get plain spoken text, then derive an ingredient list and steps from it — the transcript is spoken language, not a formatted recipe, so tidy it into clear ingredients/steps yourself.
     d. If neither yields enough to reconstruct a real recipe, tell the user what's missing and ask them to paste the recipe or point to another source — don't fabricate quantities or steps.
   - **Webpage:** `WebFetch` the URL with a prompt asking for the recipe title, servings/time if present, full ingredient list, and full numbered instructions. Recipe sites often bury this in a "jump to recipe" block — ask WebFetch specifically for that block's content, not the surrounding blog story.

3. **Check for duplicates.** Query the data source for an existing row with the same `URL` or a very similar `Nome` before creating anything:
   `mcp__claude_ai_Notion__notion-query-data-sources` with `data: {"mode":"rows","data_source_url":"collection://65c41482-3f17-4378-91a2-181b7ea3ba73"}`.
   If a match exists, tell the user it's already there (name it) and stop instead of creating a duplicate.

4. **Create the Notion page** via `mcp__claude_ai_Notion__notion-create-pages`:
   - `parent`: `{"type":"data_source_id","data_source_id":"65c41482-3f17-4378-91a2-181b7ea3ba73"}`
   - `properties.Nome`: the recipe's name, translated to Brazilian Portuguese if the source wasn't already in Portuguese (clean it up — strip channel branding/emoji spam from YouTube titles)
   - `properties["userDefined:URL"]`: the original source URL (video or webpage) — always set, regardless of source type.
   - `properties.Tipo`: the recipe's category (see Context above).
   - `icon`: a single emoji matching `Tipo`, so the icon reflects the recipe's category, not the specific dish. Keep this mapping consistent across recipes:
     - `Frango` → 🍗
     - `Carne` → 🥩
     - `Massa` → 🍝
     - `Salada` → 🥗
     - `Sobremesa` → 🍰
     - `Frutos do Mar` → 🦐
     - a new `Tipo` option → pick a fitting emoji and keep using it consistently for that category going forward.
   - `content`: Notion markdown, roughly:
     ```
     [Source](<original URL>)

     ## Ingredientes
     - ...

     ## Modo de preparo
     1. ...
     ```
     Translate all of it to Brazilian Portuguese if the source wasn't already in Portuguese — keep quantities/units as given (don't convert units), just translate the language. Include servings/prep time/cook time near the top if you found them.

5. **Confirm to the user** with the recipe name and a one-line summary of what you found (e.g. "from the video description" or "from the transcript, reconstructed" or "from the webpage's recipe card"), so they know how much to trust the extraction.

## Rules

- Never invent ingredients, quantities, or steps that weren't in the source. If information is missing or ambiguous, say so in the confirmation rather than guessing.
- Don't add properties beyond `Nome`, `URL`, and `Tipo` — the schema only has those three; everything else belongs in page content.
- Translate the recipe name and content to Brazilian Portuguese (pt-BR) whenever the source isn't already in Portuguese.
- One recipe per invocation unless the user pastes multiple URLs, in which case repeat steps 1–4 for each and give one combined confirmation at the end.
