# Equipment.gd
extends Resource
class_name Equipment

enum EquipmentType {
    WEAPON,   # 武器
    ARMOR,    # 盔甲
    ACCESSORY # 饰品
}

enum EquipmentCategory {
    MELEE_WEAPON,  # 近战武器
    RANGED_WEAPON, # 远程武器
    LIGHT_ARMOR,   # 轻甲
    HEAVY_ARMOR,   # 重甲
    RING,          # 戒指
    NECKLACE,      # 项链
    BRACELET       # 手镯
}

var item_name: String = ""
var description: String = ""
var item_value: int = 0
var attribute_boosts: Dictionary = {}
var equip_conditions: Dictionary = {}
var special_skill: String = ""
var equipment_type: EquipmentType
var equipment_category: EquipmentCategory

func _init(_name: String, _description: String, _item_value: int, _attribute_boosts: Dictionary, _equip_conditions: Dictionary, _special_skill: String, _equipment_type: EquipmentType, _equipment_category: EquipmentCategory):
    item_name = _name
    description = _description
    item_value = _item_value
    attribute_boosts = _attribute_boosts
    equip_conditions = _equip_conditions
    special_skill = _special_skill
    equipment_type = _equipment_type
    equipment_category = _equipment_category

func equip(character):
    # 实现装备逻辑
    pass

func unequip(character):
    # 实现卸下装备逻辑
    pass