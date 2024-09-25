extends Node
const Equipment = preload("res://Script/Equipment.gd")
const Consumable = preload("res://Script/Consumable.gd")
const MiscItem = preload("res://Script/MiscItem.gd")  

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
# 背包系统
var inventory: Array = []
var default_inventory_size: int = 10
var inventory_capacity: int = default_inventory_size  # 默认背包容量

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

# 初始化背包
func init_inventory():
    inventory.clear()
    inventory.resize(inventory_capacity)

# 添加物品到背包
func add_to_inventory(item):
    var empty_slot = inventory.find(null)
    if empty_slot != -1:
        inventory[empty_slot] = item
        return true
    else:
        print("背包已满")
        return false

# 从背包移除物品
func remove_from_inventory(item):
    var item_index = inventory.find(item)
    if item_index != -1:
        inventory[item_index] = null
        return true
    else:
        print("物品不在背包中")
        return false

# 装备武器
func equip_weapon(new_weapon: Equipment):
    if meets_conditions(new_weapon.equip_conditions):
        if weapon:
            add_to_inventory(weapon)
        weapon = new_weapon
        remove_from_inventory(new_weapon)
        print("装备了武器：", new_weapon.item_name)
    else:
        print("装备条件不满足")

# 装备护甲
func equip_armor(new_armor: Equipment):
    if meets_conditions(new_armor.equip_conditions):
        if armor:
            add_to_inventory(armor)
        armor = new_armor
        remove_from_inventory(new_armor)
        print("装备了护甲：", new_armor.item_name)
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
        remove_from_inventory(new_accessory)
        print("装备了饰品：", new_accessory.item_name)
    else:
        print("装备条件不满足")

# 卸下武器
func remove_weapon():
    if weapon:
        add_to_inventory(weapon)
        print("卸下了武器：", weapon.item_name)
        weapon = null
    else:
        print("没有装备武器")

# 卸下护甲
func remove_armor():
    if armor:
        add_to_inventory(armor)
        print("卸下了护甲：", armor.item_name)
        armor = null
    else:
        print("没有装备护甲")

# 卸下饰品
func remove_accessory(accessory: Equipment):
    if accessories.has(accessory):
        accessories.erase(accessory)
        add_to_inventory(accessory)
        print("卸下了饰品：", accessory.item_name)
    else:
        print("未装备该饰品")

# 更新背包容量
func update_inventory_capacity(new_capacity: int):
    inventory_capacity = new_capacity
    inventory.resize(inventory_capacity)

# 检查并应用特殊装备效果（增加背包容量）
func check_special_equipment_effects():
    var capacity_boost = 0
    if weapon and "inventory_boost" in weapon.attribute_boosts:
        capacity_boost += weapon.attribute_boosts["inventory_boost"]
    if armor and "inventory_boost" in armor.attribute_boosts:
        capacity_boost += armor.attribute_boosts["inventory_boost"]
    for accessory in accessories:
        if "inventory_boost" in accessory.attribute_boosts:
            capacity_boost += accessory.attribute_boosts["inventory_boost"]
    update_inventory_capacity(default_inventory_size + capacity_boost)  # 基础容量加上增益

# 在装备或卸下物品后调用此函数
func update_equipment():
    check_special_equipment_effects()

# 检查是否满足装备条件
func meets_conditions(conditions: Dictionary) -> bool:
    for attr in conditions.keys():
        if self.get(attr) < conditions[attr]:
            return false
    return true

