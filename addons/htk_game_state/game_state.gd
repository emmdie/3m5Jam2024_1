@tool
class_name GameStateBase
extends Node

## Base class for GameState autoloads. Can be used standalone as well.
## Includes serialization as JSON.
## Other plugins can hook Serializables into the save process.


## Wraps around a ConfigFile but does only expose one section.
class SectionWrapper extends RefCounted:
	var file: ConfigFile
	var section: String


	func _init(p_file: ConfigFile, p_section: String) -> void:
		file = p_file
		section = p_section


	func get_keys() -> PackedStringArray:
		return file.get_section_keys(section)


	func get_value(key: String, default: Variant = null) -> Variant:
		return file.get_value(section, key, default)


	func set_value(key: String, value: Variant) -> void:
		return file.set_value(section, key, value)


	func erase_key(key: String) -> void:
		return file.erase_section_key(section, key)


	func has_key(key: String) -> bool:
		return file.has_section_key(section, key)


## Base class for saved values. Can be used by plugins to save plugin data with the state.
## Use Value and its derived classes for your own state.
class Serializable extends RefCounted:
	signal changed()


	## Returns the serialized data.
	func serialize(config: SectionWrapper) -> void:
		return _serialize(config)


	## Override for custom serialization.
	func _serialize(config: SectionWrapper) -> void:
		pass


	## Deserialzes the data based on the value.
	func deserialize(config: SectionWrapper) -> void:
		return _deserialize(config)


	## Override for custom deserialization.
	func _deserialize(config: SectionWrapper) -> void:
		pass


	## When this is called the data should be reset to its defaults.
	## This way the GameState supports resetting without restarting.
	func reset() -> void:
		return _reset()


	## Override this to change set default behaviour.
	func _reset() -> void:
		pass


## Base class for serialized values for the player state.
class Value extends Serializable:
	## The real stored value
	var value:
		set(p_value):
			if typeof(p_value) != typeof(default_value):
				push_warning(
					"GameState.Value: Can not set value "
					+ str(value) + " with value "
					+ str(p_value)
					+ ". Keeping old value. (This may be due to a type conflict.)"
				)
				return
			value = p_value
			changed.emit()
		get:
			return value

	## The default value. The value with which the instance was initialized.
	var default_value: Variant
	var serialized: bool


	func _init(p_value: Variant, p_serialized: bool = true) -> void:
		default_value = p_value
		value = p_value
		serialized = p_serialized


	func _reset() -> void:
		value = default_value


	func _serialize(config: SectionWrapper) -> void:
		config.set_value(config.get_meta(&"key"), value)


	func _deserialize(config: SectionWrapper) -> void:
		value = config.get_value(config.get_meta(&"key"), default_value)


	func str() -> String:
		return str(value)


## Under this section meta information is stored.
const SECTION_META: String = "meta"
## Under this key the version of the state is saved.
const KEY_STATE_VERSION: String = "state_version"

## Under this section the state is stored.
const SECTION_STATE: String = "state"

## Prefix for extension sections.
const EXTENSION_PREFIX: String = "extension_"

## Registerd extensions. A plugin can register an extension to save its state together
## with the state of the game.
var __extensions: Dictionary = {}


func _ready() -> void:
	__ready_auto_save()


## Returns the file path under which the state is stored.
func get_file_path() -> String:
	return _get_file_path()

## Override to change the path under which the state is saved.
func _get_file_path() -> String:
	return "user://game.state"


## Returns the password with wich the state file is encrypted.
func get_password() -> String:
	return _get_password()

## Override the password. Include device specifics to prevent transfering save files.
func _get_password() -> String:
	return ""


## Returns the current version of the state.
func get_version() -> int:
	return _get_version()

## Override to change the version of the state.
func _get_version() -> int:
	return 1


## Returns whether the state should auto save when changed. And auto load on start.
func get_auto_save_load() -> bool:
	return _get_auto_save_load()

## Override to change auto save load behaviour.
func _get_auto_save_load() -> bool:
	return true


## Upgrade old state to a new version. Has to be implemented by the programmer.
func handle_old_version(config: ConfigFile) -> ConfigFile:
	return _handle_old_version(config)

