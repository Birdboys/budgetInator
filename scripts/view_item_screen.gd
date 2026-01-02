extends MarginContainer

@onready var nameEntry := $viewVbox/dataMargin/dataVbox/nameHbox/nameData
@onready var priceEntry := $viewVbox/dataMargin/dataVbox/priceHbox/priceData
@onready var tagOptions := $viewVbox/dataMargin/dataVbox/tagOptions
@onready var tagRect := $viewVbox/dataMargin/dataVbox/tagOptions/tagRect
@onready var linkEntry := $viewVbox/dataMargin/dataVbox/linkHbox/linkData
@onready var linkButton := $viewVbox/dataMargin/dataVbox/linkHbox/linkLabel/linkButton
@onready var linkLabel := $viewVbox/dataMargin/dataVbox/linkHbox/linkLabel

@onready var timeLabel := $viewVbox/dataMargin/dataVbox/timeLabel
@onready var timeButton := $viewVbox/dataMargin/dataVbox/timeLabel/timeButton

@onready var updateButton := $viewVbox/bottomButtons/updateButton
@onready var purchaseButton := $viewVbox/bottomButtons/purchaseButton
@onready var backButton := $viewVbox/bottomButtons/backButton
@onready var resetButton := $viewVbox/dataMargin/dataVbox/viewButtons/resetButton
@onready var resetSpacer := $viewVbox/dataMargin/dataVbox/viewButtons/resetSpacer
@onready var trashButton := $viewVbox/dataMargin/dataVbox/viewButtons/trashButton
var original_item_data := {}
var changes_made := false
var showing_date := true
var one_week_in_cart := false
var is_unique := true
signal exit

func _ready() -> void:
	nameEntry.text_changed.connect(dataUpdated)
	priceEntry.text_changed.connect(dataUpdated)
	linkEntry.text_changed.connect(dataUpdated)
	tagOptions.item_selected.connect(tagUpdated)
	
	linkButton.pressed.connect(linkPressed)
	updateButton.pressed.connect(updatePressed)
	purchaseButton.pressed.connect(purchasePressed)
	backButton.pressed.connect(backPressed)
	resetButton.pressed.connect(resetData)
	trashButton.pressed.connect(trashPressed)
	timeButton.pressed.connect(toggleTimeLabel)
	pass

func tagUpdated(tag_id):
	var tag_name = tagOptions.get_item_text(tag_id)
	tagRect.modulate = DataHandler.tag_data[tag_name]['tag_color']
	if tag_name == "No Tag":
		changeTagSelectColor(Color.html("ecdfbf"))
	else:
		changeTagSelectColor(Color.html("2e3334"))
	dataUpdated("")
	
func dataUpdated(_text):
	if original_item_data == {}: 
		changes_made = false
		togglePurchaseUpdate(true)
		return
	is_unique = not DataHandler.checkDuplicateItem(nameEntry.text, original_item_data['item_name'])
	if nameEntry.text != original_item_data['item_name']: 
		changes_made = true
	elif priceEntry.text != original_item_data['item_price']:
		changes_made = true
	elif linkEntry.text != original_item_data['item_link']:
		changes_made = true
	elif tagOptions.get_item_text(tagOptions.get_selected_id()) != original_item_data['item_tag']:
		changes_made = true
	else:
		changes_made = false
	if changes_made:
		togglePurchaseUpdate(false)
	else:
		togglePurchaseUpdate(true)
	
	var link_valid = await validateLink(linkEntry.text)
	print("LINK VALID: ", link_valid)
	linkButton.disabled = not link_valid
	linkLabel.add_theme_color_override("font_color", Color("6d8577") if link_valid else Color("2e3334"))
	

func loadMenu():
	visible = true
	togglePurchaseUpdate(true)
	loadTags()

func closeMenu():
	visible = false
	clearText()
	
func loadTags():
	tagOptions.add_item("No Tag")
	for tag in DataHandler.tag_data:
		if DataHandler.tag_data[tag]["tag_name"] != "No Tag":
			tagOptions.add_item(DataHandler.tag_data[tag]["tag_name"])
	tagOptions.select(0)
	changeTagSelectColor(Color.html("ecdfbf"))

func clearText():
	nameEntry.clear()
	priceEntry.clear()
	linkEntry.clear()
	#timeLabel.clear()
	tagOptions.clear()
	tagRect.modulate = Color.TRANSPARENT
	original_item_data = {}
	changes_made = false
	dataUpdated("")

func changeTagSelectColor(c):
	tagOptions.add_theme_color_override("font_color", c)
	tagOptions.add_theme_color_override("font_focus_color", c)
	tagOptions.add_theme_color_override("font_hover_color", c)
	tagOptions.add_theme_color_override("font_pressed_color", c)
	tagOptions.add_theme_color_override("font_hover_pressed_color", c)

