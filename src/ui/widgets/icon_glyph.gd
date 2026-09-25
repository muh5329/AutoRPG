class_name IconGlyph
extends Control
## Vector icons drawn in code (no image assets needed). Glyphs are authored in a
## 0..1 unit square and scaled to the control size.

@export var glyph: StringName = &"gem":
	set(v):
		glyph = v
		queue_redraw()
@export var color := Color.WHITE:
	set(v):
		color = v
		queue_redraw()
@export var outline := Color(0.1, 0.07, 0.15, 0.85)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var s := minf(size.x, size.y)
	var o := (size - Vector2(s, s)) * 0.5
	var c := color
	var dark := c.darkened(0.35)
	var light := c.lightened(0.35)
	match glyph:
		&"potion":
			_circle(o, s, Vector2(0.5, 0.62), 0.3, c)
			_poly(o, s, [Vector2(0.4, 0.12), Vector2(0.6, 0.12), Vector2(0.6, 0.38), Vector2(0.4, 0.38)], Color("e9f4ff"))
			_poly(o, s, [Vector2(0.37, 0.06), Vector2(0.63, 0.06), Vector2(0.63, 0.15), Vector2(0.37, 0.15)], Color("8a5a35"))
			_circle(o, s, Vector2(0.42, 0.55), 0.07, Color(1, 1, 1, 0.55))
		&"sword", &"mace":
			if glyph == &"sword":
				_poly(o, s, [Vector2(0.72, 0.08), Vector2(0.9, 0.1), Vector2(0.88, 0.28), Vector2(0.42, 0.66), Vector2(0.34, 0.58)], Color("e6edf5"))
			else:
				_poly(o, s, [Vector2(0.6, 0.35), Vector2(0.68, 0.43), Vector2(0.38, 0.7), Vector2(0.3, 0.62)], Color("8a5a35"))
				_circle(o, s, Vector2(0.7, 0.3), 0.18, c)
			_poly(o, s, [Vector2(0.24, 0.52), Vector2(0.3, 0.46), Vector2(0.54, 0.7), Vector2(0.48, 0.76)], Color("f2c45a"))
			_poly(o, s, [Vector2(0.36, 0.62), Vector2(0.42, 0.68), Vector2(0.2, 0.9), Vector2(0.14, 0.84)], Color("8a5a35"))
		&"staff", &"wand":
			_poly(o, s, [Vector2(0.62, 0.3), Vector2(0.7, 0.36), Vector2(0.24, 0.92), Vector2(0.16, 0.86)], Color("a0703f"))
			_circle(o, s, Vector2(0.72, 0.24), 0.16 if glyph == &"staff" else 0.12, c)
			_circle(o, s, Vector2(0.68, 0.2), 0.05, Color(1, 1, 1, 0.7))
		&"bow":
			_arc(o, s, Vector2(0.3, 0.5), 0.42, -1.2, 1.2, Color("a0703f"), 0.09)
			_line(o, s, Vector2(0.44, 0.12), Vector2(0.44, 0.88), Color("f5f0e6"), 0.03)
			_line(o, s, Vector2(0.2, 0.5), Vector2(0.9, 0.5), Color("e6edf5"), 0.05)
			_poly(o, s, [Vector2(0.9, 0.5), Vector2(0.78, 0.42), Vector2(0.78, 0.58)], Color("e6edf5"))
		&"armor":
			_poly(o, s, [Vector2(0.2, 0.2), Vector2(0.38, 0.12), Vector2(0.5, 0.2), Vector2(0.62, 0.12), Vector2(0.8, 0.2),
				Vector2(0.86, 0.45), Vector2(0.72, 0.5), Vector2(0.72, 0.88), Vector2(0.28, 0.88), Vector2(0.28, 0.5), Vector2(0.14, 0.45)], c)
			_line(o, s, Vector2(0.5, 0.24), Vector2(0.5, 0.86), dark, 0.04)
		&"gem":
			_poly(o, s, [Vector2(0.5, 0.08), Vector2(0.86, 0.4), Vector2(0.5, 0.92), Vector2(0.14, 0.4)], c)
			_poly(o, s, [Vector2(0.5, 0.08), Vector2(0.86, 0.4), Vector2(0.5, 0.4)], light)
			_poly(o, s, [Vector2(0.14, 0.4), Vector2(0.5, 0.4), Vector2(0.5, 0.92)], dark)
		&"coin":
			_circle(o, s, Vector2(0.5, 0.5), 0.42, Color("c98a1e"))
			_circle(o, s, Vector2(0.5, 0.47), 0.38, Color("f6c65b"))
			_circle(o, s, Vector2(0.5, 0.47), 0.24, Color("ffd97a"))
			_circle(o, s, Vector2(0.42, 0.38), 0.07, Color(1, 1, 1, 0.7))
		&"bag":
			_circle(o, s, Vector2(0.5, 0.62), 0.33, c)
			_poly(o, s, [Vector2(0.34, 0.14), Vector2(0.66, 0.14), Vector2(0.58, 0.34), Vector2(0.42, 0.34)], dark)
			_line(o, s, Vector2(0.36, 0.34), Vector2(0.64, 0.34), Color("f2c45a"), 0.05)
		&"book":
			_poly(o, s, [Vector2(0.14, 0.18), Vector2(0.5, 0.26), Vector2(0.5, 0.88), Vector2(0.14, 0.8)], c)
			_poly(o, s, [Vector2(0.5, 0.26), Vector2(0.86, 0.18), Vector2(0.86, 0.8), Vector2(0.5, 0.88)], light)
			for i in 3:
				_line(o, s, Vector2(0.58, 0.38 + i * 0.13), Vector2(0.78, 0.34 + i * 0.13), dark, 0.03)
		&"party":
			_circle(o, s, Vector2(0.32, 0.36), 0.14, light)
			_circle(o, s, Vector2(0.68, 0.36), 0.14, light)
			_circle(o, s, Vector2(0.32, 0.72), 0.2, c)
			_circle(o, s, Vector2(0.68, 0.72), 0.2, c)
			_circle(o, s, Vector2(0.5, 0.3), 0.16, Color.WHITE)
			_circle(o, s, Vector2(0.5, 0.7), 0.24, light)
		&"menu":
			for i in 3:
				_line(o, s, Vector2(0.2, 0.3 + i * 0.2), Vector2(0.8, 0.3 + i * 0.2), c, 0.09)
		&"check":
			_line(o, s, Vector2(0.18, 0.52), Vector2(0.42, 0.76), c, 0.13)
			_line(o, s, Vector2(0.42, 0.76), Vector2(0.84, 0.26), c, 0.13)
		&"cross":
			_line(o, s, Vector2(0.22, 0.22), Vector2(0.78, 0.78), c, 0.12)
			_line(o, s, Vector2(0.78, 0.22), Vector2(0.22, 0.78), c, 0.12)
		&"dot":
			_circle(o, s, Vector2(0.5, 0.5), 0.22, c)
		&"heart":
			_circle(o, s, Vector2(0.33, 0.38), 0.2, c)
			_circle(o, s, Vector2(0.67, 0.38), 0.2, c)
			_poly(o, s, [Vector2(0.14, 0.45), Vector2(0.86, 0.45), Vector2(0.5, 0.88)], c)
			_circle(o, s, Vector2(0.3, 0.33), 0.06, Color(1, 1, 1, 0.6))
		&"shield":
			_poly(o, s, [Vector2(0.5, 0.08), Vector2(0.86, 0.2), Vector2(0.8, 0.6), Vector2(0.5, 0.92), Vector2(0.2, 0.6), Vector2(0.14, 0.2)], c)
			_poly(o, s, [Vector2(0.5, 0.08), Vector2(0.86, 0.2), Vector2(0.8, 0.6), Vector2(0.5, 0.92)], dark)
		&"roar":
			_poly(o, s, [Vector2(0.12, 0.35), Vector2(0.4, 0.35), Vector2(0.62, 0.15), Vector2(0.62, 0.85), Vector2(0.4, 0.65), Vector2(0.12, 0.65)], c)
			_arc(o, s, Vector2(0.62, 0.5), 0.22, -0.9, 0.9, light, 0.06)
			_arc(o, s, Vector2(0.62, 0.5), 0.34, -0.9, 0.9, light, 0.06)
		&"bolt":
			_poly(o, s, [Vector2(0.58, 0.06), Vector2(0.22, 0.54), Vector2(0.46, 0.54), Vector2(0.38, 0.94), Vector2(0.78, 0.42), Vector2(0.54, 0.42)], c)
		&"snow":
			for i in 3:
				var ang := PI * i / 3.0
				var d := Vector2(cos(ang), sin(ang)) * 0.4
				_line(o, s, Vector2(0.5, 0.5) - d, Vector2(0.5, 0.5) + d, c, 0.08)
			_circle(o, s, Vector2(0.5, 0.5), 0.1, light)
		&"drop":
			_circle(o, s, Vector2(0.5, 0.62), 0.28, c)
			_poly(o, s, [Vector2(0.5, 0.08), Vector2(0.75, 0.52), Vector2(0.25, 0.52)], c)
			_circle(o, s, Vector2(0.42, 0.6), 0.07, Color(1, 1, 1, 0.6))
		&"star":
			var pts := PackedVector2Array()
			for i in 10:
				var ang := -PI * 0.5 + PI * i / 5.0
				var r := 0.44 if i % 2 == 0 else 0.2
				pts.append(Vector2(0.5, 0.52) + Vector2(cos(ang), sin(ang)) * r)
			_poly(o, s, pts, c)
		&"flame":
			_poly(o, s, [Vector2(0.5, 0.06), Vector2(0.78, 0.46), Vector2(0.76, 0.72), Vector2(0.5, 0.92), Vector2(0.24, 0.72), Vector2(0.24, 0.46), Vector2(0.38, 0.3)], c)
			_poly(o, s, [Vector2(0.5, 0.4), Vector2(0.64, 0.64), Vector2(0.5, 0.84), Vector2(0.36, 0.64)], light)
		&"up":
			_poly(o, s, [Vector2(0.5, 0.1), Vector2(0.85, 0.5), Vector2(0.62, 0.5), Vector2(0.62, 0.9), Vector2(0.38, 0.9), Vector2(0.38, 0.5), Vector2(0.15, 0.5)], c)
		&"lock":
			_arc(o, s, Vector2(0.5, 0.42), 0.2, PI, TAU, c, 0.08)
			_poly(o, s, [Vector2(0.22, 0.42), Vector2(0.78, 0.42), Vector2(0.78, 0.88), Vector2(0.22, 0.88)], c)
			_circle(o, s, Vector2(0.5, 0.62), 0.07, dark)
		&"arrow_up":
			_poly(o, s, [Vector2(0.5, 0.2), Vector2(0.85, 0.72), Vector2(0.15, 0.72)], c)
		&"arrow_down":
			_poly(o, s, [Vector2(0.5, 0.8), Vector2(0.85, 0.28), Vector2(0.15, 0.28)], c)
		&"skull":
			_circle(o, s, Vector2(0.5, 0.44), 0.34, c)
			_poly(o, s, [Vector2(0.32, 0.6), Vector2(0.68, 0.6), Vector2(0.64, 0.86), Vector2(0.36, 0.86)], c)
			_circle(o, s, Vector2(0.37, 0.45), 0.09, dark)
			_circle(o, s, Vector2(0.63, 0.45), 0.09, dark)
		_:
			_circle(o, s, Vector2(0.5, 0.5), 0.35, c)


