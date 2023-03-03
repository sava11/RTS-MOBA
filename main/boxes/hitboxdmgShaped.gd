extends Area2D
export(float) var damage=1
export(float) var scale_damage=1
export(int)var command=0
onready var t=$Timer
#var tpos=Vector2.ZERO
#var speed:float=100
#func _ready():
	#print(collision_layer)
	#print(collision_mask)
	#t.wait_time=fnc._sqrt(tpos-global_position)/(speed)
	#t.start(t.wait_time)

func _on_Timer_timeout():
	queue_free()
