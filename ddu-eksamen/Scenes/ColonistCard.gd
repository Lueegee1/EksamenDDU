extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$WorkButton.get_popup().id_pressed.connect(_on_item_pressed)
	pass # Replace with function body.

func _on_item_pressed(id) -> void:
	var popup = $WorkButton.get_popup()
	var index = popup.get_item_index(id)
	
	# Uncheck all items first
	for i in popup.item_count:
		popup.set_item_checked(i, false)
	
	# Check the one that was pressed
	popup.set_item_checked(index, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
