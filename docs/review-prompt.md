# App Store review prompt

CoffeeTimer asks for an App Store review with Apple's native prompt (SwiftUI `@Environment(\.requestReview)`). There is no custom "Do you like the app?" screen first. The app only asks at moments where the user has just done something that shows they get value from it. The system then decides whether the prompt actually appears.

## Moments

### Accepted

| Moment | Where it is asked | Rule | Why |
|---|---|---|---|
| Brew completed (every step followed to the end) | Post-brew screen, 1.5 s after it appears | From the 2nd meaningful brew on | The user has just finished making coffee with the app. Waiting for the 2nd brew skips the first trial run. |
| Brew ended with "End" | Post-brew screen, 1.5 s after it appears | From the 3rd meaningful brew on | Most users end a brew early once they know the remaining steps, so this is where most brews finish. It is a weaker signal than a completed brew, so it waits one brew longer. |
| Custom brew method created | Main screen, 1 s after the recipes screen closes | 1st method | Building a method is a deliberate investment in the app, and it is rare. |
| Recipe created | Main screen, 1 s after the recipes screen closes | From the 2nd recipe on | The first recipe is often a trial. A second one means the user is coming back. |
| Recipe amounts edited and saved | Main screen, 1 s after the edit sheet closes | From the 2nd save on | Adjusting amounts again shows the user is tuning the app to their routine. |

A **meaningful brew** lasts at least 60 seconds from "Begin". Shorter brews are likely a misclick or a quick look at the steps. They don't count, whether they were completed by skipping every step or ended with "End".

### Rejected

| Moment | Why not |
|---|---|
| Brew started, a stage completed, a timer finishing | The user is in the middle of a brew. |
| Brew ended in under 60 seconds | Likely a misclick or a quick look, not satisfaction. |
| Tapping "Buy Me a Coffee" (post-brew or gift screen) | A strong positive signal, but the user leaves the app for the browser. Asking for a tip and a review back to back is too much. |
| Opening the gift screen | A sheet is on screen. Asking from inside it would stack two prompts. |
| Selecting a recipe | Routine navigation, no clear satisfaction. |
| Opening the brew method info | Vague: the user may be confused, not satisfied. |
| App launch or the Nth launch | No action behind it, so the signal is vague. |
| Deleting a recipe or a custom method | May mean frustration or clean-up. |
| Cancelling or closing a flow without saving, swiping the edit sheet away | Not a positive signal. |
| Validation errors in the create flows, failed fetches of brew methods or instructions | Frustration. |

## Timing rules

- **Counters only go up.** Rules are "from the Nth time on", so a moment that was missed (for example, the user left the post-brew screen within 1.5 s) qualifies again the next time.
- **At most one request per app version.** After a request, nothing is asked again until the app is updated.
- **At least 30 days between requests**, even across versions. Apple also shows the prompt at most 3 times in 365 days and may show nothing at all, so the app does not try harder than that.
- **No days-since-install or minimum-launch gate.** Usage is infrequent (a brew or two a day at most), so extra gates would delay the prompt by weeks and miss the user's early interest.
- **Never mid-flow.** Moments inside the recipes screen (creating a recipe or a custom method) are kept pending until that screen closes. Right before asking, the app checks again that no brew is running and no sheet or full-screen flow is open. If one is, the request is dropped. A pending moment is also dropped once the app has checked it, so it never shows up later out of context.

## Ending a brew early

Tapping "End" after at least 60 seconds now shows the same post-brew screen as a completed brew, including the Buy Me a Coffee call to action. Ending before 60 seconds goes back to the start screen, as before.

## Implementation

- `CoffeeTimer/ReviewPrompt/ReviewPromptPolicy.swift`: `ReviewPromptPolicy` / `ReviewPromptPolicyImp` hold the rules above. The counters and the last request (date and app version) are stored as one `ReviewPromptState` value under the `reviewPromptState` key through `StorageImp`. Screens call `record(_:)` for a moment, `takePendingTrigger()` at a settled screen, and `didRequestReview()` when they ask.
- `CoffeeTimer/iOS/ViewModifiers/View+ReviewPrompt.swift`: the `.reviewPrompt(trigger:delay:confirm:)` modifier waits for the delay, asks the view model to confirm, then calls `requestReview`. The wait is cancelled if the screen goes away.
- `BrewQueueViewModel` records brews and asks from the post-brew screen. `AppFlowViewModel` asks on the main screen after the recipes screen or the edit sheet closes. `CreateRecipeViewModel`, `CreateMethodViewModel` and `EditRecipeAmountsViewModel` record their moments.
- Analytics: `review_prompt_requested` (`trigger`: `brew_completed`, `brew_ended`, `method_created`, `recipe_created`, `amounts_edited`) and `post_brew_shown` (`source`: `completed`, `ended`). `brew_cancelled` now carries `stage_index` and `elapsed_seconds`.
- To change a rule, edit `ReviewPromptPolicyImp.Rules` or `BrewSessionRules.meaningfulDuration` and update this page and `ReviewPromptPolicyImpTests`.
