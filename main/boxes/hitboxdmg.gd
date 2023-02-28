extends Area2D
export(float) var damage=1
export(float) var scale_damage=1
export(float,0,99)var wait_time=1
export(int)var command=0
onready var t=$Timer
func _ready():
	t.wait_time=wait_time
	#t.start(t.wait_time)

func _on_Timer_timeout():
	queue_free()
