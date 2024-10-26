extends Control

var npc_data = {}
var monster_data = {}
var current_character = null

var text_edit_width = 300

func _ready():
	load_data()
	setup_ui()

func load_data():
	var file = FileAccess.open("res://Dataset/NPC/NPCData.json", FileAccess.READ)
	npc_data = JSON.parse_string(file.get_as_text())
	file.close()
	
	file = FileAccess.open("res://Dataset/Monster/MonsterTemplate.json", FileAccess.READ)
	monster_data = JSON.parse_string(file.get_as_text())
	file.close()

func setup_ui():
	# 创建主要的垂直布局
	var main_vbox = VBoxContainer.new()
	main_vbox.name = "MainVBox"
	main_vbox.anchor_right = 1
	main_vbox.anchor_bottom = 1
	add_child(main_vbox)

	# 创建顶部水平布局
	var top_hbox = HBoxContainer.new()
	top_hbox.name = "TopHBox"
	main_vbox.add_child(top_hbox)

	# 创建角色选择下拉菜单
	var character_select = OptionButton.new()
	character_select.name = "CharacterSelect"
	character_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	character_select.item_selected.connect(_on_character_selected)
	top_hbox.add_child(character_select)
	
	# 添加NPC和怪物到下拉菜单
	var index = 0
	for npc_id in npc_data.keys():
		character_select.add_item("NPC: " + npc_data[npc_id].name, index)
		character_select.set_item_metadata(index, npc_id)
		index += 1
	for monster_id in monster_data.keys():
		character_select.add_item("Monster: " + monster_data[monster_id].name, index)
		character_select.set_item_metadata(index, monster_id)
		index += 1
	
	# 添加保存按钮
	var save_button = Button.new()
	save_button.text = "保存"
	save_button.pressed.connect(_on_save_pressed)
	top_hbox.add_child(save_button)

	# 创建属性编辑区域
	var scroll_container = ScrollContainer.new()
	scroll_container.name = "ScrollContainer"
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(scroll_container)

func _on_character_selected(index):
	var character_select = $MainVBox/TopHBox/CharacterSelect
	var selected_id = character_select.get_item_metadata(index)
	if character_select.get_item_text(index).begins_with("NPC"):
		current_character = npc_data[selected_id]
	else:
		current_character = monster_data[selected_id]
	update_property_editor()

func update_property_editor():
	# 清除旧的属性编辑器
	var scroll_container = $MainVBox/ScrollContainer
	for child in scroll_container.get_children():
		scroll_container.remove_child(child)
		child.queue_free()
	
	# 创建新的属性编辑器
	var vbox = VBoxContainer.new()
	scroll_container.add_child(vbox)
	
	create_property_editors(vbox, current_character)

func create_property_editors(parent, data, prefix=""):
	if parent.get_child_count() > 0:
		return

	var categories = {
		"基本信息": ["name", "race", "creature_type"],
		"属性": ["strength", "dexterity", "constitution", "intelligence", "charisma", "perception"],
		"战斗属性": ["physical_attack", "physical_defense", "magic_attack", "magic_defense"],
		"资源": ["current_health", "max_health", "current_mana", "max_mana", "current_energy", "max_energy", "current_stamina", "max_stamina", "current_qi", "max_qi", "current_stress", "max_stress"],
		"技能和特性": ["learned_skills", "active_skills", "traits"],
		"装备和物品": ["equipment", "inventory", "inventory_capacity", "money"],
		"其他": []
	}

	var categorized_data = {}
	for category in categories:
		categorized_data[category] = {}

	for key in data.keys():
		var category_found = false
		for category in categories:
			if key in categories[category]:
				categorized_data[category][key] = data[key]
				category_found = true
				break
		if not category_found:
			categorized_data["其他"][key] = data[key]

	for category in categorized_data:
		var category_label = Label.new()
		category_label.text = category
		category_label.add_theme_color_override("font_color", Color(0.5, 0.7, 1.0))
		parent.add_child(category_label)

		for key in categorized_data[category]:
			var value = categorized_data[category][key]
			var hbox = HBoxContainer.new()
			
			var label = Label.new()
			label.text = prefix + key
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox.add_child(label)
			
			if typeof(value) == TYPE_DICTIONARY:
				var expand_button = Button.new()
				expand_button.text = "展开"
				expand_button.pressed.connect(func(): toggle_expand(hbox, value, prefix + key + "."))
				hbox.add_child(expand_button)
			elif typeof(value) == TYPE_ARRAY:
				var array_edit = LineEdit.new()
				array_edit.text = JSON.stringify(value)
				array_edit.name = prefix + key
				array_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				array_edit.custom_minimum_size.x = text_edit_width  # 设置最小宽度为text_edit_width像素
				hbox.add_child(array_edit)
			else:
				var edit = LineEdit.new()
				edit.text = str(value)
				edit.name = prefix + key
				edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				edit.custom_minimum_size.x = text_edit_width  # 设置最小宽度为text_edit_width像素
				hbox.add_child(edit)
			
			var delete_button = Button.new()
			delete_button.text = "删除"
			delete_button.pressed.connect(func(): delete_property(hbox, prefix + key))
			hbox.add_child(delete_button)
			
			parent.add_child(hbox)

