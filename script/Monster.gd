extends Node

var monster_name: String
var race: String = "Monster"

var health: int = 100
var mana: int = 50

var physical_attack: int = 10
var magic_attack: int = 10
var physical_defense: int = 10
var magic_defense: int = 10
var speed: int = 10

var skills: Dictionary = {}

func init(_monster_name: String, _race: String, _health: int, _mana: int, _physical_attack: int, _magic_attack: int, _physical_defense: int, _magic_defense: int, _speed: int):
	monster_name = _monster_name
	race = _race
	health = _health
	mana = _mana
	physical_attack = _physical_attack
	magic_attack = _magic_attack
	physical_defense = _physical_defense
	magic_defense = _magic_defense
	speed = _speed
# 在Monster类中添加

func add_skill(weight: int, skill_id: int):
	if len(skills) < 10 and weight >= 1 and weight <= 10:
		skills[weight] = skill_id

func remove_skill(weight: int):
	skills.erase(weight)

func modify_health(amount: int):
	health = max(0, health + amount)

func modify_mana(amount: int):
	mana = max(0, mana + amount)

# 为其他属性添加getter和setter方法
func get_physical_attack() -> int:
	return physical_attack

func set_physical_attack(value: int):
	physical_attack = value

# 为其他属性添加类似的getter和setter方法
func get_magic_attack() -> int:
	return magic_attack

func set_magic_attack(value: int):
	magic_attack = value

func get_physical_defense() -> int:
	return physical_defense
