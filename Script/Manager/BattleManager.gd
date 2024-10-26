# res://Script/Manager/BattleManager.gd
# 战斗管理器，负责处理战斗相关的逻辑

extends Node

# 存储当前战斗的数据
var current_battle_data = {}

# 定义最大回合数
const MAX_TURNS = 10

# 创建新的战斗
# 参数：adventurer_team_id - 冒险者队伍ID，monster_team_id - 怪物队伍ID
# 返回：创建成功返回true
func create_new_battle(adventurer_team_id, monster_team_id):
	# 获取冒险者队伍和怪物队伍的数据
	var adventurer_team = DataManager.get_team_data(adventurer_team_id)
	var monster_team = DataManager.get_team_data(monster_team_id)
	
	# 创建战场数据结构
	var battlefield_adventurer_team = {
		"team_id": str(adventurer_team_id),
		"describe": adventurer_team["describe"],
		"positions": {}
	}
	
	var battlefield_monster_team = {
		"team_id": str(monster_team_id),
		"describe": monster_team["describe"],
		"positions": {}
	}
	
	# 转换冒险者队伍数据
	for position in adventurer_team["positions"]:
		var character_id = adventurer_team["positions"][position]
		if character_id != null:
			battlefield_adventurer_team["positions"][position] = {
				"character_id": character_id,
				"is_down": false
			}
		else:
			battlefield_adventurer_team["positions"][position] = null
	
	# 转换怪物队伍数据并生成临时怪物
	for position in monster_team["positions"]:
		var monster_id = monster_team["positions"][position]
		if monster_id != null:
			var temp_id = DataManager.generate_temporary_monster_data(monster_id)
			battlefield_monster_team["positions"][position] = {
				"character_id": temp_id,
				"is_down": false
			}
		else:
			battlefield_monster_team["positions"][position] = null
	
	# 初始化当前战斗数据
	current_battle_data = {
		"adventurer_team": battlefield_adventurer_team,
		"monster_team": battlefield_monster_team,
		"turn": 1,  # 初始回合数为1
		"active_character": null  # 当前活动角色，初始为null
	}
	
	print("BattleManager create_new_battle 当前战斗数据: \n", current_battle_data)
	# 保存战斗数据
	save_battle_data()
	return true


