extends MarginContainer

@onready var nameEntry := $addVbox/dataMargin/dataVbox/nameData
@onready var tagOptions := $addVbox/dataMargin/dataVbox/tagOptions
@onready var tagRect := $addVbox/dataMargin/dataVbox/tagOptions/tagRect
#@onready var colorEntry := $addVbox/dataMargin/dataVbox/colorData
#@onready var colorRect := $addVbox/dataMargin/dataVbox/colorRect
@onready var submitButton := $addVbox/bottomButtons/submitButton
@onready var cancelButton := $addVbox/bottomButtons/cancelButton
#@onready var randomButton := $addVbox/dataMargin/dataVbox/randomButton

var valid_color := false
var is_unique := true

signal exit

func _ready() -> void:
	nameEntry.text_changed.connect(dataUpdated)
	tagOptions.item_selected.connect(tagUpdated)
	submitButton.pressed.connect(submitItem)
	cancelButton.pressed.connect(cancel)
	dataUpdated("")
	
func dataUpdated(_text):
	toggleSubmitCancel(nameEntry.text != "")

func tagUpdated(tag_id):
	var tag_name = tagOptions.get_item_text(tag_id)
	tagRect.modulate = DataHandler.tag_data[tag_name]['tag_color']
	if tag_name == "No Tag":
		changeTagSelectColor(Color.html("ecdfbf"))
	else:
		changeTagSelectColor(Color.html("2e3334"))
		
func submitItem():
	if nameEntry.text == "":
		WarningMenu.loadMenu("Vice name can't be empty")
		return
	if DataHandler.checkDuplicateVice(nameEntry.text):
		WarningMenu.loadMenu("Name must be unique")
		return
	
	var new_vice = {}
	new_vice['vice_name'] = nameEntry.text
	new_vice['vice_tag'] = tagOptions.text
	new_vice['vice_date'] = int(Time.get_unix_time_from_system()) + DataHandler.time_zone_offset
	new_vice['vice_purchases'] = []
	DataHandler.addVice(new_vice)
	emit_signal("exit")
	#var new_tag = {}
	#new_tag['tag_name'] = nameEntry.text
	#new_tag['tag_color'] = colorRect.modulate
	#new_tag['tag_date'] = int(Time.get_unix_time_from_system()) + DataHandler.time_zone_offset
	#DataHandler.addTag(new_tag)
	#emit_signal("exit")

func loadTags():
	tagOptions.add_item("No Tag")
	for tag in DataHandler.tag_data:
		if DataHandler.tag_data[tag]["tag_name"] != "No Tag":
			tagOptions.add_item(DataHandler.tag_data[tag]["tag_name"])
	tagOptions.select(0)
	changeTagSelectColor(Color.html("ecdfbf"))
	
func changeTagSelectColor(c):
	tagOptions.add_theme_color_override("font_color", c)
	tagOptions.add_theme_color_override("font_focus_color", c)
	tagOptions.add_theme_color_override("font_hover_color", c)
	tagOptions.add_theme_color_override("font_pressed_color", c)
	tagOptions.add_theme_color_override("font_hover_pressed_color", c)
	
func cancel():
	emit_signal("exit")

func toggleSubmitCancel(submit):
	submitButton.visible = submit
	cancelButton.visible = not submit
	
func loadMenu():
	visible = true
	valid_color = false
	clearText()
	loadTags()

func closeMenu():
	visible = false
	valid_color = false
	clearText()
	
func clearText():
	nameEntry.clear()
	tagOptions.clear()
	tagRect.modulate = Color.TRANSPARENT
	dataUpdated("")
