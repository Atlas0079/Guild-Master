# TestScene.gd
extends Node

#@onready var llm = $LLM  # 如果LLM是场景中的节点
# 或者，如果LLM是AutoLoad脚本：
@onready var llm = get_node("/root/LLM")

@onready var response_label = $Label  # 假设您有一个Label节点来显示响应

func _ready():
	# 假设您的按钮名为 "TestButton"
	$Button.pressed.connect(on_test_button_pressed)
	
	# 连接LLM的response_received信号
	LLM.response_received.connect(on_llm_response)

func on_test_button_pressed():
	LLM.test_llm_interaction()

func on_llm_response(response: String):
	# 在这里处理LLM的响应
	print("收到LLM响应：", response)
	response_label.text = response  # 将响应显示在Label上
