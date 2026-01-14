extends MarginContainer

@onready var vices := $viceVBox/vicesScroll/vicesBox
@onready var addViceButton := $addMargin/addViceButton
@onready var loadOptionsButton := $viceVBox/loadOptionsButton
@onready var optionsPanel := $viceVBox/optionsPanel

@onready var optionsDropdown := $viceVBox/optionsPanel/optionsMargins/optionsVbox/optionsDropdown
@onready var ascendingButton := $viceVBox/optionsPanel/optionsMargins/optionsVbox/orderMargins/orderHbox/ascending
@onready var descendingButton := $viceVBox/optionsPanel/optionsMargins/optionsVbox/orderMargins/orderHbox/descending

@onready var tagPanel = preload("res://scenes/tag_panel.tscn")

var options_open := false
var sorting_option = 0
var ascending := true

signal view_vice(vice_id)

func _ready() -> void:
	loadOptionsButton.pressed.connect(toggleOptionsPanel)
	#optionsDropdown.item_selected.connect(changeSorting)
	#ascendingButton.pressed.connect(sortAscending)
	#descendingButton.pressed.connect(sortDescending)
	
func loadMenu():
	closeOptionsPanel()
	#clearTags()
	#loadTags(sorting_option, ascending)
	#totalTagsLabel.text = DataHandler.getTotalTags()
	visible = true
	
func closeMenu():
	clearVices()
	visible = false

func loadTags(sort, asc=true):
	pass
	#clearTags()
	#var tag_list = []
	#match sort:
		#0: #last updated
			#tag_list = DataHandler.tag_data.keys()
		#1: #date added
			#tag_list = DataHandler.getTagsByDate()
		#2: #name
			#tag_list = DataHandler.getTagsByName()
		#3: #number of items
			#tag_list = DataHandler.getTagsByNumItems()
	#if not asc: tag_list.reverse()
	#for tag in tag_list:
		#if tag == "No Tag": continue
		#var new_tag = tagPanel.instantiate()
		##tags.add_child(new_tag)
		#new_tag.loadTag(DataHandler.tag_data[tag])
		##new_tag.tag_pressed.connect(viewTag)
		
func clearVices():
	for vice in vices.get_children():
		vice.queue_free()

func viewVice(vice_id):
	emit_signal("view_vice", vice_id)
	

func openOptionsPanel():
	options_open = true
	optionsPanel.visible = true
	loadOptionsButton.flip_v = true
	addViceButton.visible = false

func closeOptionsPanel():
	options_open = false
	optionsPanel.visible = false
	loadOptionsButton.flip_v = false
	addViceButton.visible = true
	
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
