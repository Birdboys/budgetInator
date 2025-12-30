extends MarginContainer

@onready var nameEntry := $addVbox/dataMargin/dataVbox/nameData
@onready var colorEntry := $addVbox/dataMargin/dataVbox/colorData
@onready var colorRect := $addVbox/dataMargin/dataVbox/colorRect
@onready var submitButton := $addVbox/submitButton
@onready var randomButton := $addVbox/dataMargin/dataVbox/randomButton

var valid_color := false
var is_unique := true

signal exit

func _ready() -> void:
	nameEntry.text_changed.connect(dataUpdated)
	colorEntry.text_changed.connect(colorUpdated)
	
	randomButton.pressed.connect(getRandomColor)
	submitButton.pressed.connect(submitItem)
	dataUpdated("")
	
func dataUpdated(_text):
	is_unique = DataHandler.checkDuplicateTag(nameEntry.text, colorRect.modulate)
	submitButton.theme_type_variation = "submitButton" if (nameEntry.text != "" and valid_color and is_unique) else "cancelButton"
	submitButton.text = "SUBMIT ITEM" if (nameEntry.text != "" and valid_color and is_unique) else "CANCEL"
	
func colorUpdated(color: String):
	if color.substr(0,1) == "#": color = color.substr(1)
	if color.substr(0,2) == "0x": color = color.substr(2)
	if color.is_valid_html_color():
		colorRect.modulate = Color(color)
		valid_color = true
		dataUpdated("")
	else:
		colorRect.modulate = Color(0.0, 0.0, 0.0, 0.0)
		valid_color = false

func getRandomColor():
	var new_color_int := randi() % 16777215
	var new_color_hex = "%06X" % new_color_int
	colorEntry.text = new_color_hex
	colorUpdated(new_color_hex)
	
func submitItem():
	if (nameEntry.text != "" and valid_color == true):
		var new_tag = {}
		new_tag['tag_name'] = nameEntry.text
		new_tag['tag_color'] = colorRect.modulate
		DataHandler.addTag(new_tag)
	emit_signal("exit")

func loadMenu():
	visible = true
	valid_color = false
	clearText()

func closeMenu():
	visible = false
	valid_color = false
	clearText()
	
func clearText():
	nameEntry.clear()
	colorEntry.clear()
	colorRect.modulate = Color.TRANSPARENT
	dataUpdated("")
