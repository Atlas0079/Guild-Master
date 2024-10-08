# MiscItem.gd
extends Item
class_name MiscItem

func _init(_name: String, _description: String, _item_value: int):
    super(_name, _description, _item_value, ItemType.MISC)

func use(character):
    # 杂物通常不能直接使用，可以实现一些特殊逻辑或者返回提示信息
    print("这个物品不能直接使用。")