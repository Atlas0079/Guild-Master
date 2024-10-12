# script/NPC/NPCEquipment.gd
extends Node

class_name NPCEquipment

var weapon: Equipment = null
var armor: Equipment = null
var accessories: Array = []

var npc: NPC

func init(_npc: NPC):
    npc = _npc

func equip_weapon(new_weapon: Equipment):
    if meets_conditions(new_weapon.conditions):
        weapon = new_weapon
        apply_equipment_effects()

func equip_armor(new_armor: Equipment):
    if meets_conditions(new_armor.conditions):
        armor = new_armor
        apply_equipment_effects()

func add_accessory(new_accessory: Equipment):
    if meets_conditions(new_accessory.conditions) and accessories.size() < 3:
        accessories.append(new_accessory)
        apply_equipment_effects()

func remove_weapon():
    weapon = null
    apply_equipment_effects()

func remove_armor():
    armor = null
    apply_equipment_effects()

func remove_accessory(accessory: Equipment):
    var index = accessories.find(accessory)
    if index != -1:
        accessories.remove_at(index)  # 使用 remove_at() 替代 remove()
        apply_equipment_effects()

func update_equipment():
    apply_equipment_effects()

func meets_conditions(conditions: Dictionary) -> bool:
    for condition in conditions:
        if not npc.attributes.get(condition) >= conditions[condition]:
            return false
    return true

func apply_equipment_effects():
    # 重置属性
    npc.attributes.update_derived_stats()
    
    # 应用武器效果
    if weapon:
        apply_item_effects(weapon)
    
    # 应用护甲效果
    if armor:
        apply_item_effects(armor)
    
    # 应用饰品效果
    for accessory in accessories:
        apply_item_effects(accessory)

func apply_item_effects(item: Equipment):
    for effect in item.effects:
        var attribute = effect.attribute
        var value = effect.value
        npc.attributes.set(attribute, npc.attributes.get(attribute) + value)