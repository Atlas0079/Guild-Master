extends Node
const Equipment = preload("res://Script/Equipment.gd")
const Consumable = preload("res://Script/Consumable.gd")
const Misc = preload("res://Script/Misc.gd")

# 属性
var npc_name: String
var strength: int = 10
var intelligence: int = 10
var dexterity: int = 10
var charisma: int = 10
var constitution: int = 10
var perception: int = 10

# 状态
var health: int = 100
var mana: int = 50
var stamina: int = 50
var stress: int = 0

# 装备 (武器，护甲，饰品)
var weapon: Equipment = null
var armor: Equipment = null
var accessories: Array = []

# 财产
var wealth: int = 0

# 关系 (用字典来表示与其他NPC的关系)
var relationships: Dictionary = {}

# 种族
var race: String = "Human"

# 记忆 (初步设置为空列表，可以记录互动信息)
var memory: Array = []

# 自定义初始化函数
func init(_npc_name: String, _race: String, _strength: int, _intelligence: int, _dexterity: int, _charisma: int, _constitution: int, _perception: int):
    npc_name = _npc_name
    race = _race
    strength = _strength
    intelligence = _intelligence
    dexterity = _dexterity
    charisma = _charisma
    constitution = _constitution
    perception = _perception

# 添加记忆
func add_memory(interaction: String, time: String, emotion: String):
    var memory_entry = {
        "interaction": interaction,
        "time": time,
        "emotion": emotion
    }
    memory.append(memory_entry)

# 装备武器
func equip_weapon(new_weapon: Equipment):
    if meets_conditions(new_weapon.equip_conditions):
        weapon = new_weapon
    else:
        print("装备条件不满足")

# 装备护甲
func equip_armor(new_armor: Equipment):
    if meets_conditions(new_armor.equip_conditions):
        armor = new_armor
    else:
        print("装备条件不满足")

# 添加饰品
func add_accessory(new_accessory: Equipment):
    if accessories.size() >= 3:
        print("不能装备超过3个饰品")
    elif accessories.has(new_accessory):
        print("饰品不能重复")
    elif meets_conditions(new_accessory.equip_conditions):
        accessories.append(new_accessory)
    else:
        print("装备条件不满足")

# 检查是否满足装备条件
func meets_conditions(conditions: Dictionary) -> bool:
    for attr in conditions.keys():
        if self.get(attr) < conditions[attr]:
            return false
    return true

# 卸下装备
func remove_weapon():
    weapon = null

func remove_armor():
    armor = null

func remove_accessory(accessory: Equipment):
    accessories.erase(accessory)
