# LingoBridge — Phase 1: Foundation

**Status:** Phase 1 complete (project setup, folder structure, theme, navigation, auth scaffold).
Waiting on your approval before starting Phase 2.

## What's in this drop

```
lib/
├── core/                    # Cross-cutting, no business logic
│   ├── constants/           # SupportedLanguage, TranslationDomain, API/storage keys
│   ├── theme/                # AppTheme (Material 3, light/dark, single seed color)
│   ├── network/, errors/, utils/   # empty, reserved for Phase 3
├── data/                    # Reserved for Phase 2+ (repositories, datasources, models)
├── domain/                  # Reserved for Phase 2+ (entities, usecases)
├── presentation/
│   ├── providers/           # theme_provider, connectivity_provider, auth_provider
│   ├── screens/
│   │   ├── splash/
│   │   ├── onboarding/
│   │   ├── auth/login_screen.dart
│   │   ├── home/home_shell.dart        # bottom-nav shell
│   │   ├── translation/                # scaffold only — full UI is Phase 2
│   │   ├── history/, downloads/, settings/   # scaffolds
│   │   └── voice/, profile/            # empty, reserved for Phase 2/3
│   └── widgets/              # reserved for shared components
├── routes/app_router.dart    # go_router with auth-aware redirect
├── app.dart
└── main.dart
```

## Why these choices

**Clean architecture split (presentation / domain / data / core).**
`presentation` never talks to a database or an API directly — it only calls
providers, which will call repositories (domain contracts) that `data`
implements. Right now `data`/`domain` are empty because Phase 1 has no real
data yet, but the screens and providers are already written *as if* they
existed, so plugging in SQLite (Phase 2) and Khaya/NLLB (Phase 3) won't
require touching any screen file.

**Riverpod over Provider.** The spec listed both as options. Riverpod was
chosen because it doesn't require `BuildContext` to read state (useful for
the connectivity listener and future background sync), it's compile-safe
(no `ProviderNotFound` at runtime), and it composes cleanly with
`riverpod_generator` if the project wants generated providers later.

**go_router over `Navigator` push/pop.** LingoBridge is going to be a PWA
(Phase 5) and needs deep-linkable, URL-addressable screens. go_router gives
one declarative route table that works for mobile *and* web from day one,
plus built-in auth redirect logic (`redirect:` in `app_router.dart`) instead
of hand-rolled guards on every screen.

**One seed color, not hand-picked palettes.** `AppTheme` derives both light
and dark `ColorScheme`s from a single `_seed` color via
`ColorScheme.fromSeed`. This is what makes the future "Theme Color" setting
a one-line change instead of a redesign, and it guarantees light/dark parity
(every color has a correct dark counterpart automatically).

**Auth is a placeholder, not a stub you'll throw away.** `AuthNotifier`
already has the real shape (state machine: unknown → authenticated /
unauthenticated, JWT restore-on-launch via `flutter_secure_storage`). Only
`loginPlaceholder()` is fake — Phase 3 swaps its body for a real
`POST /auth/login` call. The screens, router guards, and state model don't
change.

**Connectivity as its own provider, not inline `Connectivity()` calls.**
The spec's application flow diagram hinges on "Internet Available? → Khaya
API : Local NLLB". Centralizing that check in `connectivityProvider` means
the Phase 3 translation logic can be a pure `if (online) ... else ...`
against one piece of state, testable without a real network.

**Bottom nav has 4 destinations, not the full 9-screen list.** Splash and
Onboarding are pre-auth, one-time flows (not nav destinations). Voice is
reached from inside Translation (it's a mode of translating, not a separate
place). Profile is reached from Settings. This keeps the bottom nav at
Material 3's recommended 3–5 items instead of cramming in 9 tabs.

## Not yet implemented (by design — later phases)

- Actual translation logic, text input/output, domain selector → **Phase 2**
- SQLite offline history/favourites persistence → **Phase 2**
- Khaya API client, speech-to-text, text-to-speech, voice playback controls → **Phase 3**
- Local NLLB model integration, language pack downloads → **Phase 4**
- Backend (FastAPI, PostgreSQL, Redis, JWT issuance) → separate `/backend` service, not started
- Testing, CI, store deployment configs → **Phase 5**

## Running this

```bash
flutter pub get
flutter run
```

No backend or API keys are required to run Phase 1 — login uses a local
placeholder session so the full navigation flow (splash → onboarding →
login → home tabs) is testable end-to-end right now.

---

**Next step:** once you approve this, Phase 2 builds the real Translation
screen (text input, translate action against a mocked repository, domain
chips, result card with copy/favourite) and the SQLite-backed History
screen. Let me know if you want any Phase 1 file changed before I move on.
