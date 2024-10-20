# 队伍管理器-自动加载脚本

extends Node


const ADVENTURER_SAVE_PATH = "res://Dataset/adventurer_teams.json"
const MONSTER_SAVE_PATH = "res://Dataset/monster_teams.json"

var adventurer_teams = {}
var monster_teams = {}

func _ready():
	load_teams()

# 创建新队伍
func create_team(team_name: String, team_id: String, members: Array, positions: Dictionary, is_monster: bool = false) -> Dictionary:
	var new_team = {
		"name": team_name,
		"id": team_id,
		"members": members,
		"positions": positions
	}
	if is_monster:
		monster_teams[team_id] = new_team
	else:
		adventurer_teams[team_id] = new_team
	save_teams()
	print_team_info(new_team, is_monster)
	return new_team

# 获取队伍
func get_team(team_id: String, is_monster: bool = false) -> Dictionary:
	if is_monster:
		return monster_teams.get(team_id, {})
	else:
		return adventurer_teams.get(team_id, {})

# 更新队伍
func update_team(team_id: String, new_data: Dictionary, is_monster: bool = false):
	var teams = monster_teams if is_monster else adventurer_teams
	if team_id in teams:
		teams[team_id].merge(new_data)
		save_teams()

# 删除队伍
func delete_team(team_id: String, is_monster: bool = false):
	var teams = monster_teams if is_monster else adventurer_teams
	if team_id in teams:
		teams.erase(team_id)
		save_teams()

# 添加成员到队伍
func add_member_to_team(team_id: String, member_name: String, position: String, is_monster: bool = false):
	var teams = monster_teams if is_monster else adventurer_teams
	if team_id in teams:
		teams[team_id]["members"].append(member_name)
		teams[team_id]["positions"][member_name] = position
		save_teams()

# 从队伍移除成员
func remove_member_from_team(team_id: String, member_name: String, is_monster: bool = false):
	var teams = monster_teams if is_monster else adventurer_teams
	if team_id in teams:
		teams[team_id]["members"].erase(member_name)
		teams[team_id]["positions"].erase(member_name)
		save_teams()

# 保存队伍信息到 JSON 文件
func save_teams():
	save_to_json(ADVENTURER_SAVE_PATH, adventurer_teams)
	save_to_json(MONSTER_SAVE_PATH, monster_teams)

# 从 JSON 文件加载队伍信息
func load_teams():
	adventurer_teams = load_from_json(ADVENTURER_SAVE_PATH)
	monster_teams = load_from_json(MONSTER_SAVE_PATH)

# 辅助函数：保存到 JSON
func save_to_json(path: String, data: Dictionary):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
	else:
		print("无法打开文件进行写入：", path)

# 辅助函数：从 JSON 加载
func load_from_json(path: String) -> Dictionary:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			var json = JSON.new()
			var error = json.parse(json_string)
			if error == OK:
				return json.data
			else:
				print("解析JSON时出错: ", path)
	else:
		print("文件不存在: ", path)
	return {}

func print_team_info(team: Dictionary, is_monster: bool):
	var team_type = "怪物"
	if not is_monster:
		team_type = "冒险者"
	
	print("新建%s队伍信息：" % team_type)
	print("  队伍名称: %s" % team["name"])
	print("  队伍ID: %s" % team["id"])
	print("  队伍成员: %s" % str(team.members))
	print("  成员位置:")
	for member in team.positions:
		print("    %s: %s" % [member, team.positions[member]])
	print("------------------------")
