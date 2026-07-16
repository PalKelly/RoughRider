extends Node

# Global singleton (autoloaded). Tracks the current level and how many
# tries the player has left. When tries hit 0, Main.gd shows the
# "watch ad to retry" screen instead of restarting automatically.

signal tries_changed(remaining: int, max_tries: int)

var current_level: int = 1
var tries_remaining: int = 3
var max_tries: int = 3

# How many tries each level allows before an ad is required.
var level_tries := {
	1: 3,
	2: 3,
	3: 2,
}

func reset_level(level: int) -> void:
	current_level = level
	max_tries = level_tries.get(level, 3)
	tries_remaining = max_tries
	tries_changed.emit(tries_remaining, max_tries)

# Call when the player crashes/fails. Returns true if they still have
# tries left, false if they're out (and should be shown the ad prompt).
func use_try() -> bool:
	tries_remaining -= 1
	tries_changed.emit(tries_remaining, max_tries)
	return tries_remaining > 0

# Call after a rewarded ad finishes successfully.
func grant_retry() -> void:
	tries_remaining = 1
	tries_changed.emit(tries_remaining, max_tries)

func advance_level() -> void:
	reset_level(current_level + 1)
