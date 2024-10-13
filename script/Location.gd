extends Node

class_name Location

enum LocationType {
	URBAN,    # 城内
	SUBURBAN, # 城外
	RURAL     # 野外
}

var location_name: String = ""
var type: LocationType
var npc_names: Array = []

func _init(_location_name: String, _type: LocationType):
	location_name = _location_name
	type = _type
	npc_names = []

func add_npc(_npc_name: String):
	if not npc_names.has(_npc_name):
		npc_names.append(_npc_name)

func remove_npc(_npc_name: String):
	if npc_names.has(_npc_name):
		npc_names.erase(_npc_name)

func get_all_npcs() -> Array:
	return npc_names
