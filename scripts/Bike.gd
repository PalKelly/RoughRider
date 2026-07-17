extends Node2D
class_name Bike

# The bike is built entirely in code (no hand-authored nested .tscn needed):
# a chassis RigidBody2D, two wheel RigidBody2D's, connected by
# DampedSpringJoint2D's for suspension. Torque on the rear wheel drives
# the bike forward; a stunt button applies an angular impulse to the
# chassis for mid-air flips.

signal crashed

@export var motor_torque: float = 4500.0
@export var brake_torque: float = 3500.0
@export var stunt_impulse: float = 7000.0

var chassis: RigidBody2D
var front_wheel: RigidBody2D
var rear_wheel: RigidBody2D

var accelerating := false
var braking := false

var upside_down_time := 0.0
const CRASH_FLIP_TIME := 2.0

func _ready() -> void:
	_build_bike()

func _build_bike() -> void:
	chassis = RigidBody2D.new()
	chassis.name = "Chassis"
	chassis.mass = 12.0
	chassis.can_sleep = false
	var chassis_shape := CollisionShape2D.new()
	var chassis_rect := RectangleShape2D.new()
	chassis_rect.size = Vector2(90, 26)
	chassis_shape.shape = chassis_rect
	chassis.add_child(chassis_shape)

	var chassis_visual := Polygon2D.new()
	chassis_visual.polygon = PackedVector2Array([
		Vector2(-45, -13), Vector2(45, -13), Vector2(45, 13), Vector2(-45, 13)
	])
	chassis_visual.color = Color(0.9, 0.2, 0.2)
	chassis.add_child(chassis_visual)

	add_child(chassis)

	rear_wheel = _make_wheel("RearWheel", Vector2(-35, 25))
	front_wheel = _make_wheel("FrontWheel", Vector2(35, 25))
	add_child(rear_wheel)
	add_child(front_wheel)

	_attach_wheel_joint(rear_wheel)
	_attach_wheel_joint(front_wheel)

func _make_wheel(wheel_name: String, offset: Vector2) -> RigidBody2D:
	var wheel := RigidBody2D.new()
	wheel.name = wheel_name
	wheel.mass = 3.0
	wheel.can_sleep = false
	wheel.position = offset
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 18.0
	shape.shape = circle
	wheel.add_child(shape)

	var wheel_visual := Polygon2D.new()
	var points := PackedVector2Array()
	var segments := 16
	for i in range(segments):
		var angle := (float(i) / segments) * TAU
		points.append(Vector2(cos(angle), sin(angle)) * 18.0)
	wheel_visual.polygon = points
	wheel_visual.color = Color(0.15, 0.15, 0.15)
	wheel.add_child(wheel_visual)

	var spoke := Polygon2D.new()
	spoke.polygon = PackedVector2Array([
		Vector2(-2, -18), Vector2(2, -18), Vector2(2, 18), Vector2(-2, 18)
	])
	spoke.color = Color(0.6, 0.6, 0.6)
	wheel.add_child(spoke)

	var physmat := PhysicsMaterial.new()
	physmat.friction = 1.6
	wheel.physics_material_override = physmat
	return wheel

func _attach_wheel_joint(wheel: RigidBody2D) -> void:
	var joint := DampedSpringJoint2D.new()
	add_child(joint)
	joint.node_a = chassis.get_path()
	joint.node_b = wheel.get_path()
	joint.length = 40.0
	joint.rest_length = 40.0
	joint.stiffness = 900.0
	joint.damping = 18.0

func _physics_process(delta: float) -> void:
	if accelerating:
		rear_wheel.apply_torque(motor_torque)
	if braking:
		rear_wheel.apply_torque(-brake_torque)
		front_wheel.apply_torque(-brake_torque * 0.5)
	_check_flip(delta)

func set_accelerate(value: bool) -> void:
	accelerating = value

func set_brake(value: bool) -> void:
	braking = value

# direction: -1 for a backflip lean, 1 for a forward flip lean
func do_stunt(direction: float) -> void:
	chassis.apply_torque_impulse(stunt_impulse * direction)

func _check_flip(delta: float) -> void:
	var up := Vector2.UP.rotated(chassis.rotation)
	if up.y > 0.3:
		upside_down_time += delta
		if upside_down_time >= CRASH_FLIP_TIME:
			crashed.emit()
	else:
		upside_down_time = 0.0

func global_center() -> Vector2:
	return chassis.global_position
