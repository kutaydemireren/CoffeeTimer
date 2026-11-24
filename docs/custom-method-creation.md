# Creating a custom brew method

Status: accepted design. All 4 stages of the [order of work](#order-of-work) are implemented: iOS 26, the model changes, the new creation flow and tile menu, and Tweak this brew. This page records how users will create their own brew method and why. The implementation should follow it. Every open question was settled on 2026-11-23; see [Decided (2026-11-23)](#decided-2026-11-23).

### What stage 2 put in the model

- `BrewMethod.referenceDose` (`ReferenceDose`: coffee, water and optional ice, in grams) is optional and stored as an optional `referenceDose` key on `BrewMethodDTO`. Built-in JSON and methods saved before it decode with `nil`, so no migration was needed. Nothing sets it yet: the stage 3 editor will.
- `BrewMethod.recipeRatios` lists the method's own ratio first (titled like "1:16.7 - As written", one decimal only when needed), then `ratios` without a duplicate. `defaultRatio` selects it in Create Recipe. Without a reference dose both behave as before.
- Ice: with a reference dose that has ice, the recipe splits the total liquid so that ice / water equals the reference ice / water. Otherwise iced brews keep 40% of the total as ice.
- Coffee is water / ratio in decimal maths, and coffee and step amounts round to the nearest gram.
- Water is labelled in grams at display time (`String.brewDisplayText`, `IngredientAmount.toRepresentableString`). The instruction JSON and stored recipes still say ml, so recipes saved by older versions show grams too.
- The old editor accepted countdowns up to 3600 s (stage 3 replaced it; the new step sheet has the same limit).

### What stage 3 built, and the choices it made

The flow, method screen, step palette, step sheet and tile menu follow the sections below. The code lives in `CoffeeTimer/BrewMethod/Editor` (the editor model: `MethodDraft`, `MethodStepMapper`, `MethodTimeline`, `MethodStepText`, `MethodDraftCompiler`, `MethodDraftFactory`), `BrewMethod/SaveBrewMethodUseCase.swift` and `CoffeeTimer/iOS/Scene/MethodEditor`. The old editor in `Scene/CreateMethod` is gone.

Where this page left room, stage 3 chose:

- **Drafts.** There is one draft slot (`methodEditorDraft` in `UserDefaults`). The editor writes the draft on every change once it differs from what was opened, and clears it on save or Discard. Close with changes asks Keep as draft, Discard changes or Cancel. When a draft is kept, "Or, create your own" shows "Continue your draft" above the two start tiles.
- **Try it.** Timers run 10 times faster (at least 1 s each), and the text keeps the real numbers. It sends no analytics and does not count toward the review prompt. The end of the brew, Done or Recipes returns to the method screen.
- **Delete.** Delete on a tile removes the method at once and shows an Undo banner for 6 seconds; there is no confirmation. Undo puts the method back at the end of the grid. A removed method's steps are kept, as before.
- **Old and built-in steps the fields can't express are kept as stored.** This covers a `put` whose amount is not one of the three forms below (for example the built-in V60 bloom, water = 2 × coffee), a pause without a countdown, and a step the app can't read. The row says "kept as saved". Saving writes such a step back byte for byte. Editing anything in its sheet rewrites it in grams from what it pours at the shown dose. The other old steps convert, and recipes made from them brew the same amounts, timers and text (a unit test checks this at several doses with steps saved by the old editor).
- **Recognised amount forms.** Water: `f × water` (or `#total.water`) is Add an amount, `f × water − 1 × #current.water` is Up to a total, `1 × #remaining.water` is The rest. Coffee and ice: `f × coffee` or `f × ice`. An adjustment with factor 0, which the old editor wrote by default, counts as none.
- **Dose for methods without a reference dose.** 15 g coffee and 250 g water. An iced one also gets 167 g ice, which keeps the 40% share of the total liquid that its recipes use today, to the nearest gram at usual cup sizes.
- **Optional step fields.** Besides `kind`, saved steps carry `doneBy` (seconds) and `amountMode` (`upTo`, `add`, `rest`). The engine ignores both. `amountMode` is needed because the engine has no running water total before the first step that puts something in or a timed pause, so an "Up to" pour there is stored as an added amount (the same number) and reopens as "Up to".
- **Brew-screen line.** The line is generated with tokens (for example "Pour up to #current.water g"). When the user rewrites it, the sheet shows placeholders such as `{amount}` and `{total}` with buttons to insert them. They are saved as tokens, so the numbers stay live. Copied steps keep their own wording.
- **Timers and "Then".** New timed steps start by themselves; Then decides whether the next step starts by itself or waits for a tap. Steps kept from a copy keep their own start setting. A step without a timer always waits for a tap, as the brew screen already does.
- **Defaults per kind.** Pour: up to the method's full water, no timer, waits for a tap. Wait: 30 s, carries on. Add coffee: all the coffee. Add ice: the method's ice (adding the first ice step to a hot method sets ice to 40% of the total liquid). Note: empty text, which Save asks for.
- **Footer.** A water mismatch is a warning, not a block: some methods pour less on purpose. The fix is "Make the last pour the rest", "Add a pour" when there is none, or "Write it for N g water" when the pours go over.
- **Save.** Messages, first one shown: "Add a name", "Add at least one step", "Set the coffee and water it is written for", "Set the ice it is written for", "Write the note in step N", "Set an amount in step N", "Step N starts at m:ss, so "Done by" must be later", "Timers go up to 60:00 (step N)". Editing a method that no recipe uses saves in place without asking. Update everywhere rebuilds the saved recipes that use the method (and the selected recipe) with their own amounts, cups and name. After saving, an empty recipe name is filled with the method's name, so the flow can go straight to cups, cup size and strength.
- **Make it mine** names a copy "My V60" for a built-in method and "<name> copy" for the user's own. When that name is already taken by one of the user's methods, the copy gets the first free number from 2: "My V60 2", "My V60 3" (`MethodDraftFactory.copyName`). This is only the default; the user can rename it.

## The problem today

A brew method is an ordered list of steps (the "how"). A recipe is a method plus cups, cup size and strength. "Or, create your own" at the bottom of the Create Recipe method grid opens the method editor (`Scene/CreateMethod`). The editor is a direct view of the step engine, and it shows:

- **Engine words.** Each step has an "Action Type" of Message, Pause or Put, a "Requirement" (none or countdown), and a "Start Requirement Method" and "Skip Step Method" set to Auto or User Interactive.
- **Tokens in text.** The brew screen shows numbers only if the user types tokens such as `#current.amount`, `#total.water` or `#remaining.coffee` into the message.
- **Amounts as formulas.** An amount is a factor times a keyword, plus an optional adjustment: a pour is "0.2 × Total Water", the built-in V60 pour is "0.6 × Total Water − 1 × Current Water". The user does the fraction maths.
- **No overview.** There is no preview of what the brew screen will say, no running total of water, and no estimated brew time.
- **Traps.**
  - "Next" turns into "Save" on the last page and saves straight away (`Views/PagerView.swift`).
  - A missing title sends the user back without a message.
  - "New Instruction" adds a blank Message row and does not open it.
  - Close and Delete throw work away without asking.
  - Delete for a method is hidden behind a long press, and that menu appears on every tile, built-ins included.
  - A saved method cannot be edited.
  - The water amount is labelled "Amount (gram)", while the brew screen shows water in ml.

Nobody points at one part. The common feeling is too much thinking, setup and typing for what should be "write down how I brew".

## Who creates methods

Two groups, equally important:

1. **People copying a recipe they found**: from a video, a barista, a coffee bag or a friend. They have the numbers in front of them and want to type them in as written.
2. **Hobbyists tweaking their own ritual**: they start from something close and change a bloom, a pour or a wait.

Beginners don't create methods. They pick a built-in method in Create Recipe and stay there.

## Settled decisions

- **Hard constraint.** A created method appears in the Create Recipe method grid, and recipes can be created from it. Custom methods already saved on users' devices must keep working.
- **The whole method is always visible.** A guided wizard (one question per screen) was rejected: it is slow, a long series of questions can overwhelm, and the user only sees the result at the end.
- **Two equal starts.** "Start from a method" (built-in or the user's own) and "Start from scratch" are both first-class. The app ships few brewers, so owners of a Kalita Wave, a Clever Dripper and so on must be able to add theirs from nothing.
- **A method remembers its ratio.** A custom method stores the dose it was written for (for example 30 g coffee and 500 g water, 1:16.7). When the user makes a recipe from it, that ratio is the default strength, and the other strengths stay available. Today strength comes from a fixed 1:16 to 1:20 list and coffee is computed with whole-number division, so this needs a model change (see [Mapping onto the engine](#mapping-onto-the-engine)).
- **Concrete grams.** While creating and brewing, the user sees and types real amounts in grams, water included. The app converts them to ratios for scaling.
- **English only** for now.
- **Considered and not chosen:**
  - *AI import from text, a photo or speech*: on-device models need Apple Intelligence devices, and the idea was dropped.
  - *Recording a brew while doing it, then tuning it*: rejected as the main way in. It is kept as an extra door: "Tweak this brew" on the post-brew screen (see [the flow](#6-tweak-this-brew)).
  - *A pour timeline chart as the editor*: dropped.
  - *Method "dials"* (a few fixed parameters such as bloom, pours and total time): too rigid for recipes that don't fit the template.
  - *Editing on the brew screen*: the controls would be invisible during a brew, and copying a recipe this way is slow.
  - *Typing the recipe as free text*: hard to get right the first time, and the app would need a parser to maintain.
  - *One save that creates both a method and a recipe*: one action making two things confuses people, and the grid would fill with near-duplicates.
- **Design language (firm).** The new screens follow CoffeeTimer's own design and reuse its existing components. Components may be created, updated or removed as needed, but the screens must clearly belong to CoffeeTimer in look and behaviour. No new visual style. See [Design system](#design-system).

## The flow

### 1. Start

"Or, create your own" opens a small choice with two equal options:

- **Start from a method**: pick any method in the grid, built-in or the user's own. The method screen opens with a copy of its steps.
- **Start from scratch**: the method screen opens with a name field, the "Written for" line and an empty step list.

Every method tile in the grid gets a visible menu button (not only a long press):

- **Make it mine**: same as starting from that method.
- For the user's own methods, also **Edit** and **Delete**. Delete asks for confirmation or offers Undo.

Built-in tiles offer only Make it mine. This also fixes today's long-press Delete on built-in tiles.

### 2. Method screen

One scrolling screen that always shows the whole method:

- **Name**, with a small row of icons to pick the grid icon from the existing brewer icons (V60, Chemex, AeroPress, French Press, kettle). The default is the template's icon, or the kettle when starting from scratch.
- **Written for 15 g coffee · 250 g water.** Tap to change. When the method adds ice, the line includes it: "15 g coffee · 150 g water · 100 g ice". When the amounts change, the app asks whether to scale the steps. If yes, amounts scale and times stay the same.
- **Steps** as readable rows. Each row says what the brew screen will say, for example "Pour up to 150 g". Under it, a quieter meta line: "+120 g · done by 1:15". The running water total sits on the right.
- **"+"** at the end of the list and between rows, to insert a step where it belongs.
- **Footer** with total poured against the method's water ("250 of 250 g") and the estimated end time. When the numbers don't add up, the footer becomes a warning with a one-tap fix, for example "Make the last pour the rest".
- **Try it** plays the brew quickly on the real brew screen, so the user sees exactly what they will get.

### 3. Step palette

Tapping "+" shows the step kinds in the user's words:

- Pour
- Wait
- Add coffee
- Swirl or stir
- Note (free text: anything the user wants)
- Under **More**: Add ice, Press, Flip, Remove

Each kind asks only for the fields it needs. A Wait has a time and no amount. A Note has text and nothing else.

### 4. Step sheet

Tapping a row opens a sheet for that step:

- **Amount**: *Up to a total* ("pour up to 150 g"), *Add an amount* ("add 50 g") or *The rest* (whatever water is left).
- **Time**: *No timer*, *Takes 30 s* or *Done by 1:15* (a clock time from the start of the brew). Timers go up to 60 minutes and are typed as m:ss. The editor turns "Done by" into a duration from the planned timeline and shows it on the row, for example "30 s pour".
- **Then**: *Carry on by itself* or *Wait for my tap*. Each kind has a sensible default: a Wait carries on by itself, a Pour without a timer waits for a tap.
- **Brew-screen line**: generated from the fields, for example "Pour up to 150 g". The user can rewrite it in their own words, and the numbers in it stay live when amounts change.
- **Tip line** (optional), shown smaller under the main line on the brew screen.
- **Duplicate**, and **Delete** with Undo.

### 5. Save

- **Save** is always visible. If the method can't be saved yet, tapping Save explains what is missing ("Add a name", "Add at least one step").
- Drafts save automatically.
- **Close** asks only when something changed.
- When the user edits a method that recipes already use, Save asks: **Update everywhere** or **Save as new**.
- After saving, the new method is selected in the grid and the flow continues to cups, cup size and strength, with the method's own ratio listed first and selected.

### 6. Tweak this brew

The post-brew screen gets a quiet secondary button, "Tweak this brew", below the Buy Me a Coffee tip. On `main` that screen already shows after both completed and ended brews (see [review-prompt.md](review-prompt.md)); the review prompt timing does not change. The button opens the same method screen on the method just brewed. For a built-in method it opens a copy ("My V60"), and on save offers to switch this recipe to the copy. This ships in the same release as the new flow.

As built: the user's own method opens as with Edit on its tile (Update everywhere or Save as new when recipes use it). After a built-in copy is saved, a prompt offers "Switch to My V60" or "Keep V60"; dismissing it keeps the recipe on the built-in. Switching keeps the recipe's name, cups and amounts and rebuilds its steps from the copy. Close without changes goes back to the post-brew screen; a save goes to the main screen. Analytics: `tweak_brew_opened` (`brew_method_type`: `built-in` or `custom`) and `tweak_brew_recipe_switch` (`switched`).

## Walkthroughs

**Copying a V60 recipe from a video (about 20 taps).** The recipe is 30 g coffee and 500 g water: bloom with 60 g, wait 45 s, pour up to 300 g by 1:15, pour up to 500 g by 1:45, swirl, let it drain. The user taps "Or, create your own", "Start from a method", V60. They set "Written for" to 30 g and 500 g and let the steps scale. They change the bloom to 60 g, set the wait to 45 s, change the first pour to "Up to 300 g, done by 1:15" and the last to "The rest, done by 1:45". They delete a step they don't need and save. The footer confirms 500 of 500 g and an end time.

**Tweaking one's own bloom (about 4 taps).** On their own method's tile: menu, Edit. Tap the bloom row, change 40 g to 50 g, Save.

**A Kalita Wave from scratch (about 25 taps).** "Start from scratch", type the name, set "Written for" to 20 g and 320 g. Then "+" Add coffee, "+" Pour up to 50 g, "+" Wait 30 s, three "+" Pour rows with "Up to" totals and "Done by" times (the last one as The rest), and a closing Note. Try it, then Save.

## Mapping onto the engine

The step engine lives in `RecipeInstructions/RecipeInstructions.swift`. A saved step is a `RecipeInstructionStep` with an action (`put`, `message` or `pause`), an optional countdown, a start and skip method (`auto` or `userInteractive`), a message and optional details with keyword tokens, and for `put` an ingredient (`coffee`, `water`, `ice`) and an `InstructionAmount` (a main factor plus an optional adjustment factor, each a number times a keyword). Built-in methods use the same format (`data/v0/brew-instructions/*.json`).

### Already supported

| New design | Existing engine |
|---|---|
| Pour, Add coffee, Add ice | `put` with ingredient `water`, `coffee` or `ice` |
| Takes 30 s | `requirement` countdown of 30 s |
| Carry on by itself / Wait for my tap | `skipMethod` `auto` / `userInteractive` (`startMethod` likewise for whether a step starts by itself) |
| Add an amount | main factor times `water` or `coffee` (the recipe's total) |
| Up to a total | main factor times `water`, adjustment `-1` times `#current.water`. The built-in V60 already does this: `0.6 × water − 1 × #current.water` |
| The rest | factor `1` times `#remaining.water` |
| Wait | `pause` with a countdown |
| Note, Swirl or stir, Press, Flip, Remove | `message`, with an optional countdown |
| Numbers in the brew-screen line | tokens such as `#current.amount`, `#current.water` and `#current.duration`, replaced when the recipe is built |

The domain already has named stage actions (`wet`, `swirl`, `swirlThoroughly`, `boilWater`, `finish`, `finishIced` in `Entities/Entities.swift`). They are mapped in `RecipeMapper` but the instruction format can't produce them: it only knows `put`, `message` and `pause`. The new step kinds can be saved as `message` steps, so no schema change is needed for them. A step kind may also be stored in a new optional field so the editor can show the row in the user's words again. Older app versions ignore unknown JSON keys.

### New work

- **Method-owned ratio and reference dose.** `BrewMethod` already has a `ratios` list, but custom methods always get the fixed list from `StaticCoffeetoWaterRatioGenerator` (1:16 to 1:20 hot, 1:15 to 1:19 iced). A custom method needs to store its reference dose (coffee and water) and put its own ratio first.
- **Ice share.** Ice amounts today are a fixed 40% of water (`iceToWaterRatio = 0.4` in `CreateContextToInputMapper`). A method that adds ice keeps its own ice share from its reference dose, and recipes scale it.
- **Decimal ratio maths.** `CoffeeToWaterRatio.value` is a `Double`, but `CreateContextToInputMapper.calculateCoffeeAmount` computes coffee as `waterAmount.amount / UInt(ratio.value)`, whole-number division. 1:16.7 becomes 1:16, and 500 g water gives 31 g coffee instead of 30 g. Amounts are also truncated to whole numbers (`UInt(...)`) when a step's amount is calculated. The new default is rounding to the nearest whole gram (the owner may revisit this).
- **Grams to factors.** The editor takes grams written for the reference dose and stores factors, so the method still scales to any recipe. For example "up to 300 g" in a 500 g method is saved as `0.6 × water − 1 × #current.water`.
- **Done by a clock time.** The engine only knows per-step durations, and it stays that way. The editor turns "Done by 1:15" into a countdown from the step's planned start time and recomputes it when earlier steps change. Steps that wait for a tap count as 0 s. The estimated end time adds up the countdowns.
- **Generated text.** Each step's brew-screen line and tip are generated from its fields, with tokens inserted so numbers stay live. A user's own wording is stored as the message, with the same tokens.
- **Dry run.** "Try it" plays the method on the brew screen with shortened timers and without saving.
- **Edit after save.** There is no edit flow today. Editing loads the saved instructions back into the editor. "Update everywhere" saves under the same method id so recipes made from it pick up the change; "Save as new" creates a new method.
- **Longer timers.** Countdowns are limited to 300 s only in the editor UI (`NumericTextField` range in `InstructionActionViewBuilder.swift`). The engine accepts any positive length. The new limit is 60 minutes.
- **Grams display.** Water shows in grams everywhere, including built-in methods, which are relabelled from ml to g in display.
- **Existing custom methods.** Methods saved with the old editor are formula-based and have no reference dose. They brew exactly as before. Opening one in the new editor shows its steps in grams at a default dose of 15 g / 250 g, and saving converts it to the new format. Methods nobody opens never change.

## Design system

The new screens reuse what the app already has. Paths are under `CoffeeTimer/iOS`.

### What exists

| Piece | Path | What it is |
|---|---|---|
| Color assets `backgroundPrimary`, `backgroundSecondary`, `foregroundPrimary`, `foregroundSecondary`, `tertiary` | `Resources/Colors.xcassets` | The app's palette; the app forces light mode |
| `BackgroundPrimary`, `BackgroundSecondary`, `.backgroundPrimary()`, `.backgroundSecondary()` | `ViewModifiers/View+Background.swift` | Screen backgrounds |
| `TitledContent` | `Views/TitledContent.swift` | Headline title with optional info button over any content |
| `TitledPicker` | `Views/TitledPicker.swift` | Titled menu picker over `Titled` items |
| `NumericTextField` | `Views/NumericTextField.swift` | Number field with a range and keyboard type |
| `AlphanumericTextField` | `Views/AlphanumericTextField.swift` | Text field |
| `InfoButton`, `InfoView` | `Views/InfoButton.swift`, `Views/InfoView.swift` | Info button that opens an explanation sheet |
| `Separator` | `Views/Separator.swift` | Thin divider |
| `.clearButton(text:)`, `.keyboardDoneToolbar(isFocused:)`, `.highlightAnimation(isAnimating:)` | `ViewModifiers/` | Field helpers and a highlight effect |
| `PagerView` | `Views/PagerView.swift` | Close / Next / Save header over paged content |
| `BrewMethodView`, `CreateRecipeBrewMethodSelection` | `Scene/CreateRecipe/CreateRecipeBrewMethodSelection.swift` | Method tile and grid, with "Or, create your own" |
| `RecipeRowView`, `RecipeProfileView` | `Scene/Recipes/RecipeRowView.swift` | Row for a saved recipe |
| `StageHeaderView` | `Scene/BrewQueue/StageHeaderView.swift` | Light title over a main title and subtext ("It is time to / Pour 50.0 ml") |
| `BrewStageView` | `Scene/BrewQueue/StageTimerView.swift` | The brew screen's circle with the step text and timer |
| `BrewQueueView` | `Scene/BrewQueue/BrewQueueView.swift` | The brew screen, with Skip and End |
| `EditRecipeAmountsView` | `Scene/EditRecipe/EditRecipeAmountsView.swift` | A small edit screen with its own Save |
| `CreateRecipeCoffeeWaterSelection` | `Scene/CreateRecipe/CreateRecipeCoffeeWaterSelection.swift` | Cups, cup size and ratio picker |
| `IngredientTypeItem`, `InstructionRequirementItem`, `InstructionInteractionMethodItem`, `IngredientAmountTypeItem` | `Views/Items/` | `Titled` picker items for the current editor |

### What each new element uses

| New element | Reuse or extend |
|---|---|
| Start choice (from a method / from scratch) | Two large tiles styled like `BrewMethodView`, on `.backgroundPrimary()` |
| Tile menu (Make it mine; Edit and Delete on own methods only) | Extend `BrewMethodView` with a visible menu button in the corner where `InfoButton` sits today; replaces the long-press menu in `CreateRecipeBrewMethodSelection` |
| Method screen header (Close, Save) | The header part of `PagerView`, taken out of the pager. Save always shown; Close asks only on changes |
| Name | `AlphanumericTextField` inside `TitledContent` |
| "Written for" line and its editor | `NumericTextField` for grams in a small sheet built like `EditRecipeAmountsView` |
| Step row | New row built from `RecipeRowView`'s layout and fonts: main line, quieter meta line, running total on the right |
| "+" between rows and at the end | The plus image and style of "Or, create your own" |
| Footer (totals, end time, warning, fix) | `foregroundSecondary` text on `BackgroundSecondary`; `.highlightAnimation` when it turns into a warning |
| Step palette | A sheet with a grid of small tiles styled like `BrewMethodView` |
| Grid icon picker | A row of the existing brewer icon assets used by `BrewMethodView` |
| Tweak this brew | A secondary button on `PostBrewView` (`Scene/BrewQueue/PostBrewView.swift`), below `BuyMeACoffeeView` |
| Step sheet: Amount, Time, Then | `TitledPicker` with new `Titled` items in user words, replacing `InstructionRequirementItem` and `InstructionInteractionMethodItem`; `NumericTextField` for grams and seconds (extend it to accept m:ss for "Done by") |
| Brew-screen line preview | `StageHeaderView`, so the preview looks like the brew screen |
| Tip line | `AlphanumericTextField` |
| Try it | `BrewQueueView` and `BrewStageView` with a dry-run recipe and shortened timers |
| Help text | `InfoButton` and `InfoView`, only where a short explanation helps |
| After save: cups, size, strength | `CreateRecipeCoffeeWaterSelection`, with the method's own ratio first |

The old editor views in `Scene/CreateMethod` (`InstructionActionViewBuilder`, the Message, Pause and Put action views, `CreateMethodDetailsView`) and their picker items in `Views/Items` were removed in stage 3.

## Watch in TestFlight

There is no separate prototype. The owner ships the new flow to TestFlight and watches these signals:

- whether people use Note, and for what,
- whether *Up to a total*, *Add an amount*, *The rest* and the time options read instantly,
- whether people find Make it mine and Edit on the tiles,
- how many start from a template and how many from scratch,
- whether anyone stalls on recipes with several equal pours.

## Decided (2026-11-23)

- **Water unit.** Grams everywhere: editor, brew screen and recipe amounts. Built-in methods are relabelled to g in display.
- **Old custom methods.** They brew exactly as before. Opening one in the new editor shows its steps in grams at a default dose of 15 g / 250 g, and saving converts it to the new format. Untouched methods never change.
- **"Split the rest into N pours".** Left out. Add it only if TestFlight testers stall on equal pours.
- **Timer limit.** Up to 60 minutes, entered as m:ss. This replaces the 300 s editor cap.
- **"Done by 1:15".** The editor converts it into a duration from the planned timeline (steps that wait for a tap count as 0 s) and shows it, for example "30 s pour". No engine change: the brew runs on durations.
- **Built-in tiles.** The menu offers only Make it mine. Edit and Delete appear only on the user's own methods. This fixes today's long-press Delete on built-in tiles.
- **Ice.** Ice comes from the method. The "Written for" line includes ice when the method adds it (for example 15 g coffee · 150 g water · 100 g ice). The method keeps that ice share, replacing the fixed 40%, and recipes scale it.
- **Grid icon.** A small icon row on the method screen with the existing brewer icons (V60, Chemex, AeroPress, French Press, kettle). The default is the template's icon; from scratch it is the kettle.
- **Editing a method that recipes use.** On save, the app asks "Update everywhere" or "Save as new".
- **Tweak this brew.** In this release. A quiet secondary button below the Buy Me a Coffee tip on the post-brew screen, which already shows after completed and ended brews. The review prompt timing is untouched. It opens the method editor on the method just brewed; for a built-in it opens a copy ("My V60") and on save offers to switch this recipe to it.
- **Amount rounding.** Nearest whole gram, replacing today's truncation. This is the default; the owner may revisit it.
- **Minimum iOS.** iOS 26 (today 17.6). This is a separate first piece of work: modernise the whole app to iOS 26 APIs, replace deprecated APIs and remove availability checks where possible. The new flow is built on top.

## Order of work

1. Raise the minimum to iOS 26 and modernise the app.
2. Model changes: method-owned decimal ratio, reference dose and ice share; rounding to the nearest gram; grams in display; timers up to 60 minutes.
3. The new creation flow and the tile menu.
4. Tweak this brew.
