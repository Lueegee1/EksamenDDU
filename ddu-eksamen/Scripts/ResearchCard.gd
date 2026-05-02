extends Control

@onready var sprite = $Group1/TextureRect
@onready var nametag = $Group1/Label
@onready var research_button = $Group1/TextureButton
@onready var description_button = $Group1/TextureButton2
@onready var discription = $Group2/Label4
@onready var cost = $Group1/Label2
var research
func setup(index):
	research = index
	if Global.GameManager.researches[index]["icons"] != "":
		sprite.texture = load(Global.GameManager.researches[index]["icons"]) as Texture2D
	#match sprite.texture_normal:
	#	"res://.godot/imported/Sprite-0003-Sheet8.png-71f00e160e62b4cdf7fe7e7ba903cadc.ctex": sprite.texture_pressed = load("res://.godot/imported/Sprite-0003-Sheet-Sheet8.png-4830186536b01167384e402b91dc8ba6.ctex") as Texture2D
	#	"res://Assets/temp files/buttons/Sprite-0003-Sheet3.png": sprite.texture_pressed = load("res://Assets/temp files/buttons/Sprite-0003-Sheet-Sheet3.png") as Texture2D
#	sprite.size = Vector2(128,128)
	nametag.text = Global.GameManager.researches[index]["name"]
	if Global.GameManager.researches[index]["description"] != "":
		discription.text = Global.GameManager.researches[index]["description"]
	else:
		discription.text = "This is a very mysterious research"
	cost.text = "Cost:
		" + str(Global.GameManager.researches[index]["cost"][0]) + "
		" + str(Global.GameManager.researches[index]["cost"][1]) + "
		" + str(Global.GameManager.researches[index]["cost"][2]) + "
		" + str(Global.GameManager.researches[index]["cost"][3])

# Called when the node enters the scene tree for the first time.



func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.GameManager.meet_research_requirements(research) and Global.GameManager.can_afford_research(research):
		research_button.disabled = false
	else:
		research_button.disabled = true
	pass


func _on_description_button_pressed() -> void:
	Global.GameManager.Click()
	if $Group2.visible != true:
		$Group1.visible = false
		$Group2.visible = true
	else: 
		$Group2.visible = false
		$Group1.visible = true
	pass # Replace with function body.


func _on_research_button_pressed() -> void:
	Global.GameManager.Click()
	Global.GameManager.research(research)
	pass # Replace with function body.
