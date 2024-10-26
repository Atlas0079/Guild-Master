# Script/Skill/SkillEffect.gd
extends Node

static func use_skill_without_cost(user_id, skill_id, target_id):
	var specific_skill_data = DataManager.get_skills_data(skill_id)
	print("SkillEffect use_skill_without_cost 技能数据: ", specific_skill_data["effects"])
	var expanded_targets = expand_targets(specific_skill_data, target_id)
	
	parse_and_apply_effects(specific_skill_data["effects"], user_id, expanded_targets)

#根据技能的tag，扩展技能的目标
static func expand_targets(specific_skill_data, original_target_id):
	var tags = specific_skill_data.get("tag", [])
	var expanded_targets = []

	if "Column" in tags or "Row" in tags or "all_team" in tags:
		var target_team = DataManager.get_team_by_npc_id(original_target_id)
		if "column" in tags:
			expanded_targets = add_column_targets(original_target_id, target_team)
		elif "row" in tags:
			expanded_targets = add_row_targets(original_target_id, target_team)
		elif "all_team" in tags:
			expanded_targets = get_all_team_targets(target_team)
	else:
		expanded_targets.append(original_target_id)
	return expanded_targets
#返回的是一个列表，列表中是目标的id

#添加列目标
static func add_column_targets(original_target_id, target_team):
	var target_position = DataManager.get_position_by_npc_id(original_target_id)
	var column = target_position.split("_")[1]  # 获取列名(left, center, right)
	var expanded_targets = []
	for position in target_team["positions"]:
		if position.ends_with(column):
			var character_id = target_team["positions"][position]["character_id"]
			if character_id and not expanded_targets.has(character_id):
				expanded_targets.append(character_id)
	return expanded_targets
#返回的是一个列表，列表中是目标的id

#添加行目标
static func add_row_targets(original_target_id, target_team):
	var target_position = DataManager.get_position_by_npc_id(original_target_id)
	var row = target_position.split("_")[0]  # 获取行名(front, back)
	var expanded_targets = []
	
	for position in target_team["positions"]:
		if position.starts_with(row):
			var character_id = target_team["positions"][position]["character_id"]
			if character_id and not expanded_targets.has(character_id):
				expanded_targets.append(character_id)
	
	return expanded_targets
#返回的是一个列表，列表中是目标的id

#获取所有目标
static func get_all_team_targets(target_team):
	var all_targets = []
	for position in target_team["positions"]:
		var character_id = target_team["positions"][position]["character_id"]
		if character_id:
			all_targets.append(character_id)
	return all_targets
#返回的是一个列表，列表中是目标的id

#应用技能效果
#type 是效果的类型，value 是效果的值
#targets 是目标的id列表
static func apply_effect(effect: Dictionary, user_id: String, targets: Array):
	var caster = DataManager.get_character_data(user_id)
	#print("SkillEffect apply_effect 效果: ", effect)
	var effect_type = effect["type"]
	match effect_type:
			"physical_damage":
				apply_physical_damage(effect, caster, targets)
			"magic_damage":
				apply_magic_damage(effect, caster, targets)
			"heal":
				apply_heal(effect, caster, targets)
			"status":
				apply_status(effect, caster, targets)
			_:
				print("未知的效果类型: ", effect_type)
	

	

# 应用伤害效果
static func apply_physical_damage(effect, caster, targets):
	var damage_multiplier = effect["value"] / 100.0  # 将百分比转换为小数
	var base_damage = caster.physical_attack * damage_multiplier
	
	for target_id in targets:
		var target = DataManager.get_character_data(target_id)
		print("SkillEffect apply_physical_damage 目标: ", target)
		var final_damage = max(base_damage - target.physical_defense, 0)  # 确保伤害不小于0
		target.current_health -= final_damage
		target.current_health = max(target.current_health, 0)  # 确保生命值不小于0
		
		print("物理伤害: ", caster.name, " 对 ", target.name, " 造成 ", final_damage, " 点伤害")
		
		# 更新目标数据
		DataManager.save_character_data(target_id, target)
		
# 应用法术伤害效果
static func apply_magic_damage(effect, caster, targets):
	var damage_multiplier = effect["value"] / 100.0  # 将百分比转换为小数
	var base_damage = caster.magic_attack * damage_multiplier
	
	for target_id in targets:
		var target = DataManager.get_character_data(target_id)
		var damage_reduction = min(target.magic_defense / 100.0, 1)  # 确保法术防御不超过100%
		var final_damage = base_damage * (1 - damage_reduction)
		target.current_health -= final_damage
		target.current_health = max(target.current_health, 0)  # 确保生命值不小于0
		
		print("法术伤害: ", caster.name, " 对 ", target.name, " 造成 ", final_damage, " 点伤害")
		
		# 更新目标数据
		DataManager.save_character_data(target_id, target)

# 应用治疗效果
static func apply_heal(effect, caster, targets):
	var heal_multiplier = effect["value"] / 100.0  # 将百分比转换为小数
	var base_heal = caster.magic_attack * heal_multiplier
	
	for target_id in targets:
		var target = DataManager.get_character_data(target_id)
		var final_heal = base_heal
		
		# 检查是否存在heal_block状态
		if "heal_block" in target.states:
			var heal_block_value = target.states["heal_block"]
			var heal_reduction = min(heal_block_value * 0.2, 1.0)  
			# 每1点heal_block减少20%,最多减少100%
			final_heal *= (1 - heal_reduction)
		
		final_heal = max(final_heal, 0)  # 确保治疗量不小于0
		target.current_health += final_heal
		target.current_health = min(target.current_health, target.max_health)  # 确保生命值不超过最大值
		
		print("治疗效果: ", caster.name, " 对 ", target.name, " 恢复了 ", final_heal, " 点生命值")
		
		# 更新目标数据
		DataManager.save_character_data(target_id, target)



# 应用状态效果
static func apply_status(effect: Dictionary, caster: Dictionary, targets: Array):
	var status_type = effect["status_type"]
	var value = effect["value"]
	
	for target_id in targets:
		var target = DataManager.get_character_data(target_id)
		
		# 检查目标是否已经有这个状态
		var status_exists = false
		for state in target.states:
			if status_type in state:
				# 如果状态已存在,更新它的值
				state[status_type] = max(state[status_type], value)
				status_exists = true
				break
		
		# 如果状态不存在,添加新的状态
		if not status_exists:
			target.states.append({status_type: value})
		
		print(caster.name, " 对 ", target.name, " 施加了 ", status_type, " 状态,持续 ", value, " 回合")
		
		# 更新目标数据
		DataManager.save_character_data(target_id, target)

# 解析并应用所有效果
static func parse_and_apply_effects(effects: Array, caster, targets):
	for effect in effects:
		apply_effect(effect, caster, targets)
