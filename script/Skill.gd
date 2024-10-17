# Script/Skill.gd
extends Node

var skill_id: int
var skill_name: String
var description: String
var weight: int
var use_conditions: Array
var effects: Array
var timings: Array

func _init(skill_data: Dictionary):
    skill_id = skill_data.get("id", 0)
    skill_name = skill_data.get("name", "")
    description = skill_data.get("description", "")
    weight = skill_data.get("weight", 0)
    use_conditions = skill_data.get("use_conditions", [])
    effects = skill_data.get("effects", [])
    timings = skill_data.get("timings", [])

func can_use(user, battlefield_id: String) -> bool:
    for condition in use_conditions:
        if not check_condition(user, condition):
            return false
    
    for timing in timings:
        if not check_timing(battlefield_id, timing):
            return false
    
    return true

func check_condition(user, condition: Dictionary) -> bool:
    match condition.type:
        "mp_cost":
            return user.mp >= condition.value
        # 添加更多条件类型
    return false

func check_timing(battlefield_id: String, timing: String) -> bool:
    var battlefield = BattleManager.get_battlefield(battlefield_id)
    if not battlefield:
        return false

    match timing:
        "enemy_hp_below_half":
            return check_enemy_hp_below_half(battlefield)
        "highest_physical_attack_ally":
            return check_highest_physical_attack_ally(battlefield)
        "enemy_in_full_column":
            return check_enemy_in_full_column(battlefield)
    return false

func check_enemy_hp_below_half(battlefield: BattleManager.Battlefield) -> bool:
    for position in battlefield.battlefield[BattleManager.Camp.MONSTER].values():
        if position and position.health < position.max_health / 2:
            return true
    return false

func check_highest_physical_attack_ally(battlefield: BattleManager.Battlefield) -> bool:
    var highest_attack = 0
    var highest_attack_character = null
    for position in battlefield.battlefield[BattleManager.Camp.ADVENTURER].values():
        if position and position.physical_attack > highest_attack:
            highest_attack = position.physical_attack
            highest_attack_character = position
    return highest_attack_character != null

func check_enemy_in_full_column(battlefield: BattleManager.Battlefield) -> bool:
    var front_positions = [BattleManager.Position.FRONT_TOP, BattleManager.Position.FRONT_MIDDLE, BattleManager.Position.FRONT_BOTTOM]
    var back_positions = [BattleManager.Position.BACK_TOP, BattleManager.Position.BACK_MIDDLE, BattleManager.Position.BACK_BOTTOM]
    
    return (all_positions_filled(battlefield, BattleManager.Camp.MONSTER, front_positions) or
            all_positions_filled(battlefield, BattleManager.Camp.MONSTER, back_positions))

func all_positions_filled(battlefield: BattleManager.Battlefield, camp: int, positions: Array) -> bool:
    for position in positions:
        if not battlefield.battlefield[camp][position]:
            return false
    return true

func apply_effects(target):
    for effect in effects:
        apply_effect(target, effect)

func apply_effect(target, effect: Dictionary):
    match effect.type:
        "damage":
            target.take_damage(effect.value)
        "heal":
            target.heal(effect.value)
        "burn":
            target.apply_burn(effect.value, effect.duration)
        # 添加更多效果类型

func set_weight(new_weight: int):
    weight = new_weight