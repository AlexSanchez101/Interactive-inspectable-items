extends KinematicBody

const GRAVITY = -24.8 #also, it's a max fall speed
const WALK_SPEED = 10
const ACCEL = 2
const DEACCEL = 8

var mouse_sensetivity = 0.3
var mouse_direction = Vector2()
var camera_v_angle = 0

var can_move = true
var inspecting = false

var velocity = Vector3()

signal inspect(item, item_name)

func _input(event):
	#mouse movement process (aiming)
	if can_move:
		if event is InputEventMouseMotion:
			mouse_direction = event.relative
			$CameraBase.rotate_y(deg2rad(-mouse_direction.x * mouse_sensetivity))
			var v_rotation = -mouse_direction.y * mouse_sensetivity
			if camera_v_angle + v_rotation > -90 and camera_v_angle + v_rotation < 90:
				camera_v_angle += v_rotation
				$CameraBase/CameraX.rotate_x(deg2rad(v_rotation))
			

func movement(delta):
	#movement
	var direction = Vector3()
	var aim = $CameraBase/CameraX.get_global_transform().basis
	if Input.is_action_pressed("move_forward"):
		direction -= aim.z
	if Input.is_action_pressed("move_backward"):
		direction += aim.z
	if Input.is_action_pressed("move_left"):
		direction -= aim.x
	if Input.is_action_pressed("move_right"):
		direction += aim.x
	
	#calculate horizontal movement only
	direction = direction.normalized()
	var destination = direction * WALK_SPEED
	destination.y = 0 #prevent aim to affect our vertical velocity
	var h_velocity = velocity
	h_velocity.y = 0 #horizontal velocity only
	var acceleration
	if direction.dot(h_velocity) > 0:
		acceleration = ACCEL
	else:
		acceleration = DEACCEL
	
	h_velocity = h_velocity.linear_interpolate(destination, acceleration * delta)
	
	velocity.x = h_velocity.x
	velocity.z = h_velocity.z
	velocity.y = lerp(velocity.y, GRAVITY, delta) #max fall speed

	velocity = move_and_slide(velocity, Vector3(0, -1, 0))
		
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	
	if can_move:
		movement(delta)
		
	#interactive
	$UI/InteractiveSign.visible = false
	if !inspecting:
		if $CameraBase/CameraX/Sight.is_colliding():
			var collider = $CameraBase/CameraX/Sight.get_collider()
			if collider.get_class() == "Interactive":
				if collider.inspect == true:
					$UI/InteractiveSign/Label.text = "Press E\nto inspect"
					$UI/InteractiveSign.visible = true
					if Input.is_action_just_pressed("use"):
						emit_signal("inspect", collider.get_parent(), collider.inspect_name) #collider parent mesh