## Override to implement upgrading. When you update the version of state you have to implement this.
## Setting up the version is only necessary if the state is not backwards compatible. Don't use this
## durring active development. It is meant for game updates.
func _handle_old_version(config: ConfigFile) -> ConfigFile:
	return null


## Adds an extension. An extension is just an serializable. A unique key is needed.
func add_extension(name: String, extension: Serializable) -> void:
	if __extensions.has(name):
		push_error("GameState: An extension with the name "+name+" already exists.")
		return
	__extensions[name] = extension
	if get_auto_save_load():
		extension.changed.connect(__auto_save)
	load_extension(name)


## Loads the data and deserializes the extension when data for it exists.
func load_extension(name: String, p_state: ConfigFile = null):
	var state: ConfigFile = p_state
	if state == null:
		state = load_data()
	if state == null:
		return

	if not state.has_section(EXTENSION_PREFIX + name):
		return
	var wrapper = SectionWrapper.new(state, EXTENSION_PREFIX + name)

	__extensions[name].deserialize(wrapper)


## Setup auto saving and loading.
func __ready_auto_save():
	if get_auto_save_load():
		load_state()
		for prop in get_property_list():
			var val = get(prop["name"])
			if val is Value and val.serialized:
				val.changed.connect(__auto_save)


## Removes the saved file.
func clear_save():
	if FileAccess.file_exists(get_file_path()):
		var err = DirAccess.remove_absolute(get_file_path())
		if err != OK:
			print("GameState: Error while removing save file. (Code: "+str(err)+")")


## Resets the state to default.
func reset_state():
	for prop in get_property_list():
		var val = get(prop["name"])
		if val is Value:
			val.reset()
	for ext in __extensions:
		ext.reset()
	clear_save()


## Saves the state.
func save_state() -> void:
	var state = ConfigFile.new()
	for prop in get_property_list():
		var val = get(prop["name"])
		if val is Value and val.serialized:
			var wrapper = SectionWrapper.new(state, SECTION_STATE)
			wrapper.set_meta(&"key", prop["name"])
			val.serialize(wrapper)

	for ext in __extensions.keys():
		__extensions[ext].serialize(SectionWrapper.new(state, EXTENSION_PREFIX + ext))

	state.set_value(SECTION_META, KEY_STATE_VERSION, get_version())

	state.save_encrypted_pass(get_file_path(), get_password())


## Loads the data.
func load_data() -> ConfigFile:
	if not FileAccess.file_exists(get_file_path()):
		push_warning("GameState: No state file found for loading. Keeping current state. (This may be due to first starting the game on a new device.)")
		return null

	var state := ConfigFile.new()
	var err = state.load_encrypted_pass(get_file_path(), get_password())
	if err != OK:
		push_error("GameState: Error loading save file. (Code:"+str(FileAccess.get_open_error())+")")
		return null

	return state


## Loads the data and deserializes the complete state.
func load_state() -> void:
	var state := load_data()
	if state == null:
		return

	if state.get_value(SECTION_META, KEY_STATE_VERSION, get_version()) < get_version():
		var converted = handle_old_version(state)
		if converted == null:
			push_warning("GameState: Could not upgrade state from version "+str(state.get_value(SECTION_META, KEY_STATE_VERSION, get_version()))+" to "+str(get_version())+". Keeping current state. (This may be due to the developer not implementing proper upgrade mechanics. Shame on him.)")
			return
		state = converted
	elif state.get_value(SECTION_META, KEY_STATE_VERSION, get_version()) > get_version():
		push_warning("GameState: Could not load state from newer version. Keeping current state. (This may be due to using an old version of the game. Consider updating it.)")

	for prop in get_property_list():
		var val = get(prop["name"])
		if val is Serializable and val.serialized:
			var wrapper = SectionWrapper.new(state, SECTION_STATE)
			wrapper.set_meta(&"key", prop["name"])
			val.deserialize(wrapper)

	for ext in __extensions.keys():
		load_extension(ext, state)


func __auto_save():
	save_state()
