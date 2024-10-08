# Consumable.gd
extends Item
class_name Consumable

var effect: Dictionary = {}

func _init(_name: String, _description: String, _item_value: int, _effect: Dictionary):
	super(_name, _description, _item_value, ItemType.CONSUMABLE)
	effect = _effect

func use(character):
	# 实现使用消耗品的逻辑
	pass
