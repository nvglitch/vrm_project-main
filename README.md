# Godot VRM动画导入教程

本教程详细指导如何在Godot 4中使用Mixamo动画，并将其应用于VRM角色模型。按照以下步骤操作，可以解决常见的动画导入问题。

## 第一步：去进货（免费获取动画）
最简单的方法是去 Mixamo （Adobe 的免费动画库）。

**访问 Mixamo**：去 [mixamo.com](https://www.mixamo.com) 登录。

**选角色**：随便选一个默认的 Y Bot 角色即可（因为我们只需要它的动作数据）。

**找动作**：
- 搜索 "Idle" (待机)：找一个你喜欢的站立姿势。
- 搜索 "Run" 或 "Walk" (跑/走)：关键点 ——在右边参数栏里勾选 **In Place (原地)** ！一定要勾选，否则你的角色会跑出屏幕。

**下载 (Download)**：
- Format: **FBX Binary (.fbx)**
- Skin: **Without Skin** (为了省体积，我们只要骨骼数据) 或者 **With Skin** (有些时候为了在 Godot 里预览方便，带皮下载也行，推荐带皮 With Skin，Godot 识别更准)。
- 下载下来，分别命名为 `idle.fbx` 和 `run.fbx`。

## 第二步：Godot 4 骨骼重定向（最关键！）
把 `idle.fbx` 和 `run.fbx` 拖进你的 Godot 项目文件夹。这时候你不能直接用，因为 Mixamo 的骨头名字和 VRM 的骨头名字可能对不上。Godot 4 有个神器叫 **BoneMap**。

**双击打开导入设置**：在 Godot 的 **文件系统 (FileSystem)** 面板里，双击 `run.fbx`。这会打开一个大窗口（高级导入设置）。

**设置骨骼映射**：
1. 左边选中 **Skeleton3D** (或者叫 RootNode 下的那个骨架图标)。
2. 右边属性栏，找到 **Retarget (重定向)** -> **Bone Map**。
3. 点击 **\<empty\>** -> **New BoneMap**。
4. 点击刚新建的 BoneMap 展开它。
5. 找到 **Profile (配置)** -> 点击 **\<empty\>** -> 选择 **New SkeletonProfileHumanoid**。
6. 此时奇迹发生：Godot 会自动把 Mixamo 的 Hips, Spine, Leg 等骨头匹配到标准人形骨架上。

**提取动画**：
1. 在这个窗口上方，切换到 **Animation (动画)** 标签页。
2. 在列表里你应该能看到 `mixamo.com` 或者叫 `default` 的动画。
3. 把它的名字改简单点，比如叫 `run`。
4. 勾选 **Loop Mode (循环模式)**：设为 **Linear** (因为跑步是循环的)。
5. **最重要的一步**：点击右下角的 **Reimport (重新导入)**。

(对 `idle.fbx` 重复同样的步骤，记得也设为 Loop)

## 第三步：直接把 FBX 导入为“动画库” (最推荐)
Godot 4 允许你在导入阶段就告诉引擎：“这文件别把它当场景，把它当成一包动作数据。”

**选中文件**：在 Godot 的 **文件系统 (FileSystem)** 面板里，单击选中你的动画文件（比如 `run.fbx`）。

**打开导入面板**：此时看屏幕左上角的 **Import (导入)** 标签页（在 Scene 标签页旁边）。

**更改导入类型**：
1. 找到最上面的 **Import As (导入为)** 选项。
2. 默认是 **Scene**，请把它改成 **Animation Library**。

**重新导入**：点击底部的 **Reimport (重新导入)** 按钮。

Godot 会重新处理这个文件，现在它在引擎眼里已经不是一个 3D 模型了，而是一个存着动作的 `.res` 资源。

**加载**：
1. 回到你的 VRM 角色。
2. 选中 **AnimationPlayer** -> **Manage Animations** -> **Load Library**。
3. 现在选择那个 `run.fbx`，应该就能完美加载了，而且不会报错。

这完全正常！这正是 Godot 处理 VRM 模型的机制导致的。

## 🕵️‍♂️ 真相大白
你用的那个 **AnimationPlayer**（藏在 **VRM_Visuals** 里的那个）是 V-Sekai 插件自动生成的。

**它的任务**是：只管表情 (BlendShapes)。

**它的性格**是：“霸道”。每次你重新加载场景或运行游戏，插件都会重置它，把你手动塞进去的 Run / Idle 踢出去。

所以，你之前的努力都被它“回滚”了。

## 🏆 终极解决方案：分家！(双播放器战术)
不要试图跟插件抢那个播放器。我们需要新建一个专门管身体动作的播放器。
这就好比：原来的播放器管“面部表情”，新建的播放器管“肢体动作”。

请严格按照以下步骤操作，绝对能成：

### 第一步：创建“身体播放器”
1. 选中你的 **Player3D** 根节点。
2. 点击 **+** (添加子节点)，搜索 **AnimationPlayer**。
3. 重命名：把它改名为 **BodyPlayer**（这样就不会和原来的搞混了）。

### 第二步：加载 Mixamo 动画
1. 选中这个新的 **BodyPlayer**。
2. 在底部的 **Animation** 面板 -> **Manage Animations** (文件夹图标) -> **Load Library**。
3. 选择你那个改过名字（或者没改名）的 `run.fbx` 或 `idle.fbx`（前提是你已经按之前的教程，把它们在导入设置里改成 **"Animation Library"** 了）。
4. 如果你之前没弄好导入设置，就选 **"New Library"** 然后手动把动画 `.res` 文件加进去。

### 第三步：关键设置 (这一步不做还是动不了！)
Mixamo 的动画是针对骨骼的，所以这个播放器必须知道骨骼在哪。

1. 选中 **BodyPlayer**。
2. 看右侧 **检查器 (Inspector)** 的 **Root Node (根节点)** 属性。
3. 点击 **Assign (指定)**。
4. 在弹出的树里，选中包含骨骼的那个节点。
5. 对于 V-Sekai VRM，通常是选中 **VRM_Visuals** 或者它下面的 **Skeleton3D**。

**秘诀**：一般选 **VRM_Visuals** 是最稳的。如果动不了，回来改成选 **Skeleton3D** 试试。

---

祝你在Godot中使用VRM角色和Mixamo动画愉快！