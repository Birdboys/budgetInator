extends CanvasLayer

@onready var yesButton := $popupPanel/popupMargin/popupVbox/popupButtons/yesButton
@onready var warningLabel := $popupPanel/popupMargin/popupVbox/warningLabel

signal exit

func _ready() -> void:
	yesButton.pressed.connect(yes)
	closeMenu()

func yes():
	emit_signal("exit")
	closeMenu()
	
func loadMenu(warning_text):
	warningLabel.text = warning_text
	visible = true

func closeMenu():
	visible = false
