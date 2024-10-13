# Script/NPC/NPCMemory.gd
extends Node

var relationships: Dictionary = {}
var memories: Array = []

class Memory:
    var creation_time: String
    var recall_time: String
    var content: String
    var embedding: Array
    var importance: float

    func _init(c_time: String, content_param: String, embedding_param: Array, importance_param: float):
        self.creation_time = c_time
        self.recall_time = c_time  # 初始时,召回时间等于创建时间
        self.content = content_param
        self.embedding = embedding_param
        self.importance = importance_param

func add_memory(content_param: String, embedding_param: Array, importance_param: float):
    var current_time = TimeManager.get_formatted_time()
    var new_memory = Memory.new(current_time, content_param, embedding_param, importance_param)
    memories.append(new_memory)

func update_recall_time(memory: Memory):
    memory.recall_time = TimeManager.get_formatted_time()

func get_memories_by_importance(threshold: float) -> Array:
    return memories.filter(func(memory): return memory.importance >= threshold)

func update_relationship(npc_name: String, value: int):
    if npc_name in relationships:
        relationships[npc_name] += value
    else:
        relationships[npc_name] = value

func get_relationship(npc_name: String) -> int:
    return relationships.get(npc_name, 0)