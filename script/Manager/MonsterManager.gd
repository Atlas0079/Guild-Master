# Script/Manager/MonsterManager.gd
extends Node

const Monster = preload("res://Script/Monster.gd")

var monsters: Dictionary = {}

func _init():
    load_monsters()

func load_monsters():
    var file = FileAccess.open("res://Dataset/Monsters.json", FileAccess.READ)
    var json_text = file.get_as_text()
    file.close()
    
    var json = JSON.new()
    var parse_result = json.parse(json_text)
    if parse_result == OK:
        var monster_data = json.get_data()
        for monster_id in monster_data:
            var data = monster_data[monster_id]
            var new_monster = Monster.new()
            new_monster.init(
                data.get("name", ""),
                data.get("race", "Monster"),
                data.get("health", 100),
                data.get("mana", 50),
                data.get("physical_attack", 10),
                data.get("magic_attack", 10),
                data.get("physical_defense", 10),
                data.get("magic_defense", 10),
                data.get("speed", 10)
            )
            
            # 添加技能
            var skills = data.get("skills", {})
            var weight = 1
            while weight <= 10 and skills.has(str(weight)):
                new_monster.add_skill(weight, int(skills[str(weight)]))
                weight += 1
            
            monsters[int(monster_id)] = new_monster

func get_monster(monster_id: int) -> Monster:
    return monsters.get(monster_id)

func create_monster_instance(monster_id: int) -> Monster:
    var base_monster = get_monster(monster_id)
    if base_monster:
        var new_monster = Monster.new()
        new_monster.init(
            base_monster.monster_name,
            base_monster.race,
            base_monster.health,
            base_monster.mana,
            base_monster.physical_attack,
            base_monster.magic_attack,
            base_monster.physical_defense,
            base_monster.magic_defense,
            base_monster.speed
        )
        for weight in base_monster.skills:
            new_monster.add_skill(weight, base_monster.skills[weight])
        return new_monster
    return null