extends Control

@onready var parallax = $ParallaxBackground
@onready var license_viewer = $LicenseViewer

func _process(delta):
	parallax.scroll_offset = get_global_mouse_position()*0.3

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_play_button_pressed() -> void:
	pass # Replace with function body.

func _on_source_code_button_pressed() -> void:
	OS.shell_open("https://github.com/emmdie/GamejamTemplate")

func _on_settings_button_pressed() -> void:
	pass # Replace with function body.

func _on_license_button_pressed() -> void:
	license_viewer.visible = true
