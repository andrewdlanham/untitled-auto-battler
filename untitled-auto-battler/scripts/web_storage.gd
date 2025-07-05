extends Node

func _ready() -> void:
	if not OS.has_feature("web"):
		push_warning("Web feature not detected!")

func set_item(key: String, value: String) -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("localStorage.setItem('%s', '%s');" % [key, value], true)

func get_item(key: String) -> String:
	if OS.has_feature("web"):
		return JavaScriptBridge.eval("localStorage.getItem('%s');" % key, true) as String
	return ""

func remove_item(key: String) -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("localStorage.removeItem('%s');" % key, true)
