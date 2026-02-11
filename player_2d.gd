extends CharacterBody2D

# --- 调整手感区域 ---
const SPEED = 200.0          # 左右移动速度
const JUMP_VELOCITY = -300.0 # 跳跃力度（负数是向上）

# 获取重力设置
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- 核心开关 ---
# 默认是 false，意味着游戏刚开始时，这个 2D 小人是冻结的
var is_active = false

func _physics_process(delta):
	# 如果没有被激活，什么都不做（冻结状态）
	if not is_active:
		return

	# 1. 处理重力
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. 处理跳跃
	# "ui_accept" 默认是空格键 (Space)
	# 如果你想用 "W" 键跳跃，可以改成 Input.is_action_just_pressed("move_forward")
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. 处理左右移动 (修改了这里！)
	# 使用你刚才设置的 WASD 映射
	# "move_left" (A) 对应 -1，"move_right" (D) 对应 1
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * SPEED
		
		# (可选) 简单的翻转动画
		# 如果往左走(direction < 0)，脸朝左；往右走，脸朝右
		# 假设你的 2D 角色是用 Sprite2D 做的
		# $Sprite2D.flip_h = direction < 0 
	else:
		# 如果没按键，平滑减速到 0
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 4. 真正执行移动
	move_and_slide()
