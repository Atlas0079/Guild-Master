extends Node

static func check_use_condition(conditions, user_id):
	# 如果传入的是一个空数组，则返回true
	if conditions.is_empty():
		return true 
	
	# 遍历所有条件，如果有任何一个条件不满足，则返回false
	for condition in conditions:
		if condition.is_empty():
			print("SkillUseConditions check_use_condition 无使用条件")
			continue
		
		if "type" not in condition:
			print("错误：条件中缺少'type'键")
			return false
		
		match condition["type"]:
			"mp_cost":
				if not check_mp_cost(condition["value"], user_id):
					return false
			"hp_cost":
				if not check_hp_cost(condition["value"], user_id):
					return false
			"level_requirement":
				if not check_level_requirement(condition["value"], user_id):
					return false
			"item_requirement":
				if not check_item_requirement(condition["value"], user_id):
					return false
			"state_requirement":
				if not check_state_requirement(condition["value"], user_id):
					return false
			_:
				print("未知的使用条件类型: ", condition["type"])
				return false
	
	# 如果所有条件都满足，返回true
	return true

static func condition_cost(condition, user_id):
	match condition["type"]:
		"mp_cost":
			return cost_mp(condition["value"], user_id)
		"hp_cost":
			return cost_hp(condition["value"], user_id) 

static func cost_mp(cost, user_id):
	var user = DataManager.get_character_data(user_id)
	user["current_mana"] -= cost
	print("SkillUseConditions cost_mp 消耗MP: ", cost," ", user_id)
	DataManager.save_character_data(user_id, user)    

static func cost_hp(cost, user_id):
	var user = DataManager.get_character_data(user_id)
	user["current_health"] -= cost
	print("SkillUseConditions cost_hp 消耗HP: ", cost," ", user_id)
	DataManager.save_character_data(user_id, user)       

static func check_mp_cost(cost, user_id):
	var user = DataManager.get_character_data(user_id)
	if user["current_mana"] < cost:
		print("SkillUseConditions check_mp_cost 检查MP消耗: ", cost," ", user_id, " 不足")
		return false
	else:
		print("SkillUseConditions check_mp_cost 检查MP消耗: ", cost," ", user_id," 满足")
		return true

static func check_hp_cost(cost, user_id):
	var user = DataManager.get_character_data(user_id)
	if user["current_health"] <= cost:
		print("SkillUseConditions check_hp_cost 检查HP消耗: ", cost," ", user_id, " 不足")
		return false
	else:
		print("SkillUseConditions check_hp_cost 检查HP消耗: ", cost," ", user_id," 满足")
		return true

static func check_level_requirement(required_level, user_id):
	var user = DataManager.get_character_data(user_id)
	if user["level"] < required_level:
		print("SkillUseConditions check_level_requirement 检查等级要求: ", required_level," ", user_id, " 不足")
		return false
	else:
		print("SkillUseConditions check_level_requirement 检查等级要求: ", required_level," ", user_id," 满足")
		return true

static func check_item_requirement(item_id, user_id):
	var user = DataManager.get_character_data(user_id)
	if item_id in user["inventory"]:
		print("SkillUseConditions check_item_requirement 检查物品要求: ", item_id," ", user_id, " 满足")
		return true
	else:
		print("SkillUseConditions check_item_requirement 检查物品要求: ", item_id," ", user_id, " 不足")
		return false

static func check_state_requirement(required_state, user_id):
	var user = DataManager.get_character_data(user_id)
	if required_state in user["states"]:
		print("SkillUseConditions check_state_requirement 检查状态要求: ", required_state," ", user_id, " 满足")
		return true
	else:
		print("SkillUseConditions check_state_requirement 检查状态要求: ", required_state," ", user_id, " 不足")
		return false

# 可以根据需要添加更多的条件检查函数
