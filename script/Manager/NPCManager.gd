# NPC管理器-自动加载脚本

extends Node

const NPC = preload("res://Script/NPC.gd")
# 所有NPC的字典，键为npc_name，值为NPC实例
var npc_list: Dictionary = {}
var gamer_money = 0

# 创建一个新的NPC
func create_npc(_npc_name: String, _race: String, _strength: int, _intelligence: int, _dexterity: int, _charisma: int, _constitution: int, _perception: int) -> NPC:
	var new_npc = NPC.new()
	new_npc.init(_npc_name, _race, _strength, _intelligence, _dexterity, _charisma, _constitution, _perception)
	npc_list[_npc_name] = new_npc
	return new_npc

# 获取NPC
func get_npc_by_name(_npc_name: String) -> NPC:
	if npc_list.has(_npc_name):
		return npc_list[_npc_name]
	return null

# 更新某个NPC的状态
func update_npc_status(_npc_name: String, _health: int, _mana: int, _stamina: int, _stress: int):
	if npc_list.has(_npc_name):
		var npc = npc_list[_npc_name]
		npc.health = _health
		npc.mana = _mana
		npc.stamina = _stamina
		npc.stress = _stress

# 删除NPC
func delete_npc(_npc_name: String):
	if npc_list.has(_npc_name):
		npc_list.erase(_npc_name)
