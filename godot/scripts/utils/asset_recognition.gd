class_name AssetRecognition

# General

## Obtains the file extension, used to detect its type
func get_extension(assetsFolder: String, fileName: String):
	var dir = DirAccess.open(assetsFolder)
	if dir == null:
		print("ERROR: Assets folder could not be found: " + assetsFolder)
		return ""
	var files = dir.get_files()
	var regex = RegEx.new()
	
	regex.compile("^" + fileName + "\\.(.+)$")
	for file in files:
		if file.ends_with(".import"):
			continue # Ignora los archivos .import
		var match = regex.search(file)
		if match:
			return match.get_string(1).to_lower() # Devuelve la extensión del archivo
	return "" # Devuelve string vacío para evitar errores por el uso de Nil (ex: Invalid operands 'String' and 'Nil' in operator '+'.)

## Loads the name of the directories contained in the path folder into the dir_list list
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
	else:
		print("ERROR: dir folder could not be found: ", path)

## Loads the name of the files contained in the path folder into the file_list list
func load_file_names_from_directory(path: String, file_list):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and not file_name.begins_with(".") and not file_name.ends_with(".import"):
				var dot_index = file_name.rfind(".")
				if dot_index != -1:
					var base_name = file_name.substr(0, dot_index)
					if not file_list.has(base_name): # evita duplicados si hay reloj14.png y reloj14.import
						file_list.append(base_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("ERROR: files folder could not be found: ", path)

# Images

## Detects visual resource type between image (png, jpg, jpeg, webp, svg), video (ogv) and shader (gdshader)
## named by the fileName from the assetsFolder and loads them into the specified container. Can personalize
## other container's atributes (expand, stretch,  anchors).
func load_visual_resource(assetsFolder: String, fileName: String, container, expand = TextureRect.EXPAND_FIT_WIDTH, stretch = TextureRect.STRETCH_SCALE, anchors = Control.PRESET_FULL_RECT):
	var ext = get_extension(assetsFolder, fileName)
	var path = assetsFolder + fileName + "." + ext
	match ext:
		"bmp", "dds", "ktx", "exr", "hdr", "jpg", "jpeg", "png", "tga", "svg", "webp" :
			var sprite_file = load(path)
			if sprite_file != null:
				var sprite = TextureRect.new()
				sprite.texture = sprite_file
				sprite.expand_mode = expand
				sprite.stretch_mode = stretch
				sprite.set_anchors_preset(anchors)
				container.add_child(sprite)
			else:
				print("ERROR: Image could not be loaded: ", path)
				
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
				print("ERROR: Video could not be loaded: ", path)
				
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

				# Esperamos a que el nodo tenga tamaño real para pasar la resolución
				await shader_node.ready
				shader_material.set_shader_parameter("resolution", container.size)
			else:
				print("ERROR: Shader could not be loaded: ", path)
		_:
			print("ERROR: Unsuported visual element extension: ", ext) #inicio control errores, acordarse de poner más

### Poner separadas las funciones de arriba

# Data (podríamos hacer como con las imágenes algo general para json y cfg)

## Returns JSONelement found in JSON file given by JSONpath
func get_json_element(json_path: String, key_path: String, default_value = ""):
	if not FileAccess.file_exists(json_path):
		print("ERROR: JSON file has not been found: ", json_path)
		return default_value

	var file = FileAccess.open(json_path, FileAccess.READ)
	if not file:
		print("ERROR: JSON file could not be open: ", json_path)
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

## Returns JSONelement found in JSON file given by JSONpath after decoding it
func get_encrypted_json_element(json_path: String, key_path: String, default_value = null):
	if not FileAccess.file_exists(json_path):
		print("")
		return default_value

	var file = FileAccess.open(json_path, FileAccess.READ)
	if not file:
		return default_value

	var content := file.get_as_text().strip_edges()
	file.close()

	if content == "":
		return default_value

	var parsed = JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY:
		return default_value

	if not parsed.has("data") or not parsed.has("hash"):
		return default_value

	var data_text = parsed["data"]
	var stored_hash = parsed["hash"]
	var recalculated_hash = SaveEncoder.new()._generate_hash(data_text)

	if stored_hash != recalculated_hash:
		push_error("Data has been manipulated!")
		return default_value

	var json_data = JSON.parse_string(data_text)
	if typeof(json_data) != TYPE_DICTIONARY:
		return default_value

	var keys = key_path.split("/")
	var current = json_data

	for key in keys:
		if typeof(current) != TYPE_DICTIONARY or not current.has(key):
			return default_value
		current = current[key]

	return current
