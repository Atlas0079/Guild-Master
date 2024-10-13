# LLM.gd
extends Node

const API_URL = "https://35.aigcbest.top/v1/chat/completions"
const API_KEY = "sk-BIBKYxlMfEJLwFMi89Cc39D72a434760A326501f171987Fc"

var http_request: HTTPRequest

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

func send_message(user_message: String):
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

func _on_request_completed(_result, response_code: int, _headers, body: PackedByteArray):
	if response_code != 200:
		push_error("HTTP请求失败。状态码：" + str(response_code))
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if json != null:
		if "choices" in json and json.choices.size() > 0:
			var llm_response = json.choices[0].message.content
			print("LLM响应：", llm_response)
			response_received.emit(llm_response)
		else:
			push_error("LLM响应格式不正确")
	else:
		push_error("JSON解析错误")

signal response_received(response: String)

func get_memory_embedding(memory_content: String) -> Array:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + API_KEY
	]
	var body = JSON.stringify({
		"model": "text-embedding-ada-002",
		"input": memory_content
	})
	
	var error = http_request.request("https://35.aigcbest.top/v1/embeddings", headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("获取嵌入向量时发生错误。")
		return []
	
	var result = await http_request.request_completed
	var response_code = result[1]
	var response_body = result[3]
	
	if response_code != 200:
		push_error("获取嵌入向量失败。状态码：" + str(response_code))
		return []

	var json = JSON.parse_string(response_body.get_string_from_utf8())
	if json != null and "data" in json and json.data.size() > 0:
		return json.data[0].embedding
	else:
		push_error("解析嵌入向量响应时出错")
		return []