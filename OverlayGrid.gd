extends GridContainer

const OverlayCell = preload("res://OverlayCell.tscn")

var pages: int = 1
var rows: int = 1
var cols: int = 1

func _ready() -> void:
	pass
	
func show_pages(p = pages, r = rows, c = cols) -> void:
	pages = p
	rows = r
	cols = c
	var page_size = rect_min_size / Vector2(cols, rows)
	for child in get_children():
		child.queue_free()
		remove_child(child)
	
	for i in range(pages):
		var cell = OverlayCell.instance()
		cell.rect_min_size = page_size
		cell.get_node("Label").text = "Page [%d]" % i
		add_child(cell)


func resize_cells() -> void:
	var page_size = rect_min_size / Vector2(cols, rows)
	print(page_size)
	for child in get_children():
		child.rect_min_size = page_size
	