func loadItemData(item_id):
	original_item_data = DataHandler.item_data[item_id]
	nameEntry.text = original_item_data['item_name']
	priceEntry.text = original_item_data['item_price']
	linkEntry.text = original_item_data['item_link']
	for tag in range(tagOptions.item_count):
		if tagOptions.get_item_text(tag) == original_item_data['item_tag']:
			tagUpdated(tag)
			tagOptions.select(tag)
	loadTimeSince()
	changes_made = false
	togglePurchaseUpdate(true)
	#changeUpdateButton()
	
func backPressed():
	emit_signal("exit")

func updatePressed():
	if not priceEntry.text.is_valid_int():
		WarningMenu.loadMenu("Price must be valid number")
		return
	YesOrNo.loadMenu()
	var make_choice = await YesOrNo.choice
	print("MAKE CHOICE ", make_choice)
	if not make_choice: return
	updateData()

func updateData():
	var updated_item_data := {}
	updated_item_data['item_name'] = nameEntry.text
	updated_item_data['item_price'] = priceEntry.text
	updated_item_data['item_link'] = linkEntry.text
	updated_item_data['item_tag'] = tagOptions.text
	updated_item_data['item_date'] = original_item_data['item_date']
	DataHandler.updateItem(original_item_data['item_name'], updated_item_data)
	emit_signal("exit")
	
func purchasePressed():
	YesOrNo.loadMenu()
	var make_choice = await YesOrNo.choice
	print("MAKE CHOICE ", make_choice)
	if not make_choice: return
	purchaseItem()

func purchaseItem():
	var purchased_item_data = original_item_data.duplicate()
	purchased_item_data['purchase_date'] = Time.get_unix_time_from_system()
	DataHandler.deleteItem(purchased_item_data['item_name'])
	DataHandler.addPurchase(purchased_item_data)
	emit_signal("exit")
	
func togglePurchaseUpdate(purchase):
	purchaseButton.visible = purchase
	updateButton.visible = not purchase
	changePurchaseButton()
	changeUpdateButton()
	
func changeUpdateButton():
	if changes_made:
		resetButton.visible = true
		resetSpacer.visible = false
		updateButton.disabled = not (is_unique and priceEntry.text != "" and nameEntry.text != "")
	else:
		updateButton.disabled = true
		resetButton.visible = false
		resetSpacer.visible = true
		
func changePurchaseButton():
	if one_week_in_cart:
		purchaseButton.disabled = false
	else:
		purchaseButton.disabled = true
		
func resetData():
	loadItemData(original_item_data['item_name'])

func toggleTimeLabel():
	if showing_date: loadTimeSince()
	else: loadTimeAdded()
	
func loadTimeAdded():
	var date_time = Time.get_date_dict_from_unix_time(original_item_data['item_date'])
	if one_week_in_cart:
		timeLabel.text = "DATE ADDED\n[color=#6d8577]%s/%s/%s[/color]" % [date_time['month'], date_time['day'], date_time['year']]
	else:
		timeLabel.text = "DATE ADDED\n[color=#9c4827]%s/%s/%s[/color]" % [date_time['month'], date_time['day'], date_time['year']]
	showing_date = true
	
func loadTimeSince():
	var current_time = Time.get_unix_time_from_system() + DataHandler.time_zone_offset
	var added_time = original_item_data['item_date']
	var time_diff = current_time-added_time
	var days = floori(time_diff/86400.0)
	var hours = floori((time_diff-(days*86400.0))/3600.0)
	one_week_in_cart = days >= 7
	if one_week_in_cart:
		timeLabel.text = "TIME IN CART\n[color=#6d8577]%s Days - %s Hours[/color]" % [days, hours]
	else:
		timeLabel.text = "TIME IN CART\n[color=#9c4827]%s Days - %s Hours[/color]" % [days, hours]
	showing_date = false

func trashPressed():
	YesOrNo.loadMenu()
	var make_choice = await YesOrNo.choice
	print("MAKE CHOICE ", make_choice)
	if not make_choice: return
	deleteItem()

func deleteItem():
	DataHandler.deleteItem(original_item_data['item_name'])
	emit_signal("exit")

func linkPressed():
	YesOrNo.loadMenu()
	var make_choice = await YesOrNo.choice
	if not make_choice: return
	OS.shell_open(getFormattedLink(linkEntry.text))
	print("SHEES")

func validateLink(link:String):
	if link == "": return false
	link = getFormattedLink(link)
	var http_request = HTTPRequest.new()
	add_child(http_request)
	var error = http_request.request(link) 
	return error == OK

func getFormattedLink(link):
	if link.substr(0,8) != "https://":
		link = "https://" + link
	return link
