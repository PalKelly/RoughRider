extends Node2D
class_name TerrainGenerator

# Builds a bumpy 2D terrain strip out of noise, then turns it into both
# a visible Line2D and a solid CollisionPolygon2D for the bike to ride on.
# "roughness" controls how wild the bumps get -- pass a bigger number
# for harder levels.

@export var segment_width: float = 40.0
@export var num_segments: int = 240
@export var base_height: float = 800.0

var points: PackedVector2Array = []

func generate(roughness: float, seed_value: int = 0) -> void:
	var noise := FastNoiseLite.new()
	noise.seed = seed_value
	noise.frequency = 0.06
	noise.fractal_octaves = 3

	points.clear()
	for i in range(num_segments + 1):
		var x: float = i * segment_width
		var y: float = base_height + noise.get_noise_1d(float(i)) * roughness
		points.append(Vector2(x, y))

	_build_visual_and_collision()

func _build_visual_and_collision() -> void:
	for child in get_children():
		child.queue_free()

	var static_body := StaticBody2D.new()
	var collision := CollisionPolygon2D.new()
	var poly_points := points.duplicate()
	# Close the polygon off well below the terrain so it's a solid shape.
	poly_points.append(Vector2(points[points.size() - 1].x, base_height + 2000))
	poly_points.append(Vector2(points[0].x, base_height + 2000))
	collision.polygon = poly_points
	static_body.add_child(collision)

	var physmat := PhysicsMaterial.new()
	physmat.friction = 1.4
	static_body.physics_material_override = physmat

	add_child(static_body)

	var line := Line2D.new()
	line.points = points
	line.width = 8.0
	line.default_color = Color(0.35, 0.22, 0.12)
	add_child(line)

func get_end_x() -> float:
	return points[points.size() - 1].x

func get_start_x() -> float:
	return points[0].x
