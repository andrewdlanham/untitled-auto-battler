'''
A test script for learning how to use ImmediateMesh
'''
extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var test_mesh = ImmediateMesh.new()
	
	test_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	test_mesh.surface_set_color(Color.RED)
	test_mesh.surface_add_vertex(Vector3(0,0,0))
	test_mesh.surface_add_vertex(Vector3(3,3,-5))
	
	test_mesh.surface_end()
	
	mesh = test_mesh

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
