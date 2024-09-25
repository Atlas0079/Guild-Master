# llm.gd
extends Node

const API_URL = "https://your-third-party-api-url.com/v1/chat/completions"
const API_KEY = "your-api-key-here"

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
        "model": "gpt-3.5-turbo",
        "messages": [{"role": "user", "content": user_message}]
    })
    
    var error = http_request.request(API_URL, headers, HTTPClient.METHOD_POST, body)
    if error != OK:
        push_error("HTTP请求发生错误。")
        return
    
    await http_request.request_completed
    callback.call()

func _on_request_completed(result, response_code, headers, body):
    var json = JSON.parse_string(body.get_string_from_utf8())
    if json != null:
        if "choices" in json and json.choices.size() > 0:
            var llm_response = json.choices[0].message.content
            print("LLM响应：", llm_response)
    else:
        push_error("JSON解析错误")

# 测试函数
func test_llm_interaction():
    print("正在发送测试消息到LLM...")
    send_message("你好，能给我讲个短笑话吗？", Callable(self, "on_test_response"))

func on_test_response():
    print("LLM交互测试完成。")