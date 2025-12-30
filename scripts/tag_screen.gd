extends MarginContainer

@onready var tags := $tagVBox/tagScroll/tagBox
@onready var tagPanel = preload("res://scenes/tag_panel.tscn")

signal view_tag(tag_id)

func loadMenu():
	clearTags()
	loadTags()
	visible = true
	
func closeMenu():
	clearTags()
	visible = false

func loadTags():
	for tag in DataHandler.tag_data:
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
