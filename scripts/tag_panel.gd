extends Panel

@onready var nameLabel := $tagHbox/nameLabel
@onready var countLabel := $tagHbox/countLabel
@onready var tagRect := $tagHbox/tagRect

@onready var tagButton := $tagButton
var tag_data 

signal tag_pressed(id)

func _ready() -> void:
	tagButton.pressed.connect(tagPressed)
	
func loadTag(tag):
	tag_data = tag
	nameLabel.text = tag['tag_name']
	tagRect.modulate = tag["tag_color"]
	var item_count = DataHandler.getCountItemsWithTag(tag['tag_name'])
	countLabel.text = "%s" % item_count if item_count > 0 else ""

func tagPressed():
	emit_signal("tag_pressed", tag_data['tag_name'])
