# NPC管理器-自动加载脚本

extends Node

# 所有NPC的字典，键为npc_name，值为NPC实例
var npc_list: Dictionary = {}
var gamer_money = 0

# 创建一个新的NPC
func create_npc(_npc_name: String, _race: String, _strength: int, _intelligence: int, _dexterity: int, _charisma: int, _constitution: int, _perception: int) -> NPC:
    var new_npc = NPC.new()
    new_npc.init(_npc_name, _race, _strength, _intelligence, _dexterity, _charisma, _constitution, _perception)
    npc_list[_npc_name] = new_npc
    return new_npc

# 获取NPC
func get_npc_by_name(_npc_name: String) -> NPC:
    return npc_list.get(_npc_name)

# 更新某个NPC的状态
func update_npc_status(_npc_name: String, _health: int, _mana: int, _stamina: int, _stress: int):
    var npc = get_npc_by_name(_npc_name)
    if npc:
        npc.attributes.modify_health(_health - npc.attributes.health)
        npc.attributes.modify_mana(_mana - npc.attributes.mana)
        npc.attributes.modify_stamina(_stamina - npc.attributes.stamina)
        npc.attributes.modify_stress(_stress - npc.attributes.stress)

# 删除NPC
func delete_npc(_npc_name: String):
    npc_list.erase(_npc_name)

# 更新所有NPC
func update_all_npcs():
    for npc in npc_list.values():
        npc.traits_states.update_states()
        npc.traits_states.apply_effects(npc)
        npc.equipment.update_equipment()

# 获取所有NPC
func get_all_npcs() -> Array:
    return npc_list.values()