# 保存当前战斗数据
func save_battle_data():
	var file = FileAccess.open("res://Dataset/Battles/current_battle.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(current_battle_data))
		file.close()

# 加载战斗数据
# 返回：加载成功返回true，失败返回false
func load_battle_data():
	var file = FileAccess.open("res://Dataset/Battles/current_battle.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		if error == OK:
			current_battle_data = json.data
			return true
	return false

# 获取当前战斗数据
# 返回：当前战斗数据
func get_current_battle_data():
	return current_battle_data

# 处理战斗回合
func process_battle_turn():
	# 增加所有角色的行动点数
	increase_action_points()
	# 获取可行动的角色列表
	var actionable_characters = get_actionable_characters()
	# 根据行动阈值对角色进行排序
	actionable_characters.sort_custom(Callable(self, "compare_action_threshold"))
	
	# 处理每个可行动角色的行动
	for character_id in actionable_characters:
		process_character_action(character_id)
	
	next_turn()

# 增加所有角色的行动点数
func increase_action_points():
	#print("BattleManager increase_action_points 增加行动点数")
	
	for team in [current_battle_data["adventurer_team"], current_battle_data["monster_team"]]:
		for position in team["positions"]:
			var character_data = team["positions"][position]
			if character_data != null:
				var character_id = character_data["character_id"]

				var char_data = DataManager.get_character_data(character_id)
				if char_data != null:
					char_data["action_point"] += 1
					DataManager.save_character_data(character_id, char_data)
				else:
					print("BattleManager increase_action_points 警告：未找到角色数据，ID：", character_id)
			# 如果position为null，则跳过不处理

# 获取可行动的角色列表
# 返回：可行动角色ID列表
func get_actionable_characters():
	var actionable = []
	for team in [current_battle_data["adventurer_team"], current_battle_data["monster_team"]]:
		for position in team["positions"]:
			var character_data = team["positions"][position]
			if character_data != null:
				var character_id = character_data["character_id"]
				var char_data = DataManager.get_character_data(character_id)
				if char_data != null and "action_point" in char_data and "action_threshold" in char_data:
					if char_data["action_point"] >= char_data["action_threshold"]:
						actionable.append(character_id)
						#print("BattleManager get_actionable_characters 可行动角色ID：", character_id)
				else:
					print("BattleManager get_actionable_characters 警告：未找到角色数据或数据不完整，ID：", character_id)
			# 如果position为null，则跳过不处理
	return actionable

# 比较两个角色的行动阈值
# 参数：a, b - 要比较的两个角色ID
# 返回：如果a的行动阈值小于b，返回true；否则返回false
func compare_action_threshold(a, b):
	var a_data = DataManager.get_character_data(a)
	var b_data = DataManager.get_character_data(b)
	if a_data["action_threshold"] < b_data["action_threshold"]:
		return true
	elif a_data["action_threshold"] > b_data["action_threshold"]:
		return false
	else:
		return randf() > 0.5  # 如果行动阈值相同，随机决定顺序

# 处理角色的行动
# 参数：npc_id - 要处理行动的角色ID
func process_character_action(character_id):
	# 获取可用的技能
	print("BattleManager process_character_action 开始行动： ", character_id)
	var available_skill = SkillManager.get_available_skill(character_id)
	print("BattleManager process_character_action 可用的技能: ", available_skill)
	
	if available_skill != null:
		# 如果有可用技能，选择目标并使用技能
		var targets = SkillManager.select_target(character_id, available_skill)
		SkillManager.use_skill(character_id, available_skill, targets)	
		
		# 重置角色的行动点数
		var character_data = DataManager.get_character_data(character_id)
		character_data["action_point"] = 0
		DataManager.save_character_data(character_id, character_data)	
		print("BattleManager process_character_action 重置角色行动点数: ", character_id)
	else:
		# 如果没有可用技能，保留行动点数但不超过行动阈值
		var character_data = DataManager.get_character_data(character_id)
		character_data["action_point"] = min(character_data["action_point"], character_data["action_threshold"])
		DataManager.save_character_data(character_id, character_data)
		print("BattleManager process_character_action 保留行动点数但不超过行动阈值: ", character_id)
# 进入下一回合
func next_turn():
	current_battle_data["turn"] += 1
	current_battle_data["active_character"] = null
	print("BattleManager next_turn 当前回合数: ", current_battle_data["turn"])
	save_battle_data()

# 获取角色在战场上的位置
# 参数：character_id - 角色ID
# 返回：角色的位置，如果未找到则返回null
func get_character_position(character_id):
	for team in [current_battle_data["adventurer_team"], current_battle_data["monster_team"]]:
		var positions = team.get("positions", {})
		for position in positions:
			if positions[position].get("character_id") == character_id:
				return position
	return null



# 检查战斗是否结束
# 返回：如果战斗结束返回true，否则返回false
func is_battle_over():
	# 检查回合数是否达到最大值
	if current_battle_data["turn"] >= MAX_TURNS:
		return true
	
	# 检查冒险者队伍是否全部失去战斗能力
	var adventurer_all_down = is_team_all_down("adventurer_team")
	
	# 检查怪物队伍是否全部失去战斗能力
	var monster_all_down = is_team_all_down("monster_team")
	
	# 如果任一队伍全部失去战斗能力，战斗结束
	return adventurer_all_down or monster_all_down

# 检查一个队伍是否所有角色都失去战斗能力
# 参数：team_type - 要检查的队伍类型 
# 只能是"adventurer_team"或"monster_team"
# 返回：如果所有角色都失去战斗能力返回true，否则返回false
func is_team_all_down(team_type: String):
	var team_data = null
	if team_type == "adventurer_team" or team_type == "monster_team":
		team_data = current_battle_data[team_type]
	else:
		print("BattleManager is_team_all_down 错误：未知的队伍类型 ", team_type)
		return false
	
	if team_data == null:
		print("BattleManager is_team_all_down 错误：未找到队伍类型为 ", team_type, " 的队伍数据")
		return false
	
	var active_characters = 0
	for position in team_data["positions"]:
		var character_data = team_data["positions"][position]
		if character_data != null and not character_data.get("is_down", false):
			active_characters += 1
	
	# 如果没有活跃的角色，返回true
	return active_characters == 0

# 结束战斗
func end_battle():
	# TODO: 实现战斗结束的处理逻辑
	# 清理当前战斗数据
	current_battle_data = {}

# 开始战斗
func start_battle():
	print("BattleManager start_battle 战斗开始")
	while not is_battle_over():
		process_battle_turn()


# 初始化并开始战斗
# 参数：team1_id - 第一支队伍的ID，team2_id - 第二支队伍的ID
func initialize_and_start_battle(team1_id, team2_id):
	# 创建新的战斗
	if create_new_battle(team1_id, team2_id):
		print("BattleManager initialize_and_start_battle 战斗初始化成功")
		# 开始战斗
		start_battle()
		# 获取并打印战斗结果
		var result = get_battle_result()
		end_battle()
		print("BattleManager initialize_and_start_battle 战斗结果:", result)
	else:
		print("BattleManager initialize_and_start_battle 战斗初始化失败")


func get_battle_result():
	var adventurer_all_down = is_team_all_down("adventurer_team")
	var monster_all_down = is_team_all_down("monster_team")
	
	var result = {
		"winner": "平局",
		"loser": "平局",
		"turns": current_battle_data["turn"]
	}
	
	if adventurer_all_down and not monster_all_down:
		result["winner"] = "怪物队伍"
		result["loser"] = "冒险者队伍"
	elif monster_all_down and not adventurer_all_down:
		result["winner"] = "冒险者队伍"
		result["loser"] = "怪物队伍"
	
	# TODO: 添加更多结果信息，如奖励等
	
	return result
