extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var terrain_container: Node2D = $TerrainContainer
@onready var tries_label: Label = $UI/TriesLabel
@onready var message_label: Label = $UI/MessageLabel
@onready var retry_button: Button = $UI/RetryButton
@onready var accelerate_button: Button = $UI/AccelerateButton
@onready var brake_button: Button = $UI/BrakeButton
@onready var stunt_left_button: Button = $UI/StuntLeftButton
@onready var stunt_right_button: Button = $UI/StuntRightButton

var bike: Bike
var terrain: TerrainGenerator
var level_active := true

# roughness value per level -- tune / add more as you build out levels
const LEVEL_ROUGHNESS := {1: 20.0, 2: 45.0, 3: 75.0}

func _ready() -> void:
	GameState.reset_level(GameState.current_level)
	GameState.tries_changed.connect(_on_tries_changed)
	_update_tries_label()
	retry_button.hide()
	message_label.hide()

	accelerate_button.button_down.connect(func(): bike.set_accelerate(true))
	accelerate_button.button_up.connect(func(): bike.set_accelerate(false))
	brake_button.button_down.connect(func(): bike.set_brake(true))
	brake_button.button_up.connect(func(): bike.set_brake(false))
	stunt_left_button.pressed.connect(func(): bike.do_stunt(-1.0))
	stunt_right_button.pressed.connect(func(): bike.do_stunt(1.0))
	retry_button.pressed.connect(_on_retry_pressed)

	_start_level()

func _start_level() -> void:
	level_active = true
	message_label.hide()
	retry_button.hide()

	for child in terrain_container.get_children():
		child.queue_free()
	if bike:
		bike.queue_free()

	terrain = TerrainGenerator.new()
	terrain_container.add_child(terrain)
	var roughness: float = LEVEL_ROUGHNESS.get(GameState.current_level, 40.0)
	terrain.generate(roughness, GameState.current_level)

	bike = Bike.new()
	bike.position = Vector2(100, terrain.base_height - 100)
	bike.crashed.connect(_on_bike_crashed)
	add_child(bike)

func _process(_delta: float) -> void:
	if bike and level_active:
		camera.global_position = camera.global_position.lerp(bike.global_center(), 0.1)
		if bike.global_position.x >= terrain.get_end_x() - 50:
			_on_level_complete()
		elif bike.global_position.y > terrain.base_height + 1500:
			_on_bike_crashed()

func _on_bike_crashed() -> void:
	if not level_active:
		return
	level_active = false
	var has_tries_left: bool = GameState.use_try()
	if has_tries_left:
		message_label.text = "Crashed! Try again."
		message_label.show()
		await get_tree().create_timer(1.5).timeout
		_start_level()
	else:
		message_label.text = "Out of tries!"
		message_label.show()
		retry_button.show()

func _on_retry_pressed() -> void:
	# --- Ad hook ---
	# Replace this with your rewarded-ad SDK call (e.g. AdMob plugin).
	# Only call GameState.grant_retry() + _start_level() inside the ad's
	# "reward earned" callback, so players can't skip watching it.
	GameState.grant_retry()
	_start_level()

func _on_level_complete() -> void:
	level_active = false
	message_label.text = "Level Complete!"
	message_label.show()

func _on_tries_changed(remaining: int, max_tries: int) -> void:
	tries_label.text = "Tries: %d / %d" % [remaining, max_tries]

func _update_tries_label() -> void:
	tries_label.text = "Tries: %d / %d" % [GameState.tries_remaining, GameState.max_tries]
