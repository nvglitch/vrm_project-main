extends CharacterBody3D

# --- 节点引用 ---
# 你的 VRM 模型节点（用来负责转身）
# 如果你的模型叫别的名字（比如 "Avatar"），请在这里修改！
@onready var visuals = $VRM_Visuals 

# 你的动画播放器（新建的那个 BodyPlayer）
@onready var anim_player = $BodyPlayer 

# 你的摄像机（用来判断前后左右的方向）
@onready var camera = $Camera3D

# --- 参数设置 ---
const SPEED = 5.0           # 跑步速度
const JUMP_VELOCITY = 4.5   # 跳跃高度
const ROTATION_SPEED = 15.0 # 转身速度 (越大转身越快)

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	# 1. 处理重力
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 2. 处理跳跃
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. 获取输入 (WASD)
	# 请确保你在 Project Settings -> Input Map 里设置好了 move_forward 等按键
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	# 4. 【核心】计算移动方向 (基于摄像机视角)
	var direction = Vector3.ZERO
	
	if camera:
		# 获取摄像机的水平朝向 (把 Y 轴拍扁，防止往地底下钻)
		var cam_basis = camera.global_transform.basis
		var forward = -cam_basis.z # Godot中 -Z 是前方
		var right = cam_basis.x
		
		forward.y = 0
		right.y = 0
		
		forward = forward.normalized()
		right = right.normalized()
		
		# 最终方向 = 前方 * W/S + 右方 * A/D
		# 注意：Input.get_vector 的 y 分量对应前后 (move_forward/back)
		direction = (forward * input_dir.y + right * input_dir.x).normalized()
	else:
		# 如果没摄像机，就按世界坐标走 (备用)
		direction = Vector3(input_dir.x, 0, input_dir.y).normalized()

	# 5. 执行移动与转身
	if direction != Vector3.ZERO:
		# A. 设置速度
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# B. 【关键】只旋转模型 (Visuals)，不旋转根节点！
		# 这样摄像机就不会跟着乱转了
		var target_angle = atan2(direction.x, direction.z)
		visuals.rotation.y = lerp_angle(visuals.rotation.y, target_angle, ROTATION_SPEED * delta)
		
		# C. 播放跑步动画
		play_anim_smart("Run")
		
	else:
		# 没按键，停下
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		# 播放待机动画
		play_anim_smart("Idle")

	move_and_slide()

# --- 智能播放函数 (不用改) ---
func play_anim_smart(keyword):
	if not anim_player: return
	var list = anim_player.get_animation_list()
	for anim_name in list:
		if keyword.to_lower() in anim_name.to_lower():
			if anim_player.current_animation != anim_name:
				anim_player.play(anim_name, 0.2)
			return
