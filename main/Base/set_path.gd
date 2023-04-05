extends Line2D
var battle_path=PoolVector2Array([])
func _ready():
	battle_path=fnc.to_glb_PV_and_rot(points,global_position,global_rotation_degrees)
	print(battle_path)
	hide()
	
