# Script/NPC/NPCAttributes.gd
extends Node

var npc_name: String
var race: String = "Human"

var strength: int = 10
var intelligence: int = 10
var dexterity: int = 10
var charisma: int = 10
var constitution: int = 10
var perception: int = 10

var health: int = 100
var mana: int = 50
var endurance: int = 50

var stamina: int = 50
var stress: int = 0

var physical_attack: int = 10
var magic_attack: int = 10
var physical_defense: int = 10
var magic_defense: int = 10
var speed: int = 10

var action_points: int = 0
var action_threshold: int = 10

# 新增: 技能字典
var skills: Dictionary = {}

func init(_npc_name: String, _race: String, _strength: int, _intelligence: int, _dexterity: int, _charisma: int, _constitution: int, _perception: int):
	npc_name = _npc_name
	race = _race
	strength = _strength
	intelligence = _intelligence
	dexterity = _dexterity
	charisma = _charisma
	constitution = _constitution
	perception = _perception
	
	update_derived_stats()

func update_derived_stats():
	health = constitution * 10
	mana = intelligence * 5
	stamina = strength * 5
	speed = (dexterity + strength) / 2
	
	physical_attack = strength * 2 + dexterity
	magic_attack = intelligence * 2 + perception
	physical_defense = constitution * 2 + strength
	magic_defense = intelligence + constitution + perception

# 新增: 添加技能方法
func add_skill(weight: int, skill_id: int):
	if len(skills) < 10 and weight >= 1 and weight <= 10:
		skills[weight] = skill_id

# 新增: 移除技能方法
func remove_skill(weight: int):
	skills.erase(weight)

# Getter 和 Setter 方法
func get_strength() -> int:
	return strength

func set_strength(value: int):
	strength = value
	update_derived_stats()

# 为其他属性添加类似的 getter 和 setter 方法

func modify_health(amount: int):
	health = clamp(health + amount, 0, constitution * 10)

func modify_mana(amount: int):
	mana = clamp(mana + amount, 0, intelligence * 5)

func modify_stamina(amount: int):
	stamina = clamp(stamina + amount, 0, strength * 5)

func modify_stress(amount: int):
	stress = clamp(stress + amount, 0, 100)

# 新增: 获取所有技能
func get_skills() -> Dictionary:
	return skills

# 新增: 获取特定权重的技能
func get_skill(weight: int) -> int:
	return skills.get(weight, 0)