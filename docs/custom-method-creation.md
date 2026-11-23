# Creating a custom brew method

Status: accepted design, not built yet. This page records how users will create their own brew method and why. The implementation should follow it. Questions that still need an answer are listed under [Open decisions](#open-decisions).

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
- **Concrete grams.** While creating and brewing, the user sees and types real amounts. The app converts them to ratios for scaling.
- **English only** for now.
- **Considered and not chosen:**
  - *AI import from text, a photo or speech*: on-device models need Apple Intelligence devices, and the idea was dropped.
  - *Recording a brew while doing it*: dropped.
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

### 2. Method screen

One scrolling screen that always shows the whole method:

- **Name.**
- **Written for 15 g coffee · 250 g water.** Tap to change. When the amounts change, the app asks whether to scale the steps. If yes, amounts scale and times stay the same.
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
- **Time**: *No timer*, *Takes 30 s* or *Done by 1:15* (a clock time from the start of the brew).
- **Then**: *Carry on by itself* or *Wait for my tap*. Each kind has a sensible default: a Wait carries on by itself, a Pour without a timer waits for a tap.
- **Brew-screen line**: generated from the fields, for example "Pour up to 150 g". The user can rewrite it in their own words, and the numbers in it stay live when amounts change.
- **Tip line** (optional), shown smaller under the main line on the brew screen.
- **Duplicate**, and **Delete** with Undo.

### 5. Save

- **Save** is always visible. If the method can't be saved yet, tapping Save explains what is missing ("Add a name", "Add at least one step").
- Drafts save automatically.
- **Close** asks only when something changed.
- After saving, the new method is selected in the grid and the flow continues to cups, cup size and strength, with the method's own ratio listed first and selected.

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
- **Decimal ratio maths.** `CoffeeToWaterRatio.value` is a `Double`, but `CreateContextToInputMapper.calculateCoffeeAmount` computes coffee as `waterAmount.amount / UInt(ratio.value)`, whole-number division. 1:16.7 becomes 1:16, and 500 g water gives 31 g coffee instead of 30 g. Amounts are also truncated to whole numbers (`UInt(...)`) when a step's amount is calculated.
- **Grams to factors.** The editor takes grams written for the reference dose and stores factors, so the method still scales to any recipe. For example "up to 300 g" in a 500 g method is saved as `0.6 × water − 1 × #current.water`.
- **Done by a clock time.** The engine only knows per-step durations. "Done by 1:15" has to be turned into a countdown from the step's computed start time, and recomputed when earlier steps change. The estimated end time adds up countdowns; steps that wait for a tap count as zero.
- **Generated text.** Each step's brew-screen line and tip are generated from its fields, with tokens inserted so numbers stay live. A user's own wording is stored as the message, with the same tokens.
- **Dry run.** "Try it" plays the method on the brew screen with shortened timers and without saving.
- **Edit after save.** There is no edit flow today. Editing must load the saved instructions back into the editor and save them under the same method id, so existing recipes made from the method pick up the change.
- **Longer timers.** Countdowns are limited to 300 s only in the editor UI (`NumericTextField` range in `InstructionActionViewBuilder.swift`). The engine accepts any positive length.
- **Existing custom methods.** Methods saved with the old editor are formula-based and have no reference dose. They must keep brewing as they do now. How they appear in the new editor is an open decision.

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
| Tile menu (Make it mine, Edit, Delete) | Extend `BrewMethodView` with a visible menu button in the corner where `InfoButton` sits today; replaces the long-press menu in `CreateRecipeBrewMethodSelection` |
| Method screen header (Close, Save) | The header part of `PagerView`, taken out of the pager. Save always shown; Close asks only on changes |
| Name | `AlphanumericTextField` inside `TitledContent` |
| "Written for" line and its editor | `NumericTextField` for grams in a small sheet built like `EditRecipeAmountsView` |
| Step row | New row built from `RecipeRowView`'s layout and fonts: main line, quieter meta line, running total on the right |
| "+" between rows and at the end | The plus image and style of "Or, create your own" |
| Footer (totals, end time, warning, fix) | `foregroundSecondary` text on `BackgroundSecondary`; `.highlightAnimation` when it turns into a warning |
| Step palette | A sheet with a grid of small tiles styled like `BrewMethodView` |
| Step sheet: Amount, Time, Then | `TitledPicker` with new `Titled` items in user words, replacing `InstructionRequirementItem` and `InstructionInteractionMethodItem`; `NumericTextField` for grams and seconds (extend it to accept m:ss for "Done by") |
| Brew-screen line preview | `StageHeaderView`, so the preview looks like the brew screen |
| Tip line | `AlphanumericTextField` |
| Try it | `BrewQueueView` and `BrewStageView` with a dry-run recipe and shortened timers |
| Help text | `InfoButton` and `InfoView`, only where a short explanation helps |
| After save: cups, size, strength | `CreateRecipeCoffeeWaterSelection`, with the method's own ratio first |

The old editor views in `Scene/CreateMethod` (`InstructionActionViewBuilder`, the Message, Pause and Put action views, `CreateMethodDetailsView`) can be removed once the new screens replace them.

## To test before building

Build a clickable prototype and try it with 3 to 5 people from both groups: someone copying a recipe from a video, and someone changing their own ritual. Watch whether they:

- find "Start from a method" and "Start from scratch" without help,
- understand *Up to a total*, *Add an amount* and *The rest* without an explanation,
- trust the footer, and use its one-tap fix when it warns,
- use "Try it" before saving,
- finish the V60 and Kalita walkthroughs in about the tap counts above.

## Open decisions

- **Grams or ml for water.** The design uses grams (what people read off a scale). Built-in methods and the brew screen show ml. Pick one unit for the editor and the brew screen, or show both.
- **Existing custom methods.** Methods saved with the old editor store formulas and have no reference dose. Options: convert them to the new format on first edit using a default dose, or show them read-only with a "Make it mine" copy.
- **"Split the rest into N pours".** A shortcut that creates several equal pours at once. Useful for pulse-pour recipes; not yet decided.
- **Lifting the 300 s limit.** The limit exists only in the editor. Cold or long immersion brews need longer timers. Decide on a new upper bound, or none.
