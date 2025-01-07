extends Node3D

func render_line(pos1: Vector3, pos2: Vector3, color = Color.WHITE_SMOKE):
	var mesh_instance := MeshInstance3D.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)
	st.add_vertex(Vector3(pos1.x, pos1.y, pos1.z))
	st.add_vertex(Vector3(pos2.x, pos2.y, pos2.z))
	
	st.set_material(material)
	
	st.index()
	
	mesh_instance.mesh = st.commit()
	add_child(mesh_instance)

func clear_meshes():
	for c in get_children():
		c.queue_free()
