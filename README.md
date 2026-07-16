# Rough Rider

An arcade motorcycle game: rough procedural terrain, physics-based bike
(gravity, suspension, torque), tap controls for gas/brake/stunts, and a
fixed-tries-per-level system that prompts a rewarded-ad retry when tries
run out.

## How the build works (no PC needed)

Every time you push to `main`, GitHub Actions:
1. Downloads Godot 4.3 + export templates on a cloud Linux machine
2. Exports the project to an Android `.apk`
3. Attaches the `.apk` to a new GitHub Release you can download straight
   to your phone

## First-time setup

1. Create a new **public** GitHub repo (private repos work too, Actions
   minutes are just limited on the free tier).
2. Upload every file/folder in this project to the repo, keeping the
   folder structure exactly as-is (use the GitHub app or the "Add file →
   Upload files" button on github.com — drag the whole folder in).
3. Go to the repo's **Actions** tab and enable workflows if prompted.
4. Push (or just uploading files counts as a push to `main`) — this
   kicks off the build automatically.
5. Once the run finishes (few minutes), check the repo's **Releases**
   tab (right sidebar) for the `.apk`. Download it on your phone and
   tap to install (you'll need "install unknown apps" allowed for your
   browser/file manager).

## What's already built

- **Bike.gd** — chassis + two wheels as RigidBody2D's connected by
  spring joints, torque-driven rear wheel, stunt flip impulses, crash
  detection when upside-down too long
- **TerrainGenerator.gd** — procedural bumpy terrain, roughness scales
  per level
- **GameState.gd** — tracks current level + tries remaining
- **Main.gd** — spawns bike/terrain, wires up on-screen buttons, handles
  crash → retry → "out of tries → watch ad" flow

## What you'll still want to add

- **Real ads**: `Main.gd`'s `_on_retry_pressed()` has a clearly marked
  spot to plug in a rewarded-ad SDK (e.g. the Godot AdMob Android
  plugin). Right now it just grants the retry for free so you can test
  the flow.
- **More levels**: add entries to `LEVEL_ROUGHNESS` in `Main.gd` and
  `level_tries` in `GameState.gd`.
- **Art**: currently the bike/terrain are plain shapes (rectangles,
  circles, a brown line) so the physics and flow are testable. Swap in
  sprites via `Sprite2D` nodes once you're happy with how it plays.
- **Sound/particles** for crashes, landings, stunts.

## Editing on your phone

Since `.tscn` and `.gd` files are plain text, you can edit them directly
in GitHub's web editor (tap the pencil icon on any file) or the GitHub
mobile app — no Godot editor install required to iterate on gameplay
logic. Every save triggers a fresh build automatically.
