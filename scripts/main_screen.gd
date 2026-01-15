extends Control

@onready var addItemScreen := $vBox/addItemScreen
@onready var cartScreen := $vBox/cartScreen
@onready var viewItemScreen := $vBox/viewItemScreen
@onready var addTagScreen := $vBox/addTagScreen
@onready var tagScreen := $vBox/tagScreen
@onready var viewTagScreen := $vBox/viewTagScreen
@onready var purchasedScreen := $vBox/purchasedScreen
@onready var viewPurchaseScreen := $vBox/viewPurchaseScreen
@onready var addViceScreen := $vBox/addViceScreen
@onready var vicesScreen := $vBox/vicesScreen

@onready var cartButton := $vBox/bottomPanel/buttonHbox/cartButton
@onready var tagsButton := $vBox/bottomPanel/buttonHbox/tagsButton
@onready var purchasedButton := $vBox/bottomPanel/buttonHbox/purchasedButton
@onready var vicesButton := $vBox/bottomPanel/buttonHbox/vicesButton
@onready var addItemButton := $vBox/cartScreen/addMargin/addItemButton
@onready var addTagButton := $vBox/tagScreen/addMargin/addTagButton
@onready var addViceButton := $vBox/vicesScreen/addMargin/addViceButton
@onready var cartPanel := $vBox/bottomPanel/bgHbox/cartPanel
@onready var tagsPanel := $vBox/bottomPanel/bgHbox/tagsPanel
@onready var purchasedPanel := $vBox/bottomPanel/bgHbox/purchasedPanel
@onready var vicesPanel := $vBox/bottomPanel/bgHbox/vicesPanel

@onready var menus := {
	"add_item": addItemScreen,
	"cart": cartScreen,
	"tags": tagScreen,
	"add_tag": addTagScreen,
	"purchased": purchasedScreen,
	"view_item": viewItemScreen,
	"view_tag": viewTagScreen,
	"view_purchase": viewPurchaseScreen,
	"vices": vicesScreen,
	"add_vice": addViceScreen
}
var current_screen := ""

func _ready() -> void:
	addItemScreen.exit.connect(toggleScreen.bind("cart"))
	addTagScreen.exit.connect(toggleScreen.bind("tags"))
	addViceScreen.exit.connect(toggleScreen.bind("vices"))
	viewItemScreen.exit.connect(toggleScreen.bind("cart"))
	viewTagScreen.exit.connect(toggleScreen.bind("tags"))
	viewPurchaseScreen.exit.connect(toggleScreen.bind("purchased"))
	cartScreen.view_item.connect(viewItem)
	tagScreen.view_tag.connect(viewTag)
	purchasedScreen.view_purchase.connect(viewPurchase)
	vicesScreen.view_vice.connect(viewVice)
	
	addItemButton.pressed.connect(toggleScreen.bind("add_item"))
	addTagButton.pressed.connect(toggleScreen.bind("add_tag"))
	addViceButton.pressed.connect(toggleScreen.bind("add_vice"))
	cartButton.pressed.connect(toggleScreen.bind("cart"))
	tagsButton.pressed.connect(toggleScreen.bind("tags"))
	purchasedButton.pressed.connect(toggleScreen.bind("purchased"))
	vicesButton.pressed.connect(toggleScreen.bind("vices"))
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
	vicesPanel.theme_type_variation = "pressed" if current_screen == "vices" else "empty"

	cartButton.modulate = Color("6d8577") if current_screen == "cart" else Color("2e3334")
	tagsButton.modulate = Color("6d8577") if current_screen == "tags" else Color("2e3334")
	purchasedButton.modulate = Color("6d8577") if current_screen == "purchased" else Color("2e3334")
	vicesButton.modulate = Color("6d8577") if current_screen == "vices" else Color("2e3334")

func viewItem(item_id):
	toggleScreen("view_item")
	viewItemScreen.loadItemData(item_id)

func viewTag(tag_id):
	toggleScreen("view_tag")
	viewTagScreen.loadTagData(tag_id)

func viewPurchase(item_id):
	toggleScreen("view_purchase")
	viewPurchaseScreen.loadPurchaseData(item_id)

func viewVice(vice_id):
	print("TRYING TO VIEW VICE:", vice_id)
