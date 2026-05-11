class_name AssetRecognition

# General

## Obtains the file extension, used to detect its type
## Uses ResourceLoader.exists() as fallback for exported builds where DirAccess.get_files() returns empty
func get_extension(assetsFolder: String, fileName: String) -> String:
	var supported_extensions = [
		# Imágenes primero (prioridad sobre json para evitar colisiones de nombre)
		"png", "jpg", "jpeg", "webp", "svg", "bmp", "dds", "exr", "hdr", "tga", "ktx",
		# Audio
		"ogg", "mp3", "wav",
		# Vídeo
		"ogv",
		# Shaders y escenas
		"gdshader", "tscn",
		# Datos al final
		"json", "txt", "cfg"
	]
	for ext in supported_extensions:
		var path = assetsFolder + fileName + "." + ext
		if FileAccess.file_exists(path) or ResourceLoader.exists(path):
			return ext
	print("ASSET RECOGNITION ERROR: Assets folder could not be found: " + assetsFolder + fileName)
	return ""

## Loads the name of the directories contained in the path folder into the dir_list list
## Uses _index.json as fallback for exported builds where DirAccess returns empty
func load_dir_names_from_directory(path: String, dir_list):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var folder_name = dir.get_next()
		while folder_name != "":
			if dir.current_is_dir() and not folder_name.begins_with("."):
				dir_list.append(folder_name)
			folder_name = dir.get_next()
		dir.list_dir_end()
		if dir_list.size() > 0:
			return  # Éxito por DirAccess

	# Fallback para exportado: leer _index.json
	var index_path = path + "_index.json"
	if FileAccess.file_exists(index_path):
		var file = FileAccess.open(index_path, FileAccess.READ)
		var json = JSON.parse_string(file.get_as_text())
		file.close()
		if json is Array:
			for entry in json:
				dir_list.append(entry)
			return

	print("ASSET RECOGNITION ERROR: Dir folder could not be found: ", path)

## Loads the name of the files contained in the path folder into the file_list list
## Excludes .json and .import files. Uses _files_index.json as fallback for exported builds.
func load_file_names_from_directory(path: String, file_list):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() \
			and not file_name.begins_with(".") \
			and not file_name.ends_with(".import") \
			and not file_name.ends_with(".json"):
				var dot_index = file_name.rfind(".")
				if dot_index != -1:
					var base_name = file_name.substr(0, dot_index)
					if not file_list.has(base_name):
						file_list.append(base_name)
			file_name = dir.get_next()
		dir.list_dir_end()
		if file_list.size() > 0:
			return  # Éxito por DirAccess

	# Fallback para exportado: leer _files_index.json
	var index_path = path + "_files_index.json"
	if FileAccess.file_exists(index_path):
		var file = FileAccess.open(index_path, FileAccess.READ)
		var json = JSON.parse_string(file.get_as_text())
		file.close()
		if json is Array:
			for entry in json:
				file_list.append(entry)
			return

	print("ASSET RECOGNITION ERROR: Files folder could not be found: ", path)

# Images

## Detects visual resource type between image (png, jpg, jpeg, webp, svg), video (ogv) and shader (gdshader)
## named by the fileName from the assetsFolder and loads them into the specified container. Can personalize
## other container's atributes (expand, stretch, anchors).
func load_visual_resource(assetsFolder: String, fileName: String, container, expand = TextureRect.EXPAND_FIT_WIDTH, stretch = TextureRect.STRETCH_SCALE, anchors = Control.PRESET_FULL_RECT):
	var ext = get_extension(assetsFolder, fileName)
	if ext == "":
		print("ASSET RECOGNITION ERROR: Visual element file not found: ", assetsFolder + fileName)
		return
	var path = assetsFolder + fileName + "." + ext
	match ext:
		"bmp", "dds", "ktx", "exr", "hdr", "jpg", "jpeg", "png", "tga", "svg", "webp":
			var sprite_file = load(path)
			if sprite_file != null:
				var sprite = TextureRect.new()
				sprite.texture = sprite_file
				sprite.expand_mode = expand
				sprite.stretch_mode = stretch
				sprite.set_anchors_preset(anchors)
				container.add_child(sprite)
			else:
				print("ASSET RECOGNITION ERROR: Image could not be loaded: ", path)

		"ogv":
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
				print("ASSET RECOGNITION ERROR: Video could not be loaded: ", path)

		"gdshader":
			var shader_file = load(path)
			if shader_file != null and shader_file is Shader:
				var shader_material = ShaderMaterial.new()
				shader_material.shader = shader_file

				var shader_node = ColorRect.new()
				shader_node.material = shader_material
				shader_node.set_anchors_preset(Control.PRESET_FULL_RECT)
				shader_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				shader_node.size_flags_vertical = Control.SIZE_EXPAND_FILL

				container.add_child(shader_node)
				await shader_node.ready
				shader_material.set_shader_parameter("resolution", container.size)
			else:
				print("ASSET RECOGNITION ERROR: Shader could not be loaded: ", path)
		_:
			print("ASSET RECOGNITION ERROR: Unsuported visual element extension: ", ext)

# Data

## Returns JSON element found in JSON file given by json_path
func get_json_element(json_path: String, key_path: String, default_value = ""):
	if not FileAccess.file_exists(json_path):
		print("ASSET RECOGNITION ERROR: JSON file has not been found: ", json_path)
		return default_value

	var file = FileAccess.open(json_path, FileAccess.READ)
	if not file:
		print("ASSET RECOGNITION ERROR: JSON file could not be open: ", json_path)
		return default_value

	var content := file.get_as_text().strip_edges()
	file.close()

	if content == "":
		return default_value

	var json_data = JSON.parse_string(content)
	if typeof(json_data) != TYPE_DICTIONARY:
		return default_value

	var keys = key_path.split("/")
	var current = json_data

	for key in keys:
		if typeof(current) != TYPE_DICTIONARY or not current.has(key):
			return default_value
		current = current[key]

	return current

## Returns JSON element found in encrypted save file given by json_path
func get_encrypted_json_element(json_path: String, key_path: String, default_value = null):
	if not FileAccess.file_exists(json_path):
		return default_value

	var file = FileAccess.open_encrypted_with_pass(json_path, FileAccess.READ, Globals.SECRET_KEY)
	if file == null:
		return default_value

	var content := file.get_as_text().strip_edges()
	file.close()

	if content == "":
		return default_value

	var json_data = JSON.parse_string(content)
	if typeof(json_data) != TYPE_DICTIONARY:
		return default_value

	var keys = key_path.split("/")
	var current = json_data

	for key in keys:
		if typeof(current) != TYPE_DICTIONARY or not current.has(key):
			return default_value
		current = current[key]

	return current
