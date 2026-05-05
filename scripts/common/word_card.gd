extends RigidBody2D
class_name WordCard
# WordCard 节点的 position 属性代表卡片的中心点。
enum Mode {
	STATIC,
	BOUNCE,
	FALL
}

@onready var panel: Panel = $Panel
@onready var label: Label = $Panel/Label
@onready var collision: CollisionShape2D = $CollisionShape2D

var word_text: String = "apple"
var current_mode: Mode = Mode.STATIC
signal clicked(card_text: String)

var _normal_style: StyleBoxFlat
var _hover_style: StyleBoxFlat

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# 临时碰撞体，防止初始化时形状为空导致鼠标检测失败
	var temp_shape = RectangleShape2D.new()
	temp_shape.size = Vector2(100, 60)
	collision.shape = temp_shape
	
	_create_styles()
	_apply_normal_style()
	_set_text()
	set_mode(Mode.STATIC)

func _set_text():
	label.text = word_text
	await get_tree().process_frame
	_update_size_and_collision()

func set_text(new_text: String):
	word_text = new_text
	label.text = new_text
	await get_tree().process_frame
	_update_size_and_collision()

func set_mode(mode: Mode):
	current_mode = mode
	match mode:
		Mode.STATIC:
			freeze = true
			linear_velocity = Vector2.ZERO
			angular_velocity = 0
		Mode.BOUNCE:
			freeze = false
			linear_damp = 0
			angular_damp = 0
			linear_velocity = Vector2(randf_range(-200, 200), randf_range(-200, 200))
			angular_velocity = randf_range(-2, 2)
			_apply_bounce_material(0.9)
		Mode.FALL:
			freeze = false
			linear_velocity = Vector2(0, 200)
			angular_velocity = 0
			_apply_bounce_material(0.2)

func _update_size_and_collision():
	var label_min_size = label.get_combined_minimum_size()
	var padding = Vector2(40, 30)  # 左右各20，上下各15
	var new_size = label_min_size + padding
	new_size.x = max(new_size.x, 100)
	new_size.y = max(new_size.y, 60)
	
	panel.custom_minimum_size = new_size
	panel.set_size(new_size)
	# Panel 锚点是中心，所以位置维持在 (0,0)
	panel.position = Vector2.ZERO
	
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = new_size
	collision.shape = rect_shape

func _create_styles():
	# 正常样式
	_normal_style = StyleBoxFlat.new()
	_normal_style.bg_color = Color(1, 1, 1)
	_normal_style.border_width_left = 2
	_normal_style.border_width_top = 2
	_normal_style.border_width_right = 2
	_normal_style.border_width_bottom = 2
	_normal_style.border_color = Color(0.8, 0.8, 0.8)
	_normal_style.corner_radius_top_left = 12
	_normal_style.corner_radius_top_right = 12
	_normal_style.corner_radius_bottom_left = 12
	_normal_style.corner_radius_bottom_right = 12
	_normal_style.shadow_size = 6
	_normal_style.shadow_offset = Vector2(0, 3)
	_normal_style.shadow_color = Color(0, 0, 0, 0.2)
	
	# 悬浮样式
	_hover_style = StyleBoxFlat.new()
	_hover_style.bg_color = Color(1, 1, 1)
	_hover_style.border_width_left = 2
	_hover_style.border_width_top = 2
	_hover_style.border_width_right = 2
	_hover_style.border_width_bottom = 2
	_hover_style.border_color = Color(0.4, 0.7, 1.0)
	_hover_style.corner_radius_top_left = 12
	_hover_style.corner_radius_top_right = 12
	_hover_style.corner_radius_bottom_left = 12
	_hover_style.corner_radius_bottom_right = 12
	_hover_style.shadow_size = 10
	_hover_style.shadow_offset = Vector2(0, 4)
	_hover_style.shadow_color = Color(0.4, 0.6, 1.0, 0.3)
	
	# Label 基础样式
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))

func _apply_normal_style():
	panel.add_theme_stylebox_override("panel", _normal_style)

func _apply_hover_style():
	panel.add_theme_stylebox_override("panel", _hover_style)

func _apply_bounce_material(bounce: float):
	if physics_material_override:
		physics_material_override.bounce = bounce
	else:
		var mat = PhysicsMaterial.new()
		mat.bounce = bounce
		physics_material_override = mat

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_animate_click()
		clicked.emit(word_text)

func _on_mouse_entered():
	_apply_hover_style()

func _on_mouse_exited():
	_apply_normal_style()

func _animate_click():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "scale", Vector2(0.95, 0.95), 0.08)
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.12)

# ---------- 尺寸获取接口 ----------
## 获取卡片视觉宽度（像素）
func get_card_width() -> float:
	return panel.size.x

## 获取卡片视觉高度（像素）
func get_card_height() -> float:
	return panel.size.y

## 获取卡片尺寸 Vector2
func get_card_size() -> Vector2:
	return panel.size
