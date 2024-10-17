extends Node

enum Camp {ADVENTURER, MONSTER}
enum Position {FRONT_TOP, FRONT_MIDDLE, FRONT_BOTTOM, BACK_TOP, BACK_MIDDLE, BACK_BOTTOM}

class Battlefield:
	var id: String
	var battlefield: Dictionary
	
	func _init(_id: String):
		self.id = _id
		self.battlefield = {
			Camp.ADVENTURER: {},
			Camp.MONSTER: {}
		}
		for position in Position.values():
			self.battlefield[Camp.ADVENTURER][position] = null
			self.battlefield[Camp.MONSTER][position] = null
	
	func clear_battlefield():
		for camp in battlefield.keys():
			for position in battlefield[camp].keys():
				battlefield[camp][position] = null
	
	func place_team(team: Dictionary, camp: Camp):
		for member in team.positions.keys():
			var position = string_to_position(team.positions[member])
			if position != null:
				battlefield[camp][position] = member
	
	func string_to_position(pos_string: String) -> int:
		match pos_string:
			"FRONT_TOP": return Position.FRONT_TOP
			"FRONT_MIDDLE": return Position.FRONT_MIDDLE
			"FRONT_BOTTOM": return Position.FRONT_BOTTOM
			"BACK_TOP": return Position.BACK_TOP
			"BACK_MIDDLE": return Position.BACK_MIDDLE
			"BACK_BOTTOM": return Position.BACK_BOTTOM
		return -1
	
	func display_battlefield():
		print("战场 %s 状态:" % id)
		for camp in battlefield.keys():
			var camp_name = "冒险者" if camp == Camp.ADVENTURER else "怪物"
			print("  %s阵营:" % camp_name)
			for position in battlefield[camp].keys():
				var character = battlefield[camp][position]
				var pos_name = Position.keys()[position]
				print("    %s: %s" % [pos_name, character if character else "空"])
		print("------------------------")

var battlefields = {}

func create_battlefield(battlefield_id: String) -> Battlefield:
	var new_battlefield = Battlefield.new(battlefield_id)
	battlefields[battlefield_id] = new_battlefield
	return new_battlefield

func get_battlefield(battlefield_id: String) -> Battlefield:
	return battlefields.get(battlefield_id)

func initialize_battle(battlefield_id: String, adventurer_team_id: String, monster_team_id: String):
	var battlefield = get_battlefield(battlefield_id)
	if not battlefield:
		battlefield = create_battlefield(battlefield_id)
	
	battlefield.clear_battlefield()
	
	var adventurer_team = TeamManager.get_team(adventurer_team_id, false)
	var monster_team = TeamManager.get_team(monster_team_id, true)
	
	battlefield.place_team(adventurer_team, Camp.ADVENTURER)
	battlefield.place_team(monster_team, Camp.MONSTER)
	
	battlefield.display_battlefield()

func start_battle(battlefield_id: String, adventurer_team_id: String, monster_team_id: String):
	initialize_battle(battlefield_id, adventurer_team_id, monster_team_id)
	# 这里可以添加更多战斗逻辑
	pass

func remove_battlefield(battlefield_id: String):
	battlefields.erase(battlefield_id)

func get_all_battlefield_ids() -> Array:
	return battlefields.keys()

func get_battlefield_count() -> int:
	return battlefields.size()


