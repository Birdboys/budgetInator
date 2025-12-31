extends MarginContainer

@onready var purchasedItems := $purchVbox/purchScroll/purchBox
@onready var loadOptionsButton := $purchVbox/loadOptionsButton
@onready var optionsPanel := $purchVbox/optionsPanel
@onready var itemPanel = preload("res://scenes/item_panel.tscn")

@onready var optionsDropdown := $purchVbox/optionsPanel/optionsMargins/optionsVbox/optionsDropdown
@onready var ascendingButton := $purchVbox/optionsPanel/optionsMargins/optionsVbox/orderMargins/orderHbox/ascending
@onready var descendingButton := $purchVbox/optionsPanel/optionsMargins/optionsVbox/orderMargins/orderHbox/descending
@onready var totalItemsLabel := $purchVbox/optionsPanel/optionsMargins/optionsVbox/textHbox/itemsHbox/totalItemsLabel
@onready var totalPriceLabel := $purchVbox/optionsPanel/optionsMargins/optionsVbox/textHbox/priceHbox/totalPriceLabel
@onready var resetDataButton := $purchVbox/optionsPanel/optionsMargins/optionsVbox/resetButton

var options_open := false
var sorting_option = 0
var ascending := true
signal view_item(item_id)

func _ready() -> void:
	loadOptionsButton.pressed.connect(toggleOptionsPanel)
	optionsDropdown.item_selected.connect(changeSorting)
	ascendingButton.pressed.connect(sortAscending)
	descendingButton.pressed.connect(sortDescending)
	resetDataButton.pressed.connect(resetPressed)
	
func loadMenu():
	closeOptionsPanel()
	clearItems()
	loadItems(sorting_option, ascending)
	toggleAscendingButtons()
	totalItemsLabel.text = DataHandler.getTotalPurchases()
	totalPriceLabel.text = "$%s" % DataHandler.getTotalPurchasePrice()
	visible = true
	
func closeMenu():
	clearItems()
	visible = false

func loadItems(sort:=0, asc=true):
	clearItems()
	var items = []
	match sort:
		0: #date purchased
			items = DataHandler.getPurchasesByPurchaseDate()
		1: #date added
			items = DataHandler.getPurchasesByDate()
		2: #price
			items = DataHandler.getPurchasesByPrice()
		3: #name
			items = DataHandler.getPurchasesByName()
		4: #tag
			items = DataHandler.getPurchasesByTag()
	if not asc: items.reverse()
	
	for item in items:
		var new_item = itemPanel.instantiate()
		purchasedItems.add_child(new_item)
		new_item.loadItem(DataHandler.purchase_data[item])
		new_item.item_pressed.connect(viewItem)
	DataHandler.getItemsByPrice()
	
func clearItems():
	for item in purchasedItems.get_children():
		item.queue_free()
		
func viewItem(item_id):
	emit_signal("view_item", item_id)

func openOptionsPanel():
	options_open = true
	optionsPanel.visible = true
	loadOptionsButton.flip_v = true

func closeOptionsPanel():
	options_open = false
	optionsPanel.visible = false
	loadOptionsButton.flip_v = false
	
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

func resetPressed():
	YesOrNo.loadMenu()
	var make_choice = await YesOrNo.choice
	if not make_choice: return
	DataHandler.resetAllData()
	loadMenu()
