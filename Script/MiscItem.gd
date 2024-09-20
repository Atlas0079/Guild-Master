extends Resource
class_name Misc

var item_name: String = ""
var description: String = ""
var item_value: int = 0

func _init(_name: String, _description: String, _item_value: int):
    item_name = _name
    description = _description
    item_value = _item_value

func examine():
    # 实现查看杂物详情的逻辑
    return description