extends Node

var request_headers

func _ready():
	%HTTPRequest.request_completed.connect(_on_request_completed)

	request_headers = [
		"apikey: " + DBFunc.SUPABASE_KEY,
		"Authorization: Bearer " + DBFunc.SUPABASE_KEY,
		"Content-Type: application/json"
	]

	var url = DBFunc.SUPABASE_URL + "/rest/v1/Teams?select=*"
	
func get_unit_info(unit : Unit):
	var unit_info = {
		"unit_name" : unit.unit_name,
		"hex_id" : unit.current_hex.hex_id
		}
	return unit_info
	
func get_unit_info_array():
	var unit_info_array = []
	for unit in %PlayerUnits.get_children():
		unit_info_array.append(get_unit_info(unit))
	return unit_info_array

func _on_store_team_in_db_pressed() -> void:
	store_team_in_db()
	
func _on_load_random_team_pressed() -> void:
	
	%HTTPRequest.request_completed.connect(_on_get_random_team_completed)
	var url = DBFunc.SUPABASE_URL + "/rest/v1/rpc/get_random_team"
	%HTTPRequest.request(url, request_headers, HTTPClient.METHOD_GET)
	
	
func _on_request_completed(result, response_code, headers, body):
	var response_text = body.get_string_from_utf8()
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(response_text)
		if parse_result == OK:
			var data = json.data
			print("Data received from Supabase: ", data)
			
		else:
			print("Failed to parse JSON response")
	else:
		print("Response code: ", response_code)
		print(response_text)

func _on_get_random_team_completed(result, response_code, headers, body):
	var response_text = body.get_string_from_utf8()
	print("Response code: ", response_code)
	print(response_text)
	construct_enemy_team(response_text)


func store_team_in_db():
	var data_to_enter = JSON.stringify(
		[
			{
				"units" : get_unit_info_array()
			}
		]
	)
		
	var url = DBFunc.SUPABASE_URL + "/rest/v1/Teams"
	
	%HTTPRequest.request(url, request_headers, HTTPClient.METHOD_POST, data_to_enter)

func construct_enemy_team(team_string):
	print("construct_enemy_team()")
	var team = JSON.parse_string(team_string)
	var team_data = team[0]		# TODO: Figure out error w/ this line
	var units_array = team_data["units"]

	for unit in units_array:
		var unit_scene = load("res://Units/" + unit["unit_name"] + ".tscn")
		var new_unit = unit_scene.instantiate()
		for enemy_hex in %EnemyHexes.get_children():
			if enemy_hex.hex_id == unit["hex_id"]:
				new_unit.current_hex = enemy_hex
				new_unit.position = enemy_hex.position
				get_tree().get_root().add_child(new_unit)
				print(str(unit) + " added to the scene!")
				# TODO: Implement this logic again
				#new_unit.snap_to_nearest_hex()
