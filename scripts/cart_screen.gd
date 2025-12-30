extends MarginContainer

@onready var cartItems := $cartVbox/cartScroll/cartBox
@onready var loadOptionsButton := $cartVbox/loadOptionsButton
@onready var optionsPanel := $cartVbox/optionsPanel
@onready var addItemButton := $addMargin/addItemButton
@onready var itemPanel = preload("res://scenes/item_panel.tscn")

@onready var optionsDropdown := $cartVbox/optionsPanel/optionsMargins/optionsVbox/optionsDropdown
@onready var ascendingButton := $cartVbox/optionsPanel/optionsMargins/optionsVbox/orderMargins/orderHbox/ascending
@onready var descendingButton := $cartVbox/optionsPanel/optionsMargins/optionsVbox/orderMargins/orderHbox/descending
@onready var totalItemsLabel := $cartVbox/optionsPanel/optionsMargins/optionsVbox/textHbox/itemsHbox/totalItemsLabel
@onready var totalPriceLabel := $cartVbox/optionsPanel/optionsMargins/optionsVbox/textHbox/priceHbox/totalPriceLabel

var options_open := false
var sorting_option = 0
var ascending := true
signal view_item(item_id)

func _ready() -> void:
	loadOptionsButton.pressed.connect(toggleOptionsPanel)
	optionsDropdown.item_selected.connect(changeSorting)
	ascendingButton.pressed.connect(sortAscending)
	descendingButton.pressed.connect(sortDescending)
	
func loadMenu():
	closeOptionsPanel()
	clearItems()
	loadItems(sorting_option, ascending)
	toggleAscendingButtons()
	totalItemsLabel.text = DataHandler.getTotalItems()
	totalPriceLabel.text = "$%s" % DataHandler.getTotalPrice()
	visible = true
	
func closeMenu():
	clearItems()
	visible = false

func loadItems(sort:=0, asc=true):
	clearItems()
	var items = []
	match sort:
		0: #last updated
			items = DataHandler.item_data.keys()
		1: #date added
			items = DataHandler.getItemsByDate()
		2: #price
			items = DataHandler.getItemsByPrice()
		3: #name
			items = DataHandler.getItemsByName()
		4: #tag
			items = DataHandler.getItemsByTag()
	if not asc: items.reverse()
	
	#for item in DataHandler.item_data:
	for item in items:
		var new_item = itemPanel.instantiate()
		cartItems.add_child(new_item)
		new_item.loadItem(DataHandler.item_data[item])
		new_item.item_pressed.connect(viewItem)
	DataHandler.getItemsByPrice()
	
func clearItems():
	for item in cartItems.get_children():
		item.queue_free()
		
func viewItem(item_id):
	emit_signal("view_item", item_id)

func openOptionsPanel():
	options_open = true
	optionsPanel.visible = true
	loadOptionsButton.flip_v = true
	addItemButton.visible = false

func closeOptionsPanel():
	options_open = false
	optionsPanel.visible = false
	loadOptionsButton.flip_v = false
	addItemButton.visible = true
	
func toggleOptionsPanel():
	if options_open: closeOptionsPanel()
	else: openOptionsPanel()

func changeSorting(sort_id):
	if sorting_option == sort_id: return
	sorting_option = sort_id
	loadItems(sorting_option, ascending)
	
func sortAscending():
	if ascending: return
	ascending = true
	toggleAscendingButtons()
	loadItems(sorting_option, ascending)

func sortDescending():
	if not ascending: return
	ascending = false
	toggleAscendingButtons()
	loadItems(sorting_option, ascending)
	
func toggleAscendingButtons():
	if ascending:
		ascendingButton.modulate = Color("6d8577")
		descendingButton.modulate = Color("ecdfbf")
	else:
		ascendingButton.modulate = Color("ecdfbf")
		descendingButton.modulate = Color("6d8577")
