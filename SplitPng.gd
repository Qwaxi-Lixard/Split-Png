extends PanelContainer

var TYPES = ["png"]
var out_dir: String = ""
var file_name: String = ""

onready var RowCount = $HBoxContainer/VBoxContainer/Options/RowCount
onready var ColumnCount = $HBoxContainer/VBoxContainer/Options/ColumnCount
onready var ExportCount = $HBoxContainer/VBoxContainer/Options/ExportCount
onready var ExportButton = $HBoxContainer/VBoxContainer/Options/ExportButton
onready var SourceImage = $HBoxContainer/ImagePanel/SourceImage
onready var Message = $HBoxContainer/ImagePanel/Message

onready var ImagePanel = $HBoxContainer/ImagePanel
onready var OverlayGrid = $HBoxContainer/ImagePanel/CenterContainer/OverlayGrid

func _ready() -> void:
	get_tree().connect("files_dropped", self, "_on_files_dropped")
	RowCount.connect("value_changed", self, "_on_value_changed")
	ColumnCount.connect("value_changed", self, "_on_value_changed")
	ExportCount.connect("value_changed", self, "_on_value_changed")
	ExportButton.connect("pressed", self, "_on_button_pressed")


func _on_files_dropped(files: PoolStringArray, screen: int) -> void:
	print(files)
	var file: String = files[0]
	var file_ending = file.split(".")[-1]
	var path = file.split("/")
	file_name = (path[-1] as String).replace(" ", "_")
	path.resize(path.size() - 1)
	out_dir = path.join("/") + "/"
	
	if not file_ending in TYPES:
		return
	
	var f = File.new()
	f.open(file, File.READ)
	var data = f.get_buffer(f.get_len())
	f.close()
	var image = Image.new()
	image.load_png_from_buffer(data)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	SourceImage.texture = texture
	Message.hide()
	
	ImagePanel._on_resized()
	OverlayGrid.call_deferred("call_deferred", "show_pages", ExportCount.value, RowCount.value, ColumnCount.value)


func _on_value_changed(value: float) -> void:
	var can_export = 0 < RowCount.value and 0 < ColumnCount.value \
		and 0 < ExportCount.value
		
	ExportCount.max_value = RowCount.value * ColumnCount.value
	OverlayGrid.columns = int(ColumnCount.value)
	OverlayGrid.show_pages(ExportCount.value, RowCount.value, ColumnCount.value)
	ExportButton.disabled = not can_export


func _on_button_pressed() -> void:
	var texture_size = SourceImage.texture.get_size()
	var page_size = texture_size / Vector2(ColumnCount.value, RowCount.value)
	var source_image = SourceImage.texture.get_data()
	var export_image = Image.new()
	var dir = Directory.new()
	var dir_path = out_dir + "/pages_%s" % file_name
	
	export_image.create(page_size.x, page_size.y, false, Image.FORMAT_RGB8)
	print(texture_size / Vector2(ColumnCount.value, RowCount.value))
	
	dir.make_dir(dir_path)
	var file_path = dir_path + "/%02d.png"
	
	var i = 0
	for row in range(RowCount.value):
		for column in range(ColumnCount.value):
			if i >= ExportCount.value:
				return
			
			i += 1
			var pos = Vector2(column, row)
			source_image.lock()
			export_image.lock()
			print(Rect2(pos * page_size, page_size))
			export_image.blit_rect(source_image, Rect2(pos * page_size, page_size), Vector2.ZERO)
			export_image.save_png(file_path % i)
			
			export_image.unlock()
			source_image.unlock()
			
