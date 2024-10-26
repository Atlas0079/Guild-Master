# DataManager.gd
extends Node

#获取可用目标
#参数为timing（列表，包含字符串）,caster_id（施法者id）,skill_id（技能id）    
static func get_targets_by_timing(timings, caster_id, skill_id):
	#print("SkillTiming get_targets_by_timing 技能时机: ", timings)
	var targets = []
	
	# 获取技能数据
	var skill_data = DataManager.get_skills_data(skill_id)
	var tags = skill_data.get("tag", [])
	#print("SkillTiming get_targets_by_timing 技能标签: ", tags)
	# 根据tag获取初始目标列表
	if "ally_only" in tags:
		targets = get_ally_team_characters(caster_id)
		#print("SkillTiming get_targets_by_timing 获取同队角色ID列表: ", targets)
	elif "enemy_only" in tags:
		targets = get_enemy_team_characters(caster_id)
		#print("SkillTiming get_targets_by_timing 获取敌对角色ID列表: ", targets)
	else:
		print("SkillTiming get_targets_by_timing 错误: 技能 ", skill_id, " 未指定目标类型 (ally_only 或 enemy_only)")
		return []
	
	# 如果有Timing，则根据Timing筛选目标，取多个Timing的交集
	if not timings.is_empty():
		# 遍历所有Timing
		for timing_type in timings:
			var timing_targets = []
			match timing_type:
				"ally_hp_below_50_percent":
					timing_targets = get_ally_hp_below_50_percent(caster_id)
				"self_hp_above_50_percent":
					timing_targets = get_self_hp_above_50_percent(caster_id)
				"self":
					timing_targets = [caster_id]
				_:
					print("SkillTiming get_targets_by_timing 错误: 未知的 Timing 类型: ", timing_type)
		
			# 取初始目标列表和筛选后目标列表的交集
			targets = targets.filter(func(target): return target in timing_targets)
			#print("SkillTiming get_targets_by_timing ", timing_type, " 筛选后的目标: ", targets)
	
	#无论有没有Timing，都根据通用目标规则选择最终目标
	targets = filter_targets_by_general_rules(targets, caster_id)	

	print("SkillTiming get_targets_by_timing 最终目标: ", targets)
	return targets
#返回id列表

# 根据通用目标规则选择目标
# 参数为targets（可用目标列表）,character_id（施法者id）
static func filter_targets_by_general_rules(targets, character_id):
	# 获取施法者所在队伍（未使用）
	var _caster_team = DataManager.get_team_by_character_id(character_id)
	#print("SkillTiming filter_targets_by_general_rules 可用目标: ", targets)
	# 获取施法者位置
	var caster_position = DataManager.get_position_by_character_id(character_id)
	#print("SkillTiming filter_targets_by_general_rules 施法者位置: ", caster_position)
	var front_targets = []
	var back_targets = []
	
	# 将目标分为前排和后排
	for target in targets:
		var target_position = DataManager.get_position_by_character_id(target)
		if is_front_position(target_position):
			front_targets.append(target)
		else:
			back_targets.append(target)
	
	# 优先选择前排目标
	if not front_targets.is_empty():
		# 如果有前排目标，按照与施法者的接近程度排序
		var sorted_targets = sort_targets_by_proximity(front_targets, caster_position)
		
		return sorted_targets[0] if sorted_targets else []
	elif not back_targets.is_empty():
		# 如果没有前排目标但有后排目标，按照与施法者的接近程度排序
		var sorted_targets = sort_targets_by_proximity(back_targets, caster_position)
		
		return sorted_targets[0] if sorted_targets else []
	else:
		# 如果没有可用目标，返回空数组
		return []
	# 返回最终选择的目标id
	# 注意：对于能对一列或一行造成效果的技能，在Effect中处理


# 判断给定位置是否为前排位置
static func is_front_position(position):
	return position.begins_with("front_")

