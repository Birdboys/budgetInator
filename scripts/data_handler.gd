extends Node

@onready var item_data := {}
@onready var tag_data := {
	"No Tag": {"tag_name": "No Tag", "tag_color": Color.TRANSPARENT}
}

func addItem(item):
	item_data[item.item_name] = item

func updateItem(original_name, item):
	item_data.erase(original_name)
	item_data[item['item_name']] = item

func deleteItem(item):
	item_data.erase(item)

func addTag(tag):
	tag_data[tag.tag_name] = tag

func updateTag(original_name, tag):
	tag_data.erase(original_name)
	tag_data[tag['tag_name']] = tag
	for item in item_data:
		if item_data[item]['item_tag'] == original_name:
			item_data[item]['item_tag'] = tag['tag_name']

func deleteTag(tag):
	tag_data.erase(tag)
	for item in item_data:
		if item_data[item]['item_tag'] == tag:
			item_data[item]['item_tag'] = "No Tag"

func checkDuplicateItem(item_name, original_item_name=""):
	if item_name == original_item_name and original_item_name != "": return true
	return not (item_name in item_data)

func checkDuplicateTag(tag_name, tag_color, original_tag_name="", original_tag_color=Color.TRANSPARENT):
	if tag_name == original_tag_name and original_tag_name == "" and tag_color == original_tag_color and original_tag_color != Color.TRANSPARENT: 
		return true

	var is_duplicate := false
	if tag_name in tag_data: 
		is_duplicate = true
	for tag in tag_data:
		if tag_color == tag_data[tag]['tag_color']:
			is_duplicate = true
	return not is_duplicate

func getItemsByDate():
	var date_array = []
	for item in item_data:
		date_array.append([item, item_data[item]['item_date']])
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

func sortByPrice(item_1, item_2):
	if item_1[1] < item_2[1]:
		return true
	else:
		return false

func getItemsByName():
	var item_names = item_data.keys().duplicate()
	item_names.sort()
	return item_names

func getItemsByTag():
	var tag_array = []
	for item in item_data:
		tag_array.append([item, item_data[item]['item_tag']])
	tag_array.sort_custom(sortByTag)
	return tag_array.map(func(element): return element[0])
	
func sortByTag(item_1, item_2):
	if item_1[1] < item_2[1]:
		return true
	else:
		return false

func getTotalPrice():
	var price = 0
	for item in item_data:
		price += int(item_data[item]['item_price'])
	return str(price)
	
func getTotalItems():
	return str(len(item_data.values()))
