# Script/Manager/SkillManager.gd
const Skill = preload("res://Script/Skill.gd")

var skills: Dictionary = {}

func _init():
    load_skills()

func load_skills():
    var file = FileAccess.open("res://Dataset/Skills.json", FileAccess.READ)
    var json_text = file.get_as_text()
    file.close()
    
    var json = JSON.new()
    var parse_result = json.parse(json_text)
    if parse_result == OK:
        var skill_data = json.get_data()
        for skill_id in skill_data:
            skills[int(skill_id)] = Skill.new(skill_data[skill_id])

func get_skill(skill_id: int) -> Skill:
    return skills.get(skill_id)

func get_highest_weight_skill(available_skills: Dictionary) -> int:
    if available_skills.is_empty():
        return 0
       
    var highest_weight = max(available_skills.keys())
    return available_skills[highest_weight]

func update_skill_weight(skill_id: int, new_weight: int):
    if skills.has(skill_id):
        skills[skill_id].set_weight(new_weight)