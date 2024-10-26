# res://Script/Manager/DataManager.gd 
# AutoLoad
extends Node

# 存储所有技能数据的字典
var all_skills_data = {}
# 存储所有NPC数据的字典
var all_npc_data = {}
# 存储所有装备数据的字典
var all_equipment_data = {}
# 存储所有队伍数据的字典
var all_team_data = {}
# 存储所有怪物数据的字典
var all_monster_data = {}   
# 存储所有怪物模板数据的字典
var all_template_monster_data = {}
# 存储所有临时怪物数据的字典
var all_temporary_monster_data = {}
# 在节点准备就绪时调用，加载所有数据
func _ready():
	load_all_data()

# 从JSON文件中加载所有数据
func load_all_data():
	print("DataManager load_all_data 加载所有数据")
	all_skills_data = load_json("res://Dataset/Skills.json")
	all_npc_data = load_json("res://Dataset/NPC/NPCData.json")
	all_equipment_data = load_json("res://Dataset/Equipment.json")
	all_team_data = load_json("res://Dataset/Teams.json")
	all_template_monster_data = load_json("res://Dataset/Monster/MonsterTemplate.json")
	all_temporary_monster_data = load_json("res://Dataset/Monster/MonsterTemporary.json")
# 从指定路径加载JSON文件并返回解析后的数据
# 参数：path - JSON文件的路径
# 返回：解析后的JSON数据，如果加载失败则返回空字典
func load_json(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		if error == OK:
			return json.data
	return {}

# 获取指定技能ID的技能数据
func get_skills_data(skill_id: String) -> Dictionary:
	return all_skills_data.get(str(skill_id), {})

# 获取指定NPC ID的NPC数据
func get_npc_data(npc_id: String) -> Dictionary:
	var npc_key = str(npc_id)
	if npc_key in all_npc_data:
		return all_npc_data[npc_key]
	else:
		return {}

# 获取指定模板怪物ID的怪物数据  
func get_template_monster_data(template_monster_id: String) -> Dictionary:
	var monster_key = str(template_monster_id)
	if monster_key in all_template_monster_data:
		return all_template_monster_data[monster_key]
	else:
		return {}

# 获取指定临时怪物ID的临时怪物数据
func get_temporary_monster_data(temporary_monster_id: String) -> Dictionary:
	var temp_monster_key = str(temporary_monster_id)
	if temp_monster_key in all_temporary_monster_data:
		return all_temporary_monster_data[temp_monster_key]
	else:
		return {}

# 获取指定角色ID的角色数据 
# 如果你不确定要寻找的角色是npc还是monster，请使用这个函数
func get_character_data(character_id: String) -> Dictionary:
	var npc_data = get_npc_data(character_id)

	if npc_data.is_empty():
		var monster_data = get_temporary_monster_data(character_id)
		if monster_data.is_empty():
			print("DataManager get_character_data 未找到角色数据: ", character_id)
		return monster_data
	else:
		return npc_data

# 生成临时怪物数据
func generate_temporary_monster_data(template_monster_id: String) -> String:
	var temp_monster_id = generate_unique_temp_monster_id(template_monster_id)
	var temporary_monster_data = get_template_monster_data(template_monster_id).duplicate()
	temporary_monster_data["id"] = temp_monster_id
	
	# 将新生成的临时怪物数据添加到all_temporary_monster_data字典中
	all_temporary_monster_data[temp_monster_id] = temporary_monster_data
	
	# 保存更新后的临时怪物数据
	save_temporary_monster_data()
	print("DataManager generate_temporary_monster_data 生成临时怪物数据: ", temp_monster_id)
	return temp_monster_id

# 生成唯一的临时ID，返回id字符串    
func generate_unique_temp_monster_id(monster_id: String) -> String:
	#从1开始，寻找一个不存在的ID
	var count = 1
	while str(monster_id) + "T" + str(count) in all_temporary_monster_data:
		count += 1
	return str(monster_id) + "T" + str(count)


# 保存临时怪物数据
func save_temporary_monster_data():
	var file = FileAccess.open("res://Dataset/Monster/MonsterTemporary.json", FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(all_temporary_monster_data, "  ", true) 
		file.store_string(json_string)
		file.close()
		#print("DataManager save_temporary_monster_data 保存临时怪物数据")
	else:
		print("DataManager save_temporary_monster_data 无法打开 MonsterTemporary.json 文件进行写入")

# 保存NPC数据到文件
func save_npc_data():
	var file = FileAccess.open("res://Dataset/NPC/NPCData.json", FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(all_npc_data, "  ", true)
		file.store_string(json_string)
		file.close()
		#print("DataManager save_npc_data 保存NPC数据")
	else:
		print("DataManager save_npc_data 无法打开 NPCData.json 文件进行写入")

# 保存怪物模板数据
func save_template_monster_data():
	var file = FileAccess.open("res://Dataset/Monster/MonsterTemplate.json", FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(all_template_monster_data, "  ", true)
		file.store_string(json_string)
		file.close()
		print("DataManager save_template_monster_data 保存怪物模板数据")
	else:
		print("DataManager save_template_monster_data 无法打开 MonsterTemplate.json 文件进行写入")


# 保存角色数据
# 参数：character_id - 角色ID，character_data - 角色数据
# 角色id开头为0的是NPC，开头为1的是怪物
func save_character_data(character_id: String, character_data: Dictionary):
	#print("DataManager save_character_data 保存角色数据: ", character_id)
	var id_prefix = character_id.substr(0, 1)
	
	if id_prefix == "0": # NPC数据
		
		print("DataManager save_character_data 保存NPC数据: ", character_id)
		all_npc_data[character_id] = character_data
		save_npc_data()

	elif id_prefix == "1": # 怪物数据
		
		print("DataManager save_character_data 保存怪物数据: ", character_id)
		all_temporary_monster_data[character_id] = character_data
		print("DataManager save_character_data 保存怪物数据: ", character_data)
		save_temporary_monster_data()
	else:
		print("DataManager save_character_data 错误：无效的角色ID ", character_id)




# 获取指定装备ID的装备数据
# 参数：equipment_id - 装备ID
# 返回：包含装备所有数据的字典，如果未找到则返回空字典
func get_equipment_data(equipment_id: String) -> Dictionary:
	return all_equipment_data.get(str(equipment_id), {})

# 获取指定队伍ID的队伍数据
# 参数：team_id - 队伍ID
# 返回：包含队伍所有数据的字典，如果未找到则返回空字典
func get_team_data(team_id: String) -> Dictionary:
	var team_key = str(team_id)  # 确保team_id是字符串
	if team_key in all_team_data:
		return all_team_data[team_key]
	else:
		print("DataManager get_team_data 未找到队伍数据: ", team_id)    
		return {}

# 获取角色特定技能的权重
# 参数：character_data - 角色数据字典，skill_id - 技能ID
# 返回：技能权重，如果未找到则返回0
func get_character_skill_weight(character_data: Dictionary, skill_id: String) -> int:
	var active_skills = character_data.get("active_skills", {})
	var skill_data = active_skills.get(skill_id, {})
	return skill_data.get("weight", 0)  # 使用 "weight" 作为优先级

# 根据NPC ID和技能ID获取技能的时机数据
# 参数：npc_id - NPC ID，skill_id - 技能ID
# 返回：技能时机数据字典，key是时机类型，value是目标类型
func get_skill_timing_by_character_id_and_skill_id(character_id: String, skill_id: String) -> Dictionary:
	var npc_data = get_character_data(character_id) 
	var skill_data = get_skills_data(skill_id)
	var timing = skill_data.get("timing", {})
	print("DataManager get_skill_timing_by_character_id_and_skill_id 技能时机: ", timing)
	return timing.get(npc_data.get("type", ""), {})

# 根据NPC ID获取其所在的队伍数据
# 参数：character_id - 角色ID
# 返回：角色所在队伍的数据字典
func get_team_by_character_id(character_id: String) -> Dictionary:
	var battle_data = BattleManager.get_current_battle_data()
	return battle_data.get(character_id, {})

# 获取指定NPC ID的主动技能数据
# 参数：npc_id - NPC ID
# 返回：角色的主动技能数据字典
func get_active_skills_data(character_id: String) -> Dictionary:
	var character_data = get_character_data(character_id)
	return character_data.get("active_skills", {})    

# 根据角色ID获取其在战场上的位置
# 参数：character_id - 角色ID
# 返回：角色在战场上的位置字符串，如果未找到则返回空字符串
func get_position_by_character_id(character_id: String) -> String:
	var battle_data: Dictionary = BattleManager.get_current_battle_data()

	# 检查冒险者队伍
	for position in battle_data.get("adventurer_team", {}).get("positions", {}):
		var data = battle_data["adventurer_team"]["positions"][position]
		if data != null and data.get("character_id") == character_id:
			return position
	
	# 检查怪物队伍
	for position in battle_data.get("monster_team", {}).get("positions", {}):
		var data = battle_data["monster_team"]["positions"][position]
		if data != null and data.get("character_id") == character_id:
			return position
	
	# 如果没有找到，返回空字符串
	return ""

# 根据数据类型和ID获取相应的数据
# 参数：data_type - 数据类型（"skills", "npc", "equipment", "team"），data_id - 数据ID
# 返回：对应类型和ID的数据字典，如果类型未知则返回空字典
func get_data(data_type: String, data_id: String) -> Dictionary:
	match data_type:
		"skills":
			return get_skills_data(data_id)
		"npc":
			return get_npc_data(data_id)
		"equipment":
			return get_equipment_data(data_id)
		"team":
			return get_team_data(data_id)
		_:
			print("未知的数据类型: ", data_type)
			return {}