func _p(o: Vector2, s: float, v: Vector2) -> Vector2:
	return o + v * s


func _poly(o: Vector2, s: float, pts, col: Color) -> void:
	var out := PackedVector2Array()
	for v in pts:
		out.append(_p(o, s, v))
	draw_colored_polygon(out, col)
	var closed := out.duplicate()
	closed.append(out[0])
	draw_polyline(closed, outline, maxf(1.0, s * 0.035), true)


func _circle(o: Vector2, s: float, center: Vector2, radius: float, col: Color) -> void:
	draw_circle(_p(o, s, center), radius * s, outline)
	draw_circle(_p(o, s, center), radius * s - maxf(1.0, s * 0.03), col)


func _line(o: Vector2, s: float, a: Vector2, b: Vector2, col: Color, width: float) -> void:
	draw_line(_p(o, s, a), _p(o, s, b), outline, width * s + maxf(2.0, s * 0.05), true)
	draw_line(_p(o, s, a), _p(o, s, b), col, width * s, true)


func _arc(o: Vector2, s: float, center: Vector2, radius: float, from: float, to: float, col: Color, width: float) -> void:
	draw_arc(_p(o, s, center), radius * s, from, to, 24, outline, width * s + maxf(2.0, s * 0.05), true)
	draw_arc(_p(o, s, center), radius * s, from, to, 24, col, width * s, true)
