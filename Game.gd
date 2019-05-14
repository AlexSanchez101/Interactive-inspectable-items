extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var mouse_sensetivity = 0.3

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if $Player.inspecting:
		if event is InputEventMouseMotion:
			var mouse_direction = event.relative
			if Input.is_action_pressed("left_mouse_button"):
				$InspectCamera/Item.rotate_y(deg2rad(mouse_direction.x * mouse_sensetivity))
				$InspectCamera/Item.rotate_x(deg2rad(mouse_direction.y * mouse_sensetivity))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if $Player.inspecting:
			$Player.inspecting = false
			$Player.can_move = true
			$InspectCamera/Camera.current = false
			$InspectCamera/Item.rotation = Vector3(-0, 0, 0)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			$UI/InspectItemName.visible = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("reset_scene"):
		get_tree().reload_current_scene()


func _on_Player_inspect(item, item_name):
	if $InspectCamera/Item.get_child_count() > 0: #maybe add later a feature to not load the same object's mesh
		for i in range(0, $InspectCamera/Item.get_child_count()):
    		$InspectCamera/Item.get_child(i).queue_free()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Player.can_move = false
	$Player.inspecting = true
	$InspectCamera/Item.add_child(item.duplicate())
	$InspectCamera/Camera.current = true
	$UI/InspectItemName.visible = true
	$UI/InspectItemName/Label.text = item_name