extends Panel

@onready var nameLabel := $itemHBox/nameLabel
@onready var priceLabel := $itemHBox/priceLabel
@onready var tagRect := $itemHBox/tagRect

@onready var itemButton := $itemButton
var item_data 

signal item_pressed(id)

func _ready() -> void:
	itemButton.pressed.connect(itemPressed)
	
func loadItem(item):
	item_data = item
	nameLabel.text = item['item_name']
	priceLabel.text = "$%s" % item['item_price']
	var tag = item['item_tag']
	tagRect.modulate = DataHandler.tag_data[tag]['tag_color']
	
func itemPressed():
	#print(int(Time.get_unix_time_from_system())-item_data['item_date'])
	emit_signal("item_pressed", item_data['item_name'])
