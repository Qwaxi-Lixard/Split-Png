extends Panel

onready var SourceImage: TextureRect = $SourceImage
onready var OverlayGrid: GridContainer = $CenterContainer/OverlayGrid

func _ready() -> void:
	connect("resized", self, "_on_resized")
	pass


func _on_resized() -> void:
	if SourceImage.texture:
		var size = SourceImage.texture.get_size() 
		var ratio = (rect_size) / size
		var scale_factor = min(ratio.x, ratio.y)
		
		OverlayGrid.rect_min_size = Vector2(round(scale_factor * size.x), round(scale_factor * size.y))
		OverlayGrid.resize_cells()
		
