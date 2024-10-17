extends Node

class_name NPC

const NPCAttributesScript = preload("res://Script/NPC/NPCAttributes.gd")
const NPCInventoryScript = preload("res://Script/NPC/NPCInventory.gd")
const NPCEquipmentScript = preload("res://Script/NPC/NPCEquipment.gd")
const NPCMemoryScript = preload("res://Script/NPC/NPCMemory.gd")
const NPCTraitsStatesScript = preload("res://Script/NPC/NPCTraitsStates.gd")


var attributes: NPCAttributesScript
var inventory: NPCInventoryScript
var equipment: NPCEquipmentScript
var memory: NPCMemoryScript
var traits_states: NPCTraitsStatesScript

func _init():
    attributes = NPCAttributesScript.new()
    inventory = NPCInventoryScript.new()
    equipment = NPCEquipmentScript.new()
    memory = NPCMemoryScript.new()
    traits_states = NPCTraitsStatesScript.new()

func init(_npc_name: String, _race: String, _strength: int, _intelligence: int, _dexterity: int, _charisma: int, _constitution: int, _perception: int):
    attributes.init(_npc_name, _race, _strength, _intelligence, _dexterity, _charisma, _constitution, _perception)
    inventory.init()
    equipment.init(self)

# 其他方法可以根据需要添加，大多数操作现在会调用相应组件的方法