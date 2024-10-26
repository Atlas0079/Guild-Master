# SkillManager.gd
extends Node

var SkillUseConditions = preload("res://Script/Skill/SkillUseConditions.gd")
var SkillTiming = preload("res://Script/Skill/SkillTiming.gd")
var SkillEffect = preload("res://Script/Skill/SkillEffect.gd")  


# 获取角色可用的技能
# 参数: character_id - 角色ID
# 返回: 可用技能的ID，如果没有可用技能则返回null
func get_available_skill(character_id): 
	print("SkillManager get_available_skill 获取可用技能: ", character_id)
	# 获取角色数据
	var character_data = DataManager.get_character_data(character_id)
	# 获取角色的主动技能列表
	var active_skills = character_data.get("active_skills", {})
	
	# 创建一个包含技能ID和权重的列表
	var weighted_skills = []
	for skill_id in active_skills:
		weighted_skills.append({
			"id": skill_id,
			"weight": active_skills[skill_id].get("weight", 0)
		})
	
	# 根据权重降序排序技能列表
	weighted_skills.sort_custom(func(a, b): return a["weight"] > b["weight"])
	
	# 遍历排序后的技能列表
	for skill in weighted_skills:
		var skill_id = skill["id"]
		print("SkillManager get_available_skill 技能ID: ", skill_id)
		# 获取技能数据
		var skill_data = DataManager.get_skills_data(skill_id)
		# 获取技能的使用条件
		var use_conditions = skill_data.get("use_conditions")
		#print("SkillManager get_available_skill 技能使用条件: ", use_conditions)
		# 检查技能使用条件是否满足
		if SkillUseConditions.check_use_condition(use_conditions, character_id):
			# 获取技能的时机信息
			var timing = DataManager.get_skill_timing_by_character_id_and_skill_id(character_id, skill_id)
			# 根据时机获取可用目标
			var targets = SkillTiming.get_targets_by_timing(timing, character_id, skill_id)
			# 如果有可用目标，返回该技能ID
			if not targets.is_empty():
				#print("SkillManager get_available_skill 有可用目标，返回技能ID: ", skill_id)
				return skill_id

	# 如果没有找到可用技能，返回null
	print("SkillManager get_available_skill 没有找到可用技能，返回null")
	return null

# 选择技能目标
# 参数:character_id: 使用技能的角色ID skill_id: 要使用的技能ID
# 返回:符合条件的目标列表
func select_target(character_id, skill_id):
	# 获取技能的时机信息
	var timing = DataManager.get_skill_timing_by_character_id_and_skill_id(character_id, skill_id)

	# 根据时机信息获取可用目标
	var targets = SkillTiming.get_targets_by_timing(timing, character_id, skill_id)
	
	# 返回可用目标列表
	return targets


func use_skill(user_id, skill_id, target_id):
	print("SkillManager use_skill ", user_id, "对目标 ", target_id, " 使用技能 ", skill_id)
	SkillEffect.use_skill_without_cost(user_id, skill_id, target_id)
