extends Resource
class_name Consumable

var item_name: String = ""
var description: String = ""
var item_value: int = 0
var effect: Dictionary = {}

func _init(_name: String, _description: String, _item_value: int, _effect: Dictionary):
    item_name = _name
    description = _description
    item_value = _item_value
    effect = _effect

func use(character):
    # 实现使用消耗品的逻辑
    pass