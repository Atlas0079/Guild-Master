# LLM.gd
extends Node

const API_URL = "https://35.aigcbest.top/v1/chat/completions"
const API_KEY = "sk-BIBKYxlMfEJLwFMi89Cc39D72a434760A326501f171987Fc"

var http_request: HTTPRequest

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

func send_message(user_message: String, callback: Callable):
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + API_KEY
	]
	var body = JSON.stringify({
		"model": "gpt-4o-mini",
		"messages": [{"role": "user", "content": user_message}]
	})
	
	var error = http_request.request(API_URL, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("HTTP请求发生错误。")
		return
	
	await http_request.request_completed
	# 注意：我们不在这里直接调用回调，而是在_on_request_completed中调用

func _on_request_completed(_result, response_code: int, _headers, body: PackedByteArray):
	if response_code != 200:
		push_error("HTTP请求失败。状态码：" + str(response_code))
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if json != null:
		if "choices" in json and json.choices.size() > 0:
			var llm_response = json.choices[0].message.content
			print("LLM响应：", llm_response)
			# 发出一个信号，包含LLM的响应
			response_received.emit(llm_response)
		else:
			push_error("LLM响应格式不正确")
	else:
		push_error("JSON解析错误")

# 定义一个新的信号
signal response_received(response: String)

# 测试函数
func test_llm_interaction():
	print("正在发送测试消息到LLM...")
	send_message("你好，能给我讲个短笑话吗？", Callable(self, "on_test_response"))

func on_test_response():
	print("LLM交互测试完成。")
