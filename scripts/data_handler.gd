extends Node

const DEFAULT_ITEM_DATA := {}
const DEFAULT_TAG_DATA := {
	"No Tag": {"tag_name": "No Tag", "tag_color": "ffffff00"}
}
const DEFAULT_PURCHASE_DATA := {}

@onready var item_data := {}
@onready var tag_data := {}
@onready var purchase_data := {}
@onready var save_data_path := "user://user_data.json"

var time_zone_offset := 0

func _ready() -> void:
	loadData()
	time_zone_offset = Time.get_time_zone_from_system()['bias']*60
	
func loadData():
	if not FileAccess.file_exists(save_data_path):
		createNewSaveData()
	loadOldSaveData()

func createNewSaveData():
	var new_save_file = FileAccess.open(save_data_path, FileAccess.WRITE)
	var save_data = {"items": DEFAULT_ITEM_DATA, "tags": DEFAULT_TAG_DATA, "purchases": DEFAULT_PURCHASE_DATA}
	var save_data_json = JSON.stringify(save_data)
	new_save_file.store_line(save_data_json)
	new_save_file.close()
	return
	
func loadOldSaveData():
	var old_save_file := FileAccess.open(save_data_path, FileAccess.READ)
	var old_save_data = JSON.parse_string(old_save_file.get_as_text())
	item_data = old_save_data['items']
	tag_data = old_save_data['tags']
	purchase_data = old_save_data['purchases']
	for tag in tag_data:
		tag_data[tag]['tag_color'] = Color(tag_data[tag]['tag_color'])
	old_save_file.close()
	
func saveData():
	var old_save_file := FileAccess.open(save_data_path, FileAccess.WRITE)
	var new_save_data = {"items":item_data.duplicate_deep(), "tags":tag_data.duplicate_deep(), "purchases":purchase_data.duplicate_deep()}
	print("NEW SAVE DATA: ", new_save_data)
	for tag in new_save_data['tags']:
		new_save_data['tags'][tag]['tag_color'] = new_save_data['tags'][tag]['tag_color'].to_html()
	var new_save_data_json := JSON.stringify(new_save_data)
	
	old_save_file.store_line(new_save_data_json)
	old_save_file.close()
	
func addItem(item):
	item_data[item.item_name] = item
	saveData()

func updateItem(original_name, item):
	item_data.erase(original_name)
	item_data[item['item_name']] = item
	saveData()

func deleteItem(item):
	item_data.erase(item)
	saveData()

func addTag(tag):
	tag_data[tag.tag_name] = tag
	saveData()

func updateTag(original_name, tag):
	tag_data.erase(original_name)
	tag_data[tag['tag_name']] = tag
	for item in item_data:
		if item_data[item]['item_tag'] == original_name:
			item_data[item]['item_tag'] = tag['tag_name']
	for item in purchase_data:
		if purchase_data[item]['item_tag'] == original_name:
			purchase_data[item]['item_tag'] = tag['tag_name']
	saveData()

func deleteTag(tag):
	tag_data.erase(tag)
	for item in item_data:
		if item_data[item]['item_tag'] == tag:
			item_data[item]['item_tag'] = "No Tag"
	for item in purchase_data:
		if purchase_data[item]['item_tag'] == tag:
			purchase_data[item]['item_tag'] = "No Tag"
	saveData()

func addPurchase(purchase):
	purchase_data[purchase['item_name']] = purchase
	saveData()
	
func updatePurchase(original_name, purchase):
	purchase_data.erase(original_name)
	purchase_data[purchase['item_name']] = purchase
	saveData()

func checkDuplicateItem(item_name, original_item_name=""):
	if item_name == original_item_name:
		return false
	if item_name in item_data or item_name in purchase_data:
		return true
	return false
	#return item_name == original_item_name or not (item_name in item_data or item_name in purchase_data)
	#if item_name == original_item_name and original_item_name != "": return true
	#return not (item_name in item_data or item_name in purchase_data)
	#RETURNS TRUE IF ITEM IS DUPLICATE

func checkDuplicateTag(tag_name, tag_color, original_tag_name="", original_tag_color=Color.TRANSPARENT):
	var tag_changed = tag_name != original_tag_name
	var color_changed = tag_color != original_tag_color
	var tag_exists = tag_name in tag_data
	var color_exists = false
	for t in tag_data:
		if tag_data[t]['tag_color'] == tag_color:
			color_exists = true
	
	if (not tag_changed) and (not color_changed): #if nothing has changed
		print("A")
		return true #duplicate
	if tag_changed and not color_changed: #if tag has changed and color hasn't
		print("B")
		return tag_exists #if tag exists, its a duplicate
	if color_changed and not tag_changed: #if color has changed and tag hasn't
		print("C")
		return color_exists
	if color_changed and tag_changed: #if both have changed
		print("D")
		return tag_exists or color_exists
		

func getItemsByDate():
	var date_array = []
	for item in item_data:
		date_array.append([item, item_data[item]['item_date']])
	date_array.sort_custom(sortByDate)
	return date_array.map(func(element): return element[0])

func getPurchasesByDate():
	var date_array = []
	for item in purchase_data:
		date_array.append([item, purchase_data[item]['item_date']])
	date_array.sort_custom(sortByDate)
	return date_array.map(func(element): return element[0])

func getPurchasesByPurchaseDate():
	var date_array = []
	for item in purchase_data:
		date_array.append([item, purchase_data[item]['purchase_date']])
	date_array.sort_custom(sortByDate)
	return date_array.map(func(element): return element[0])
	
func sortByDate(item_1, item_2):
	if item_1[1] < item_2[1]:
		return true
	else:
		return false

func getItemsByPrice():
	var price_array = []
	for item in item_data:
		price_array.append([item, int(item_data[item]['item_price'])])
	price_array.sort_custom(sortByPrice)
	return price_array.map(func(element): return element[0])

func getPurchasesByPrice():
	var price_array = []
	for item in purchase_data:
		price_array.append([item, int(purchase_data[item]['item_price'])])
	price_array.sort_custom(sortByPrice)
	return price_array.map(func(element): return element[0])
	
func sortByPrice(item_1, item_2):
	if item_1[1] < item_2[1]:
		return true
	else:
		return false

func getItemsByName():
	var item_names = item_data.keys().duplicate()
	item_names.sort()
	return item_names
	
func getPurchasesByName():
	var item_names = purchase_data.keys().duplicate()
	item_names.sort()
	return item_names

func getItemsByTag():
	var tag_array = []
	for item in item_data:
		tag_array.append([item, item_data[item]['item_tag']])
	tag_array.sort_custom(sortByTag)
	return tag_array.map(func(element): return element[0])

func getPurchasesByTag():
	var tag_array = []
	for item in purchase_data:
		tag_array.append([item, purchase_data[item]['item_tag']])
	tag_array.sort_custom(sortByTag)
	return tag_array.map(func(element): return element[0])
	
func sortByTag(item_1, item_2):
	if item_1[1] < item_2[1]:
		return true
	else:
		return false

func getTotalItemPrice():
	var price = 0
	for item in item_data:
		price += int(item_data[item]['item_price'])
	return str(price)
	
func getTotalItems():
	return str(len(item_data.values()))

func getTotalPurchasePrice():
	var price = 0
	for item in purchase_data:
		price += int(purchase_data[item]['item_price'])
	return str(price)
	
func getTotalPurchases():
	return str(len(purchase_data.values()))
	
func resetAllData():
	createNewSaveData()
	loadOldSaveData()
