extends MarginContainer

@onready var tags := $tagVBox/tagScroll/tagBox
@onready var addTagButton := $addMargin/addTagButton
@onready var loadOptionsButton := $tagVBox/loadOptionsButton
@onready var optionsPanel := $tagVBox/optionsPanel

@onready var optionsDropdown := $tagVBox/optionsPanel/optionsMargins/optionsVbox/optionsDropdown
@onready var ascendingButton := $tagVBox/optionsPanel/optionsMargins/optionsVbox/orderMargins/orderHbox/ascending
@onready var descendingButton := $tagVBox/optionsPanel/optionsMargins/optionsVbox/orderMargins/orderHbox/descending
@onready var totalTagsLabel := $tagVBox/optionsPanel/optionsMargins/optionsVbox/tagsVbox/totalTagsLabel

@onready var tagPanel = preload("res://scenes/tag_panel.tscn")

var options_open := false
var sorting_option = 0
var ascending := true
signal view_tag(tag_id)

func _ready() -> void:
	loadOptionsButton.pressed.connect(toggleOptionsPanel)
	optionsDropdown.item_selected.connect(changeSorting)
	ascendingButton.pressed.connect(sortAscending)
	descendingButton.pressed.connect(sortDescending)
	
func loadMenu():
	closeOptionsPanel()
	clearTags()
	loadTags(sorting_option, ascending)
	totalTagsLabel.text = DataHandler.getTotalTags()
	visible = true
	
func closeMenu():
	clearTags()
	visible = false

func loadTags(sort, asc=true):
	clearTags()
	var tag_list = []
	match sort:
		0: #last updated
			tag_list = DataHandler.tag_data.keys()
		1: #date added
			tag_list = DataHandler.getTagsByDate()
		2: #name
			tag_list = DataHandler.getTagsByName()
		3: #number of items
			tag_list = DataHandler.getTagsByNumItems()
	if not asc: tag_list.reverse()
	for tag in tag_list:
		if tag == "No Tag": continue
		var new_tag = tagPanel.instantiate()
		tags.add_child(new_tag)
		new_tag.loadTag(DataHandler.tag_data[tag])
		new_tag.tag_pressed.connect(viewTag)
		
func clearTags():
	for tag in tags.get_children():
		tag.queue_free()

func viewTag(tag_id):
	emit_signal("view_tag", tag_id)

func openOptionsPanel():
	options_open = true
	optionsPanel.visible = true
	loadOptionsButton.flip_v = true
	addTagButton.visible = false

func closeOptionsPanel():
	options_open = false
	optionsPanel.visible = false
	loadOptionsButton.flip_v = false
	addTagButton.visible = true
	
func toggleOptionsPanel():
	if options_open: closeOptionsPanel()
	else: openOptionsPanel()

func changeSorting(sort_id):
	if sorting_option == sort_id: return
	sorting_option = sort_id
	loadTags(sorting_option, ascending)

func sortAscending():
	if ascending: return
	ascending = true
	toggleAscendingButtons()
	loadTags(sorting_option, ascending)

func sortDescending():
	if not ascending: return
	ascending = false
	toggleAscendingButtons()
	loadTags(sorting_option, ascending)
	
func toggleAscendingButtons():
	if ascending:
		ascendingButton.modulate = Color("6d8577")
		descendingButton.modulate = Color("ecdfbf")
	else:
		ascendingButton.modulate = Color("ecdfbf")
		descendingButton.modulate = Color("6d8577")
