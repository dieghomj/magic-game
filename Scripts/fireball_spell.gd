extends Spell

class_name FireballSpell

@export var projectile_scene: PackedScene;
@export var damage: int = 10;
@export var speed: float = 2.0;

func cast(caster: Node3D):
	var p := projectile_scene.instantiate();
	p.position = caster.position;
	p.look_at(-caster.position);
	caster.get_tree().current_scene.add_child(p);
	pass
