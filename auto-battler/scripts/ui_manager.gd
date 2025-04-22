extends Node

func _ready() -> void:
	connect_signals()

func connect_signals() -> void:
	%StoreTeamButton.pressed.connect(DataManager._on_store_team_in_db_pressed)
	%LoadRandomTeamButton.pressed.connect(DataManager._on_load_random_team_pressed)
	%RollShopButton.pressed.connect(%ShopManager._on_roll_shop_pressed)
