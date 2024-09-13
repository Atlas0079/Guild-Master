extends Control

# 进入游戏的函数
func _Entering_game() -> void:
	# 假设游戏场景是 "res://scenes/game_scene.tscn"
	var game_scene = "res://scenes/game_scene.tscn"
	# 切换到游戏场景
	get_tree().change_scene(game_scene)
	print("进入游戏场景...")

# 游戏设置的函数
func _Game_Setting() -> void:
	# 这里以设置音量为例
	var master_volume = 0.5  # 设置主音量为 50%
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	print("音量设置为: ", master_volume * 100, "%")

# 读取存档的函数
func _Loading_game() -> void:
	var save_path = "user://save_game.save"  # 存档文件路径
	
	var file = FileAccess.open(save_path, FileAccess.READ)  # 打开文件进行读取
	
	# 判断存档文件是否存在
	if file:
		var save_data = file.get_as_text()  # 获取存档数据
		file.close()
		
		# 创建 JSON 实例并解析读取的存档数据 (假设存档数据是 JSON 格式)
		var json = JSON.new()
		var error = json.parse(save_data)
		if error == OK:
			var data = json.result
			print("读取到的存档数据: ", data)
			# 这里可以根据存档数据恢复游戏的状态
		else:
			print("读取存档失败，数据格式错误")
	else:
		print("没有找到存档文件")