# 根据施法者位置对目标进行排序
static func sort_targets_by_proximity(targets, caster_position):
	var sorted_targets = []
	var left_targets = []
	var center_targets = []
	var right_targets = []

	# 将目标分类到左、中、右列
	for target in targets:
		var target_position = DataManager.get_position_by_character_id(target)
		if target_position.ends_with("_left"):
			left_targets.append(target)
		elif target_position.ends_with("_center"):
			center_targets.append(target)
		elif target_position.ends_with("_right"):
			right_targets.append(target)

	# 根据施法者位置排序目标
	if caster_position.ends_with("_left"):
		# 如果施法者在左侧，优先选择左侧目标
		sorted_targets = left_targets + center_targets + right_targets
	elif caster_position.ends_with("_right"):
		# 如果施法者在右侧，优先选择右侧目标
		sorted_targets = right_targets + center_targets + left_targets
	else:  # 施法者在中间
		if left_targets.size() > 0 and right_targets.size() > 0:
			# 如果左右两侧都有目标，随机选择一侧作为优先
			if randf() < 0.5:
				sorted_targets = left_targets + center_targets + right_targets
			else:
				sorted_targets = right_targets + center_targets + left_targets
		elif left_targets.size() > 0:
			# 如果只有左侧有目标，优先选择左侧
			sorted_targets = left_targets + center_targets + right_targets
		else:
			# 如果只有右侧有目标，优先选择右侧
			sorted_targets = right_targets + center_targets + left_targets

	#print("SkillTiming sort_targets_by_proximity 排序后的目标: ", sorted_targets)
	return sorted_targets

# 获取同队角色ID列表
static func get_ally_team_characters(character_id: String) -> Array:
	var battlefield_data = BattleManager.get_current_battle_data()
	var ally_team = ""
	var ally_characters = []

	# 确定角色所在的队伍
	for team in ["adventurer_team", "monster_team"]:
		for position in battlefield_data[team]["positions"]:
			if battlefield_data[team]["positions"][position] and battlefield_data[team]["positions"][position]["character_id"] == character_id:
				ally_team = team
				break
		if ally_team:
			break

	if ally_team:
		for position in battlefield_data[ally_team]["positions"]:
			if battlefield_data[ally_team]["positions"][position]:
				ally_characters.append(battlefield_data[ally_team]["positions"][position]["character_id"])

	return ally_characters

# 获取敌对队伍角色ID列表
static func get_enemy_team_characters(character_id: String) -> Array:
	var battlefield_data = BattleManager.get_current_battle_data()
	var enemy_team = ""
	var enemy_characters = []

	# 确定角色所在的队伍
	for team in ["adventurer_team", "monster_team"]:
		for position in battlefield_data[team]["positions"]:
			if battlefield_data[team]["positions"][position] and battlefield_data[team]["positions"][position]["character_id"] == character_id:
				enemy_team = "monster_team" if team == "adventurer_team" else "adventurer_team"
				break
		if enemy_team:
			break

	if enemy_team:
		for position in battlefield_data[enemy_team]["positions"]:
			if battlefield_data[enemy_team]["positions"][position]:
				enemy_characters.append(battlefield_data[enemy_team]["positions"][position]["character_id"])

	return enemy_characters


static func get_enemy_hp_below_half(caster_id: String) -> Array:
	var targets = []
	var enemy_characters = get_enemy_team_characters(caster_id)
	
	for character_id in enemy_characters:
		var char_data = DataManager.get_character_data(character_id)
		if char_data["current_health"] < char_data["max_health"] / 2:
			targets.append(character_id)
	
	print("SkillTiming get_enemy_hp_below_half 找到的目标: ", targets)
	return targets

static func get_ally_hp_below_50_percent(caster_id: String) -> Array:
	var targets = []
	var ally_characters = get_ally_team_characters(caster_id)
	
	for character_id in ally_characters:
		var char_data = DataManager.get_character_data(character_id)
		if char_data["current_health"] < char_data["max_health"] / 2:
			targets.append(character_id)
	print("SkillTiming get_ally_hp_below_50_percent 找到的目标: ", targets)
	return targets

static func get_self_hp_above_50_percent(caster_id: String) -> Array:
	var targets = []
	var char_data = DataManager.get_character_data(caster_id)
	if char_data["current_health"] > char_data["max_health"] / 2:
		targets.append(caster_id)
	print("SkillTiming get_self_hp_above_50_percent 找到的目标: ", targets)
	return targets
