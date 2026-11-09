@tool
@icon("res://addons/almios_afterimage/icon.svg")
class_name Afterimage2D
extends Node2D

## Afterimages: fading copies of a sprite left behind as it moves. Dashes,
## dodges, teleports, speed boosts. Add it as a child of a Sprite2D or an
## AnimatedSprite2D (or set `target`): it copies the current frame, flip,
## rotation, scale and offset by itself.
## Afterimage (free) by Dimension Almios, MIT licence. The full Trails FX adds sword
## trails that follow the blade, ribbons behind projectiles and one-call slash arcs:
## https://dimensionalmios.itch.io/almios-trails-fx

enum Look { NORMAL, TINT, SILHOUETTE }

## Leave copies while true (turn it on for the length of a dash).
@export var emitting := true
## The sprite to copy. Empty = the parent.
@export var target: Node2D
## Seconds between two copies, at least (see min_distance too).
@export_range(0.01, 0.5) var interval := 0.05
## A copy only when the sprite has moved at least this far (pixels): no pile of
## copies while it stands still.
@export_range(0.0, 100.0) var min_distance := 14.0
## Seconds a copy takes to fade away.
@export_range(0.05, 3.0) var lifetime := 0.3
## NORMAL: the sprite itself. TINT: its shading in the colour. SILHOUETTE: flat colour.
@export var look := Look.TINT
## Colour over the life of a copy (left = new). Empty = the colour below, fading.
@export var gradient: Gradient
@export var color := Color(0.45, 0.75, 1.0, 0.7)
## Additive blending: glowing copies on dark scenes.
@export var additive := false
## Copies shrink to this scale at the end of their life (1 = no shrink, 0.5 = they clearly
## dwindle away).
@export_range(0.2, 1.5) var end_scale := 0.92
## Drawn just behind the sprite (true) or just in front of it, in the sprite's own
## place in the draw order (when this node is a child of the sprite).
@export var behind := true:
	set(v):
		behind = v
		_sync_order()

const SHADER := preload("res://addons/almios_afterimage/afterimage.gdshader")
const SHADER_ADD := preload("res://addons/almios_afterimage/afterimage_add.gdshader")

var _ghosts: Array = []       # [Sprite2D, age, Transform2D where it was left]
var _timer := 0.0
var _last := Vector2.INF
var _layer: Node2D


func _ready() -> void:
	# the copies are children of this node, so they are drawn in the sprite's place in
	# the draw order (see behind); each frame puts them back where they were left
	_layer = Node2D.new()
	add_child(_layer, false, INTERNAL_MODE_FRONT)
	_sync_order()


# behind: drawn just before the sprite (and after whatever is drawn before it), so
# the copies never cover the sprite, and a background never hides them the way a
# negative z_index would
func _sync_order() -> void:
	if _layer:
		show_behind_parent = behind


## Leaves one copy right now (the start of a dash, a teleport).
func burst() -> void:
	var t := _target()
	if t:
		_spawn(t)


## Removes every copy at once.
func clear() -> void:
	for g in _ghosts:
		g[0].queue_free()
	_ghosts.clear()


func _target() -> Node2D:
	if target:
		return target
	var p := get_parent()
	return p if (p is Sprite2D or p is AnimatedSprite2D) else null


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	# nothing to leave and nothing fading: no cost
	if not emitting and _ghosts.is_empty():
		return
	var t := _target()
	_timer -= delta
	if emitting and t and t.is_visible_in_tree() and _timer <= 0.0:
		if _last == Vector2.INF or _last.distance_to(t.global_position) >= min_distance:
			_spawn(t)
			_timer = interval
	var i := 0
	while i < _ghosts.size():
		var g: Array = _ghosts[i]
		g[1] += delta
		var k: float = g[1] / lifetime
		if k >= 1.0:
			g[0].queue_free()
			_ghosts.remove_at(i)
			continue
		var s: Sprite2D = g[0]
		var col := gradient.sample(k) if gradient else Color(color.r, color.g, color.b, color.a * (1.0 - k))
		# the colour goes through the shader (modulate would tint the NORMAL look too)
		(s.material as ShaderMaterial).set_shader_parameter("tint", col)
		# where it was left, shrinking toward end_scale
		var xf: Transform2D = g[2]
		var f := lerpf(1.0, end_scale, k)
		s.global_transform = Transform2D(xf.x * f, xf.y * f, xf.origin)
		i += 1


func _spawn(t: Node2D) -> void:
	if _layer == null:
		return   # (burst() before the node is in the tree: nothing to draw on yet)
	var tex: Texture2D
	var region := Rect2()
	var centered := true
	var off := Vector2.ZERO
	var flip_h := false
	var flip_v := false
	if t is Sprite2D:
		var sp: Sprite2D = t
		tex = sp.texture
		centered = sp.centered
		off = sp.offset
		flip_h = sp.flip_h
		flip_v = sp.flip_v
		# the frame grid is cut inside the region when there is one (an atlas)
		var area := sp.region_rect if sp.region_enabled else Rect2(Vector2.ZERO, tex.get_size() if tex else Vector2.ZERO)
		if sp.hframes > 1 or sp.vframes > 1:
			var fs := area.size / Vector2(sp.hframes, sp.vframes)
			region = Rect2(area.position + Vector2(sp.frame_coords) * fs, fs)
		elif sp.region_enabled:
			region = area
	elif t is AnimatedSprite2D:
		var an: AnimatedSprite2D = t
		if an.sprite_frames:
			tex = an.sprite_frames.get_frame_texture(an.animation, an.frame)
		centered = an.centered
		off = an.offset
		flip_h = an.flip_h
		flip_v = an.flip_v
	if tex == null:
		return
	var g := Sprite2D.new()
	g.texture = tex
	if region.has_area():
		g.region_enabled = true
		g.region_rect = region
	g.centered = centered
	g.offset = off
	g.flip_h = flip_h
	g.flip_v = flip_v
	var m := ShaderMaterial.new()
	m.shader = SHADER_ADD if additive else SHADER
	m.set_shader_parameter("mode", int(look))
	m.set_shader_parameter("tint", gradient.sample(0.0) if gradient else color)
	g.material = m
	g.texture_filter = t.texture_filter
	_layer.add_child(g)
	g.global_transform = t.global_transform
	_ghosts.append([g, 0.0, t.global_transform])
	_last = t.global_position
