extends Control

@onready var addItemScreen := $vBox/addItemScreen
@onready var cartScreen := $vBox/cartScreen
@onready var viewItemScreen := $vBox/viewItemScreen
@onready var addTagScreen := $vBox/addTagScreen
@onready var tagScreen := $vBox/tagScreen
@onready var viewTagScreen := $vBox/viewTagScreen
@onready var purchasedScreen := $vBox/purchasedScreen

@onready var cartButton := $vBox/bottomPanel/buttonHbox/cartButton
@onready var tagsButton := $vBox/bottomPanel/buttonHbox/tagsButton
@onready var purchasedButton := $vBox/bottomPanel/buttonHbox/purchasedButton
@onready var addItemButton := $vBox/cartScreen/addMargin/addItemButton
@onready var addTagButton := $vBox/tagScreen/addMargin/addTagButton
@onready var cartPanel := $vBox/bottomPanel/bgHbox/cartPanel
@onready var tagsPanel := $vBox/bottomPanel/bgHbox/tagsPanel
@onready var purchasedPanel := $vBox/bottomPanel/bgHbox/purchasedPanel

@onready var menus := {
	"add_item": addItemScreen,
	"cart": cartScreen,
	"tags": tagScreen,
	"add_tag": addTagScreen,
	"purchased": purchasedScreen,
	"view_item": viewItemScreen,
	"view_tag": viewTagScreen,
}
var current_screen := ""

func _ready() -> void:
	addItemScreen.exit.connect(toggleScreen.bind("cart"))
	addTagScreen.exit.connect(toggleScreen.bind("tags"))
	viewItemScreen.exit.connect(toggleScreen.bind("cart"))
	viewTagScreen.exit.connect(toggleScreen.bind("tags"))
	cartScreen.view_item.connect(viewItem)
	tagScreen.view_tag.connect(viewTag)
	
	addItemButton.pressed.connect(toggleScreen.bind("add_item"))
	addTagButton.pressed.connect(toggleScreen.bind("add_tag"))
	cartButton.pressed.connect(toggleScreen.bind("cart"))
	tagsButton.pressed.connect(toggleScreen.bind("tags"))
	purchasedButton.pressed.connect(toggleScreen.bind("purchased"))
	toggleScreen("cart")
	
func toggleScreen(screen:String):
	if screen == current_screen: return
	current_screen = screen
	for menu in menus:
		if screen == menu:
			menus[menu].loadMenu()
		else:
			menus[menu].closeMenu()

	updatePanels()
	
func updatePanels():
	cartPanel.theme_type_variation = "pressed" if current_screen == "cart" else "empty"
	tagsPanel.theme_type_variation = "pressed" if current_screen == "tags" else "empty"
	purchasedPanel.theme_type_variation = "pressed" if current_screen == "purchased" else "empty"

	cartButton.modulate = Color("6d8577") if current_screen == "cart" else Color("2e3334")
	tagsButton.modulate = Color("6d8577") if current_screen == "tags" else Color("2e3334")
	purchasedButton.modulate = Color("6d8577") if current_screen == "purchased" else Color("2e3334")

func viewItem(item_id):
	toggleScreen("view_item")
	viewItemScreen.loadItemData(item_id)

func viewTag(tag_id):
	toggleScreen("view_tag")
	viewTagScreen.loadTagData(tag_id)
