extends MarginContainer

@onready var nameEntry := $viewVbox/dataMargin/dataVbox/nameData
@onready var colorEntry := $viewVbox/dataMargin/dataVbox/colorData
@onready var colorRect := $viewVbox/dataMargin/dataVbox/colorRect
@onready var updateButton := $viewVbox/bottomButtons/updateButton
@onready var backButton := $viewVbox/bottomButtons/backButton
@onready var randomButton := $viewVbox/dataMargin/dataVbox/randomButton
@onready var resetButton := $viewVbox/dataMargin/dataVbox/viewButtons/resetButton
@onready var trashButton := $viewVbox/dataMargin/dataVbox/viewButtons/trashButton

var original_tag_data := {}
var valid_color := false
var changes_made := false
var is_unique := true

signal exit

func _ready() -> void:
	nameEntry.text_changed.connect(dataUpdated)
	colorEntry.text_changed.connect(colorUpdated)
	
	randomButton.pressed.connect(getRandomColor)
	updateButton.pressed.connect(updatePressed)
	backButton.pressed.connect(backPressed)
	
	trashButton.pressed.connect(trashPressed)
	resetButton.pressed.connect(resetData)
	dataUpdated("")
	
func dataUpdated(_text):
	if original_tag_data == {}:
		changes_made = false
		updateButton.disabled = true
		return
	
	is_unique = not DataHandler.checkDuplicateTag(nameEntry.text, colorRect.modulate, original_tag_data['tag_name'], original_tag_data['tag_color'])
	if colorRect.modulate != original_tag_data['tag_color']:
		changes_made = true
	elif nameEntry.text != original_tag_data['tag_name']:
		changes_made = true
	else:
		changes_made = false
	
	resetButton.visible = changes_made
	updateButton.disabled = not (nameEntry.text != "" and valid_color and changes_made and is_unique)
	#submitButton.text = "SUBMIT ITEM" if (nameEntry.text != "" and valid_color) else "CANCEL"
	
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
	changes_made = false
	
func closeMenu():
	visible = false
	valid_color = false
	clearText()
	
func clearText():
	nameEntry.clear()
	colorEntry.clear()
	colorRect.modulate = Color.TRANSPARENT
	original_tag_data = {}
	dataUpdated("")

func loadTagData(tag_id):
	original_tag_data = DataHandler.tag_data[tag_id]
	colorRect.modulate = original_tag_data['tag_color']
	nameEntry.text = original_tag_data['tag_name']
	colorEntry.text = original_tag_data['tag_color'].to_html(false).to_upper()
	valid_color = true
	changes_made = false
	dataUpdated("")
	
func updatePressed():
	YesOrNo.loadMenu()
	var make_choice = await YesOrNo.choice
	print("MAKE CHOICE ", make_choice)
	if not make_choice: return
	updateData()

func updateData():
	var updated_tag_data := {}
	updated_tag_data['tag_name'] = nameEntry.text
	updated_tag_data['tag_color'] = colorRect.modulate
	DataHandler.updateTag(original_tag_data['tag_name'], updated_tag_data)
	emit_signal("exit")

func backPressed():
	emit_signal("exit")

func resetData():
	loadTagData(original_tag_data['tag_name'])

func trashPressed():
	YesOrNo.loadMenu()
	var make_choice = await YesOrNo.choice
	print("MAKE CHOICE ", make_choice)
	if not make_choice: return
	deleteTag()

func deleteTag():
	DataHandler.deleteTag(original_tag_data['tag_name'])
	emit_signal("exit")
