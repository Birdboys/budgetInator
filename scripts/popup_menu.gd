extends CanvasLayer

@onready var yesButton := $popupPanel/popupMargin/popupVbox/popupButtons/yesButton
@onready var noButton := $popupPanel/popupMargin/popupVbox/popupButtons/noButton

signal choice(c)

func _ready() -> void:
	yesButton.pressed.connect(yes)
	noButton.pressed.connect(no)
	closeMenu()

func yes():
	emit_signal("choice", true)
	closeMenu()

func no():
	emit_signal("choice", false)
	closeMenu()
	
func loadMenu():
	visible = true

func closeMenu():
	visible = false
