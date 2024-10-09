extends Node

var npc_name: String
var race: String = "Human"
var strength: int = 10
var intelligence: int = 10
var dexterity: int = 10
var charisma: int = 10
var constitution: int = 10
var perception: int = 10
var speed: int = 10

var health: int = 100
var mana: int = 50
var stamina: int = 50
var stress: int = 0

func init(_npc_name: String, _race: String, _strength: int, _intelligence: int, _dexterity: int, _charisma: int, _constitution: int, _perception: int):
    npc_name = _npc_name
    race = _race
    strength = _strength
    intelligence = _intelligence
    dexterity = _dexterity
    charisma = _charisma
    constitution = _constitution
    perception = _perception