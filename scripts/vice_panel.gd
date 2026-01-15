extends Panel

@onready var nameLabel := $viceHbox/nameLabel
@onready var countLabel := $viceHbox/countLabel
@onready var tagRect := $viceHbox/tagRect

@onready var viceButton := $viceButton

var vice_data 

signal vice_pressed(id)

func _ready() -> void:
	viceButton.pressed.connect(vicePressed)

func loadVice(vice):
	vice_data = vice
	nameLabel.text = vice['vice_name']
	tagRect.modulate = DataHandler.tag_data[vice['vice_tag']]['tag_color']
	pass
	
func vicePressed():
	emit_signal("vice_pressed", vice_data['vice_name'])
