# Item.gd
extends Resource
class_name Item

enum ItemType {
	EQUIPMENT,
	CONSUMABLE,
	MISC
}

var item_name: String = ""
var description: String = ""
var item_value: int = 0
var item_type: ItemType

func _init(_name: String, _description: String, _item_value: int, _item_type: ItemType):
	item_name = _name
	description = _description
	item_value = _item_value
	item_type = _item_type

func use(character):
	# 将在子类中实现
	pass

func examine():
	return description
