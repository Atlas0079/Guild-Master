extends Node

# 加载 Equipment 类（路径需要根据项目结构调整）
const Equipment = preload("res://Script/Equipment.gd")  # 确保路径正确

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
