extends Spell

class_name BlinkSpell

@export var distance: float;

func cast(caster: Node3D):
	var direction = caster.global_transform.basis.z;
	caster.global_position += direction*5;
