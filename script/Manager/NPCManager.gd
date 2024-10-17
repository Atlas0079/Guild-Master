# Script/Manager/NPCManager.gd
extends Node

var npc_list: Dictionary = {}
var gamer_money = 0

const NPC_DATA_PATH = "res://Dataset/NPC/NPCData.json"

func _ready():
    load_npc_data()

func create_npc(_npc_name: String, _race: String, _strength: int, _intelligence: int, _dexterity: int, _charisma: int, _constitution: int, _perception: int) -> NPC:
    var new_npc = NPC.new()
    new_npc.init(_npc_name, _race, _strength, _intelligence, _dexterity, _charisma, _constitution, _perception)
    npc_list[_npc_name] = new_npc
    save_npc_data()
    return new_npc

func get_npc_by_name(_npc_name: String) -> NPC:
    return npc_list.get(_npc_name)

func update_npc_status(_npc_name: String, _health: int, _mana: int, _stamina: int, _stress: int):
    var npc = get_npc_by_name(_npc_name)
    if npc:
        npc.attributes.modify_health(_health - npc.attributes.health)
        npc.attributes.modify_mana(_mana - npc.attributes.mana)
        npc.attributes.modify_stamina(_stamina - npc.attributes.stamina)
        npc.attributes.modify_stress(_stress - npc.attributes.stress)
    save_npc_data()

func delete_npc(_npc_name: String):
    npc_list.erase(_npc_name)
    save_npc_data()

func update_all_npcs():
    for npc in npc_list.values():
        npc.traits_states.update_states()
        npc.traits_states.apply_effects(npc)
        npc.equipment.update_equipment()
    save_npc_data()

func get_all_npcs() -> Array:
    return npc_list.values()

func save_npc_data():
    var file = FileAccess.open(NPC_DATA_PATH, FileAccess.WRITE)
    if file:
        var npc_data = {}
        for npc_name in npc_list:
            var npc = npc_list[npc_name]
            npc_data[npc_name] = {
                "race": npc.attributes.race,
                "strength": npc.attributes.strength,
                "intelligence": npc.attributes.intelligence,
                "dexterity": npc.attributes.dexterity,
                "charisma": npc.attributes.charisma,
                "constitution": npc.attributes.constitution,
                "perception": npc.attributes.perception,
                "health": npc.attributes.health,
                "mana": npc.attributes.mana,
                "stamina": npc.attributes.stamina,
                "stress": npc.attributes.stress,
                "skills": npc.attributes.skills  # 新增：保存技能数据
            }
        file.store_string(JSON.stringify(npc_data))
        file.close()
    else:
        print("无法打开文件进行写入：", NPC_DATA_PATH)

func load_npc_data():
    if FileAccess.file_exists(NPC_DATA_PATH):
        var file = FileAccess.open(NPC_DATA_PATH, FileAccess.READ)
        if file:
            var json_string = file.get_as_text()
            file.close()
            var json = JSON.new()
            var error = json.parse(json_string)
            if error == OK:
                var npc_data = json.data
                for npc_name in npc_data:
                    var data = npc_data[npc_name]
                    var new_npc = create_npc(npc_name, data["race"], data["strength"], data["intelligence"], 
                               data["dexterity"], data["charisma"], data["constitution"], data["perception"])
                    update_npc_status(npc_name, data["health"], data["mana"], data["stamina"], data["stress"])
                    
                    # 新增：加载技能数据
                    if "skills" in data:
                        for weight in data["skills"]:
                            new_npc.attributes.add_skill(int(weight), data["skills"][weight])
            else:
                print("解析JSON时出错: ", NPC_DATA_PATH)
    else:
        print("NPC数据文件不存在: ", NPC_DATA_PATH)

# 新增：为NPC添加技能的方法
func add_skill_to_npc(_npc_name: String, weight: int, skill_id: int):
    var npc = get_npc_by_name(_npc_name)
    if npc:
        npc.attributes.add_skill(weight, skill_id)
        save_npc_data()

# 新增：从NPC移除技能的方法
func remove_skill_from_npc(_npc_name: String, weight: int):
    var npc = get_npc_by_name(_npc_name)
    if npc:
        npc.attributes.remove_skill(weight)
        save_npc_data()

# 新增：获取NPC的所有技能
func get_npc_skills(_npc_name: String) -> Dictionary:
    var npc = get_npc_by_name(_npc_name)
    if npc:
        return npc.attributes.get_skills()
    return {}