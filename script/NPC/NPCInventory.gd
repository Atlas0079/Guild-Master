# script/NPC/NPCInventory.gd
extends Node

class_name NPCInventory

var inventory: Array = []
var default_inventory_size: int = 10
var inventory_capacity: int = default_inventory_size

func init():
    inventory.clear()

func add_to_inventory(item):
    if inventory.size() < inventory_capacity:
        inventory.append(item)
        return true
    return false

func remove_from_inventory(item):
    var index = inventory.find(item)
    if index != -1:
        inventory.remove_at(index)  # 使用 remove_at() 替代 remove()
        return true
    return false

func update_inventory_capacity(new_capacity: int):
    inventory_capacity = new_capacity

func check_special_equipment_effects(equipment):
    for item in inventory:
        if item.has_method("apply_special_effect"):
            item.apply_special_effect(equipment)

func get_item_count() -> int:
    return inventory.size()

func is_inventory_full() -> bool:
    return inventory.size() >= inventory_capacity