func toggle_expand(hbox, data, prefix):
	var expand_button = hbox.get_child(1)
	if expand_button.text == "展开":
		expand_button.text = "收起"
		var sub_vbox = VBoxContainer.new()
		sub_vbox.name = "SubVBox"
		hbox.add_child(sub_vbox)
		create_nested_property_editors(sub_vbox, data, prefix)
	else:
		expand_button.text = "展开"
		var sub_vbox = hbox.get_node_or_null("SubVBox")
		if sub_vbox:
			hbox.remove_child(sub_vbox)
			sub_vbox.queue_free()

func create_nested_property_editors(parent, data, prefix):
	for key in data.keys():
		var value = data[key]
		var hbox = HBoxContainer.new()
		
		var label = Label.new()
		label.text = prefix + key
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(label)
		
		if typeof(value) == TYPE_DICTIONARY:
			var expand_button = Button.new()
			expand_button.text = "展开"
			expand_button.pressed.connect(func(): toggle_expand(hbox, value, prefix + key + "."))
			hbox.add_child(expand_button)
		elif typeof(value) == TYPE_ARRAY:
			var array_edit = LineEdit.new()
			array_edit.text = JSON.stringify(value)
			array_edit.name = prefix + key
			array_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			array_edit.custom_minimum_size.x = text_edit_width  # 设置最小宽度为text_edit_width像素
			hbox.add_child(array_edit)
		else:
			var edit = LineEdit.new()
			edit.text = str(value)
			edit.name = prefix + key
			edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			edit.custom_minimum_size.x = text_edit_width  # 设置最小宽度为text_edit_width像素
			hbox.add_child(edit)
		
		var delete_button = Button.new()
		delete_button.text = "删除"
		delete_button.pressed.connect(func(): delete_property(hbox, prefix + key))
		hbox.add_child(delete_button)
		
		parent.add_child(hbox)

func delete_property(hbox, key):
	var keys = key.split(".")
	var current = current_character
	for i in range(keys.size() - 1):
		current = current[keys[i]]
	current.erase(keys[-1])
	hbox.queue_free()

func _on_save_pressed():
	# 保存修改后的数据
	save_property_changes($MainVBox/ScrollContainer.get_child(0), current_character)
	
	# 将修改后的数据写回文件
	var file = FileAccess.open("res://Dataset/NPC/NPCData.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(npc_data, "\t"))
	file.close()
	
	file = FileAccess.open("res://Dataset/Monster/MonsterTemporary.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(monster_data, "\t"))
	file.close()
	
	print("数据已保存")

func save_property_changes(node, data):
	for child in node.get_children():
		if child is HBoxContainer:
			var key = child.get_child(0).text
			if child.get_child_count() > 2 and child.get_child(2) is VBoxContainer:
				var sub_data = {}
				save_property_changes(child.get_child(2), sub_data)
				set_nested_value(data, key, sub_data)
			elif child.get_child(1) is LineEdit:
				var value = child.get_child(1).text
				set_nested_value(data, key, parse_value(value))
		elif child is VBoxContainer:
			save_property_changes(child, data)

func set_nested_value(data, key, value):
	var keys = key.split(".")
	var current = data
	for i in range(keys.size() - 1):
		if not current.has(keys[i]):
			current[keys[i]] = {}
		current = current[keys[i]]
	current[keys[-1]] = value

func parse_value(value):
	if value.is_valid_int():
		return int(value)
	elif value.is_valid_float():
		return float(value)
	elif value == "true":
		return true
	elif value == "false":
		return false
	elif value.begins_with("[") and value.ends_with("]"):
		return JSON.parse_string(value)
	else:
		return value
