extends Area2D
export var tspeed=1
onready var t=$Timer
var invi=false setget set_invi
signal invi_started
signal invi_ended
func _ready():
	$Timer.wait_time=tspeed
func set_invi(v):
	invi=v
	if invi==true:
		emit_signal("invi_started")
	else:
		emit_signal("invi_ended")
func start_invi(dir):
	self.invi=true
	t.start(dir)
func _on_Timer_timeout():
	self.invi=false

func _on_hurt_box_invi_ended():
	set_deferred("monitorable",true)
	set_deferred("monitoring",true)


func _on_hurt_box_invi_started():
	set_deferred("monitorable",false)
	set_deferred("monitoring",false)
