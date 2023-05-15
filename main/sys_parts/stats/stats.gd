extends Node
export(float) var m_he=1 setget s_m_h
var he=m_he setget set_he
signal no_he
signal h_ch(v)
signal m_h_ch(v)
func s_m_h(v):
	m_he=v
	self.he=min(he,m_he)
	emit_signal("m_h_ch",m_he)
func set_he(value):
	he=value
	emit_signal("h_ch",he)
	if he<=0:
		emit_signal("no_he")
func _ready():
	self.he=m_he
