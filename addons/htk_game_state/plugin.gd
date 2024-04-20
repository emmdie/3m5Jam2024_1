@tool
extends EditorPlugin


enum STATE_OPTIONS {CLEAR}

var setup_dialog: AcceptDialog
var file_dialog: EditorFileDialog


func _enter_tree():
	if not ProjectSettings.has_setting("autoload/GameState"):
		setup_autoload()

	var state_menu = PopupMenu.new()
	state_menu.add_item("Clear", STATE_OPTIONS.CLEAR)
	state_menu.id_pressed.connect(state_handler)

	add_tool_submenu_item("State", state_menu)


func _exit_tree():
	remove_autoload_singleton("GameState")
	remove_tool_menu_item("State")


func setup_autoload():
	setup_dialog = AcceptDialog.new()
	setup_dialog.exclusive = true
	setup_dialog.title = "Setup GameState"
	setup_dialog.get_ok_button().visible = false
	var l := Label.new()
	l.text = "To use GameState as own state you need a script that inherits GameStateBase.\nYou can use GameStateBase if you use a plugin that requires GameState but don't want to have an own state."
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var button_open := Button.new()
	button_open.text = "Open an existing file"
	button_open.pressed.connect(setup_existing)
	var button_new := Button.new()
	button_new.text = "Create a file for me"
	button_new.pressed.connect(setup_new)
	var button_no := Button.new()
	button_no.text = "Use GameStateBase"
	button_no.pressed.connect(setup_base)
	var vb := VBoxContainer.new()
	vb.add_child(l)
	vb.add_child(button_open)
	vb.add_child(button_new)
	vb.add_child(button_no)
	setup_dialog.add_child(vb)

	get_editor_interface().get_base_control().add_child(setup_dialog)
	setup_dialog.popup_centered_clamped()


func setup_base():
	hide_dialogs()

	add_autoload_singleton("GameState", "res://addons/htk_game_state/game_state.gd")


func setup_new():
	hide_dialogs()

	file_dialog = EditorFileDialog.new()
	get_editor_interface().get_base_control().add_child(file_dialog)

	file_dialog.current_file = "game_state"
	file_dialog.add_filter("*.gd")
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	file_dialog.exclusive = true

	file_dialog.file_selected.connect(create_new)
	file_dialog.title = "Create GameState script"

	file_dialog.popup_centered_ratio()


func create_new(path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(generate_state())
	file.close()

	get_editor_interface().get_resource_filesystem().scan()
	get_editor_interface().get_resource_filesystem().update_file(path)

	get_editor_interface().edit_script(ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE))

	add_autoload_singleton("GameState", path)


func setup_existing():
	hide_dialogs()

	file_dialog = EditorFileDialog.new()
	get_editor_interface().get_base_control().add_child(file_dialog)

	file_dialog.current_file = "game_state"
	file_dialog.add_filter("*.gd, *.tscn; Autoload")
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	file_dialog.exclusive = true

	file_dialog.file_selected.connect(add_existing)
	file_dialog.title = "Select GameState autoload"

	file_dialog.popup_centered_ratio()


func add_existing(path):
	hide_dialogs()
	add_autoload_singleton("GameState", path)


func hide_dialogs():
	if is_instance_valid(setup_dialog):
		setup_dialog.visible = false
		setup_dialog.queue_free()
	if is_instance_valid(file_dialog):
		file_dialog.visible = false
		file_dialog.queue_free()


func state_handler(id):
	var game_state = get_tree().get_root().get_node_or_null("GameState")
	if not game_state:
		return

	match(id):
		STATE_OPTIONS.CLEAR:
			# if the derived state is not marked as tool
			# no error should be thrown
			# (there might be reasons like complex and different paths)
			if game_state.has_method("reset_state"):
				game_state.reset_state()
			else:
				print("Mark your GameState script as tool to allow editor tools.")


func generate_state():
	var template = """@tool
extends GameStateBase


# Some example variable.
var highscore := Value.new(0)


# Override this to change the path under which the state is saved.
func _get_file_path():
	return "user://game.state"


# Override the password used to encrypt the file.
# This password is randomly generated. You can keep it.
func _get_password():
	return "%s"


# Should the state automaticaly load on startup and save on change.
func _get_auto_save_load():
	return true
"""
	return template % generate_word(
		'abcdefghiklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890?$§%_.;,/()[]{}+#~-',
		32,
	)


func generate_word(chars, length):
	var word: String = ""
	for i in range(length):
		word += chars[randi()% len(chars)]

	return word
