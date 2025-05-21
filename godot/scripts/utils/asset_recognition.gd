class_name AssetRecognition

func get_extension(assetsFolder: String, fileName: String):
	var dir = DirAccess.open(assetsFolder)
	if dir == null:
		print("ERROR: Assets folder could not be found " + assetsFolder)
		return
	var files = dir.get_files()
	var regex = RegEx.new()
	
	regex.compile("^" + fileName + "\\.(.+)$")
	for file in files:
		var match = regex.search(file)
		if match:
			return match.get_string(1).to_lower() # Devuelve la extensión del archivo

func load_visual_resource(assetsFolder: String, fileName: String, container):
	var ext = get_extension(assetsFolder, fileName)
	var path = assetsFolder + fileName + "." + ext
	match ext:
		"png", "jpg", "jpeg", "webp": # Carga de una imagen
			var sprite_file = load(path)
			if sprite_file != null:
				var sprite = TextureRect.new()
				sprite.texture = sprite_file
				sprite.set_anchors_preset(Control.PRESET_FULL_RECT)
				sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH
				container.add_child(sprite)
			else:
				print("ERROR: Image could not be loaded ", path)
				
		"webm", "ogv": # Carga de un vídeo
			var video_file = load(path)
			if video_file != null:
				var video = VideoStreamPlayer.new()
				video.stream = video_file
				video.set_anchors_preset(Control.PRESET_FULL_RECT)
				video.autoplay = true
				video.expand = true
				video.loop = true
				container.add_child(video)
			else:
				print("ERROR: Video could not be loaded ", path)
				
		"gdshader": #Carga de un shader
			var shader_file = load(path)
			if shader_file != null:
				var shader_material = ShaderMaterial.new()
				shader_material.shader = shader_file
				var shader = ColorRect.new()
				shader.material = shader_material
				shader.set_anchors_preset(Control.PRESET_FULL_RECT)
				shader.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				shader.size_flags_vertical = Control.SIZE_EXPAND_FILL
				container.add_child(shader)
			else:
				print("ERROR: Shader could not be loaded ", path)
		_:
			print("ERROR: Unsuported extension ", ext) #inicio control errores, acordarse de poner más

func load_audio_resource(node: Node, assetsFolder: String, fileName: String, type): # Más adelante tendremos que controlar que sea una canción o un s
	if not node.get_tree().get_root().has_node("MusicManager"):
		var audio_file = load(assetsFolder + fileName)
		var music_manager = preload("res://scenes/musicManager.tscn").instantiate()
		music_manager.name = "musicManager"
		node.get_tree().get_root().call_deferred("add_child", music_manager)
		match type:
			"music":
				music_manager.play_music(audio_file)
			"sfx":
				music_manager.play_sfx(audio_file)
			_:
				print("ERROR: Audio type not recognized " + type)

func load_json_resource(assetFolder: String, fileName: String, container, JSONelement: String):
	var path = assetFolder + fileName + ".json"
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var level_data = JSON.parse_string(file.get_as_text())
		if level_data == null:
			push_error("ERROR: JSON read fail ", path)
		container.text = level_data[JSONelement]
	else:
		print("ERROR: JSON could not be opened ", path)


func load_levels_from_directory(path: String, levels): # Guarda los nombres de las carpetas en un array
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var folder_name = dir.get_next()
		while folder_name != "":
			if dir.current_is_dir() and not folder_name.begins_with("."):
				levels.append(folder_name)
			folder_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("ERROR: levels folder could not be found ", path)
