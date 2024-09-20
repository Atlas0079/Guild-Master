extends Resource

# 通用装备类
class_name Equipment

# 装备属性
var name: String = ""
var attribute_boosts: Dictionary = {}  # 例如 {"strength": 5, "health": 10}
var equip_conditions: Dictionary = {}  # 例如 {"strength": 10} 表示需要10点力量才能装备
var price: int = 0
var special_skill: String = ""  # 额外技能

# 初始化
func _init(_name: String, _attribute_boosts: Dictionary, _equip_conditions: Dictionary, _price: int, _special_skill: String):
	name = _name
	attribute_boosts = _attribute_boosts
	equip_conditions = _equip_conditions
	price = _price
	special_skill = _special_skill
