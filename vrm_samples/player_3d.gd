extends CharacterBody3D

# --- 节点引用 ---
@onready var visuals = $VRM_Visuals   # 你的模型节点
@onready var anim_player = $BodyPlayer # 你的动画播放器
@onready var camera = $SpringArm3D/Camera3D  # 你的摄像机

# --- 参数设置 ---
const SPEED = 5.0             # 跑步速度
const JUMP_VELOCITY = 4.5     # 跳跃高度
const ROTATION_SPEED = 15.0   # 转身速度

# 获取重力
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
    # 1. 重力
    if not is_on_floor():
        velocity.y -= gravity * delta

    # 2. 跳跃 (按空格)
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY
        play_anim_smart("Jump")

    # 3. 移动输入 (WASD)
    var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    
    # 【关键修复】计算方向 (Direction)
    # 必须把输入转换为相对于摄像机的方向，否则按 W 永远只向一个方向跑
    var direction = Vector3.ZERO
    if input_dir != Vector2.ZERO:
        # 获取摄像机的水平方向
        var cam_basis = camera.global_transform.basis
        direction = (cam_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
        direction.y = 0 # 确保不往天上飞
        direction = direction.normalized()

    # 4. 动画状态机
    if not is_on_floor():
        # A. 如果在空中 -> 播放跳跃
        play_anim_smart("Jump")
    else:
        # B. 如果在地面
        if direction:
            play_anim_smart("Run")
        else:
            play_anim_smart("Idle")

    # 5. 移动与转身逻辑
    if direction:
        # 有输入：移动并转身
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
        
        # 计算目标角度并平滑旋转
        var target_angle = atan2(direction.x, direction.z)
        visuals.rotation.y = lerp_angle(visuals.rotation.y, target_angle, ROTATION_SPEED * delta)
    else:
        # 无输入：滑行停止
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()

# --- 智能播放函数 ---
func play_anim_smart(keyword):
    if not anim_player: return
    var list = anim_player.get_animation_list()
    for anim_name in list:
        if keyword.to_lower() in anim_name.to_lower():
            if anim_player.current_animation != anim_name:
                anim_player.play(anim_name, 0.2)
            return
