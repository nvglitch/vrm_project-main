extends MeshInstance3D 

# 获取必要的节点引用 (请根据你的实际节点路径修改！)
@onready var player_3d = get_node("../Player3D") 
@onready var player_2d_root = get_node("../2D_Game_Engine/Level_2D/Player2D") 
@onready var wall_camera = get_node("WallCamera") # 假设你在墙前放了个摄像机

func _ready():
	# 确保连接了信号
	$TriggerZone.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# 确认撞进来的是 3D 玩家
	if body == player_3d:
		switch_to_2d_mode()

func switch_to_2d_mode():
	# 1. 【冻结 3D 肉身】
	# PROCESS_MODE_DISABLED 会彻底停止这个节点的 _process 和 _physics_process
	player_3d.process_mode = Node.PROCESS_MODE_DISABLED 
	player_3d.visible = false # 隐身
	
	# 2. 【激活 2D 灵魂】
	# 记得我们之前在 Player2D 脚本里写的 var is_active 吗？
	player_2d_root.is_active = true
	
	# 3. 【切换视角】
	# 让摄像机从 3D 人身上切到墙壁前面的固定机位
	wall_camera.current = true
