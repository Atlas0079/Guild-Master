# script/NPC/NPCTraitsStates.gd
extends Node

var traits: Dictionary = {}
var states: Dictionary = {}

func add_trait(trait_name: String, effects: Dictionary):
    # 实现添加特质的逻辑
    pass

func remove_trait(trait_name: String):
    # 实现移除特质的逻辑
    pass

func add_state(state_name: String, effects: Dictionary, duration: int):
    # 实现添加状态的逻辑
    pass

func update_states():
    # 实现更新状态的逻辑
    pass

func apply_effects():
    # 实现应用特质和状态效果的逻辑
    pass