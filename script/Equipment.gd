# Equipment.gd
extends Item
class_name Equipment

enum EquipmentType {
	WEAPON,
	ARMOR,
	ACCESSORY
}

enum EquipmentCategory {
	MELEE_WEAPON,
	RANGED_WEAPON,
	LIGHT_ARMOR,
	HEAVY_ARMOR,
	RING,
	NECKLACE,
	BRACELET
}

var attribute_boosts: Dictionary = {}
var equip_conditions: Dictionary = {}
var special_skill: String = ""
var equipment_type: EquipmentType
var equipment_category: EquipmentCategory

func _init(_name: String, _description: String, _item_value: int, _attribute_boosts: Dictionary, _equip_conditions: Dictionary, _special_skill: String, _equipment_type: EquipmentType, _equipment_category: EquipmentCategory):
	super(_name, _description, _item_value, ItemType.EQUIPMENT)
	attribute_boosts = _attribute_boosts
	equip_conditions = _equip_conditions
	special_skill = _special_skill
	equipment_type = _equipment_type
	equipment_category = _equipment_category

func use(character):
	equip(character)

func equip(character):
	# 实现装备逻辑
	pass

func unequip(character):
	# 实现卸下装备逻辑
	pass
