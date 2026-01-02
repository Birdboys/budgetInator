extends MarginContainer

@onready var nameEntry := $addVbox/dataMargin/dataVbox/nameData
@onready var priceEntry := $addVbox/dataMargin/dataVbox/priceData
@onready var tagOptions := $addVbox/dataMargin/dataVbox/tagOptions
@onready var tagRect := $addVbox/dataMargin/dataVbox/tagOptions/tagRect
@onready var linkEntry := $addVbox/dataMargin/dataVbox/linkData
@onready var submitButton := $addVbox/bottomButtons/submitButton
@onready var cancelButton := $addVbox/bottomButtons/cancelButton

var is_unique := true

signal exit

func _ready() -> void:
	nameEntry.text_changed.connect(dataUpdated)
	priceEntry.text_changed.connect(dataUpdated)
	linkEntry.text_changed.connect(dataUpdated)
	tagOptions.item_selected.connect(tagUpdated)
	submitButton.pressed.connect(submitItem)
	cancelButton.pressed.connect(cancel)
	dataUpdated("")

func tagUpdated(tag_id):
	var tag_name = tagOptions.get_item_text(tag_id)
	tagRect.modulate = DataHandler.tag_data[tag_name]['tag_color']
	if tag_name == "No Tag":
		changeTagSelectColor(Color.html("ecdfbf"))
	else:
		changeTagSelectColor(Color.html("2e3334"))
		
func dataUpdated(_text):
	toggleSubmitCancel(nameEntry.text != "" and priceEntry.text != "")
	#is_unique = DataHandler.checkDuplicateItem(nameEntry.text)
	#submitButton.theme_type_variation = "submitButton" if (nameEntry.text != "" and priceEntry.text != "" and is_unique) else "cancelButton"
	#submitButton.text = "SUBMIT ITEM" if (nameEntry.text != "" and priceEntry.text != "" and is_unique) else "CANCEL"
	
func submitItem():
	if DataHandler.checkDuplicateItem(nameEntry.text):
		WarningMenu.loadMenu("Item already exists")
		return
	if not priceEntry.text.is_valid_int():
		WarningMenu.loadMenu("Price must be valid number")
		return
	
	var new_item = {}
	new_item['item_name'] = nameEntry.text
	new_item['item_price'] = priceEntry.text
	new_item['item_link'] = linkEntry.text
	new_item['item_tag'] = tagOptions.text
	new_item['item_date'] = int(Time.get_unix_time_from_system())
	DataHandler.addItem(new_item)
	emit_signal("exit")

func cancel():
	emit_signal("exit")

func toggleSubmitCancel(submit):
	submitButton.visible = submit
	cancelButton.visible = not submit
	
func loadMenu():
	visible = true
	toggleSubmitCancel(false)
	clearText()
	loadTags()
	print(DataHandler.tag_data)

func closeMenu():
	visible = false
	clearText()
	
func loadTags():
	for tag in DataHandler.tag_data:
		tagOptions.add_item(DataHandler.tag_data[tag]["tag_name"])
	tagOptions.select(0)
	changeTagSelectColor(Color.html("ecdfbf"))

func clearText():
	nameEntry.clear()
	priceEntry.clear()
	linkEntry.clear()
	tagOptions.clear()
	tagRect.modulate = Color.TRANSPARENT
	dataUpdated("")

func changeTagSelectColor(c):
	tagOptions.add_theme_color_override("font_color", c)
	tagOptions.add_theme_color_override("font_focus_color", c)
	tagOptions.add_theme_color_override("font_hover_color", c)
	tagOptions.add_theme_color_override("font_pressed_color", c)
	tagOptions.add_theme_color_override("font_hover_pressed_color", c)

func checkDuplicate():
	return DataHandler.checkDuplicateItem(nameEntry.text)
