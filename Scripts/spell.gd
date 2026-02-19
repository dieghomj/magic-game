extends Resource
class_name Spell

@export var name: String = "Generic Spell";
@export var mana_cost: int = 1.0;
@export var cooldown: float = 1.0;

func cast(caster: Node3D):
	pass;
