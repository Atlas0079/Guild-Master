# 战场管理器-自动加载脚本

extends Node

class_name BattleManager

# 定义阵营
enum Camp {ADVENTURER, MONSTER}

# 定义位置
enum Position {FRONT_TOP, FRONT_MIDDLE, FRONT_BOTTOM, BACK_TOP, BACK_MIDDLE, BACK_BOTTOM}

# 战场结构
var battlefield = {
    Camp.ADVENTURER: {
        Position.FRONT_TOP: null,
        Position.FRONT_MIDDLE: null,
        Position.FRONT_BOTTOM: null,
        Position.BACK_TOP: null,
        Position.BACK_MIDDLE: null,
        Position.BACK_BOTTOM: null
    },
    Camp.MONSTER: {
        Position.FRONT_TOP: null,
        Position.FRONT_MIDDLE: null,
        Position.FRONT_BOTTOM: null,
        Position.BACK_TOP: null,
        Position.BACK_MIDDLE: null,
        Position.BACK_BOTTOM: null
    }
}



func initialize_battle(adventurer_team_id: String, monster_team_id: String):
    # 清空战场
    clear_battlefield()
    
    # 获取队伍数据
    var adventurer_team = TeamManager.get_team(adventurer_team_id, false)
    var monster_team = TeamManager.get_team(monster_team_id, true)
    
    # 放置冒险者
    place_team(adventurer_team, Camp.ADVENTURER)
    
    # 放置怪物
    place_team(monster_team, Camp.MONSTER)
    
    # 显示战场
    display_battlefield()

func clear_battlefield():
    for camp in battlefield.keys():
        for position in battlefield[camp].keys():
            battlefield[camp][position] = null

func place_team(team: Dictionary, camp: Camp):
    for member in team.positions.keys():
        var position = string_to_position(team.positions[member])
        if position != null:
            battlefield[camp][position] = member

func string_to_position(pos_string: String) -> int:
    match pos_string:
        "FRONT_TOP": return Position.FRONT_TOP
        "FRONT_MIDDLE": return Position.FRONT_MIDDLE
        "FRONT_BOTTOM": return Position.FRONT_BOTTOM
        "BACK_TOP": return Position.BACK_TOP
        "BACK_MIDDLE": return Position.BACK_MIDDLE
        "BACK_BOTTOM": return Position.BACK_BOTTOM
    return -1

func display_battlefield():
    print("战场状态:")
    for camp in battlefield.keys():
        var camp_name = "冒险者" if camp == Camp.ADVENTURER else "怪物"
        print("  %s阵营:" % camp_name)
        for position in battlefield[camp].keys():
            var character = battlefield[camp][position]
            var pos_name = Position.keys()[position]
            print("    %s: %s" % [pos_name, character if character else "空"])
    print("------------------------")

func start_battle(adventurer_team_id: String, monster_team_id: String):
    initialize_battle(adventurer_team_id, monster_team_id)
    # 接下来可以添加战斗逻辑
    pass