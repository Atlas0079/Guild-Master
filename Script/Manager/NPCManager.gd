# res://Script/Manager/NPCManager.gd
# AutoLoad

extends Node

func _ready():
	pass

func get_npc(npc_id):
	return DataManager.get_npc_data(npc_id)

func move_npc_to_place(npc_id, place_id):
	var npc_data = get_npc(npc_id)
	npc_data["location"] = place_id
	DataManager.save_character_data(npc_id, npc_data)

func npc_eat():
	pass

func npc_sleep():
	pass

func npc_talk_to(another_npc_id):
	pass

func npc_pick_up_item(item_id):
	pass

func npc_drop_item(item_id):
	pass

func trade_with_money(buyer_id, seller_id, item_id, price):
	var buyer = get_npc(buyer_id)
	var seller = get_npc(seller_id)
	
	if item_id in seller["inventory"] and buyer["money"] >= price:
		buyer["money"] -= price
		buyer["inventory"].append(item_id)
		
		seller["money"] += price
		seller["inventory"].erase(item_id)
		
		DataManager.save_character_data(buyer_id, buyer)
		DataManager.save_character_data(seller_id, seller)
		
		return true
	else:
		print("交易无法完成：物品不在卖家库存中或买家金钱不足")
		return false

#需要提前检查物品是否存在，还需要检查双方是否在同一地点
func npc_trade_with_item(trader_id, target_npc_id, wanted_item_id, offered_item_id):
	var trader_data = get_npc(trader_id)
	var target_npc_data = get_npc(target_npc_id)
	
	if offered_item_id in trader_data["inventory"] and wanted_item_id in target_npc_data["inventory"]:
		trader_data["inventory"].erase(offered_item_id)
		trader_data["inventory"].append(wanted_item_id)
		
		target_npc_data["inventory"].erase(wanted_item_id)
		target_npc_data["inventory"].append(offered_item_id)
		
		DataManager.save_character_data(trader_id, trader_data)
		DataManager.save_character_data(target_npc_id, target_npc_data)
	else:
		print("交易无法完成：物品不在库存中")

func equip_equipment_from_inventory(npc_id, equipment_type, item_id):
	var npc_data = get_npc(npc_id)
	if item_id in npc_data["inventory"]:
		var item = DataManager.get_item_data(item_id)
		if item["type"] == equipment_type:
			if equipment_type == "accessories":
				if npc_data["equipment"][equipment_type].size() < 3:
					npc_data["equipment"][equipment_type].append(item_id)
					npc_data["inventory"].erase(item_id)
				else:
					print("Cannot equip more than 3 accessories")
			else:
				var current_equipment = npc_data["equipment"].get(equipment_type, null)
				if current_equipment:
					npc_data["inventory"].append(current_equipment)
				npc_data["equipment"][equipment_type] = item_id
				npc_data["inventory"].erase(item_id)
			DataManager.save_character_data(npc_id, npc_data)
	else:
		print("Item not in inventory")
