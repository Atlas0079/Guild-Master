extends Node

func _ready():
	# 等待一帧以确保NPCManager已经完全加载
	await get_tree().process_frame
	BattleManager.initialize_and_start_battle("00001", "00002")
