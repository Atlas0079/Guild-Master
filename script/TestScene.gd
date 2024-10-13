# TestScene.gd
extends Node

@onready var llm = get_node("/root/LLM")
@onready var response_label = $Label

func _ready():
	$Button.pressed.connect(on_test_button_pressed)
	$EmbeddingButton.pressed.connect(on_embedding_button_pressed)
	LLM.response_received.connect(on_llm_response)

func on_test_button_pressed():
	test_llm_interaction()

func on_embedding_button_pressed():
	var test_memory = "莉娜在舞会上与艾伦跳舞,感到非常开心。"
	var embedding = await LLM.get_memory_embedding(test_memory)
	if embedding.size() > 0:
		print("成功获取嵌入向量,维度: ", embedding.size())
		response_label.text = "嵌入向量获取成功,维度: " + str(embedding.size())
	else:
		print("获取嵌入向量失败")
		response_label.text = "获取嵌入向量失败"

func on_llm_response(response: String):
	print("响应：", response)
	response_label.text = response

func test_llm_interaction():
	print("正在发送测试消息到LLM...")
	LLM.response_received.connect(on_test_response)
	LLM.send_message("你好，能给我讲个短笑话吗？")

func on_test_response(response: String):
	print("LLM交互测试完成。收到回复：", response)
	LLM.response_received.disconnect(on_test_response)