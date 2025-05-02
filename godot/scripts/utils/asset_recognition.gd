extends Node

class_name AssetRecognition

func load_visual_resource(assetsFolder: String, fileName: String, element):
	var dir = DirAccess.open(assetsFolder)
	if dir == null:
		print("ERROR: Carpeta Assets no encontrada:" + assetsFolder)
		return
	var files = dir.get_files()
	var regex = RegEx.new()
	
		# Fondo pantalla
	regex.compile("^" + fileName + "\\.(.+)$")
	for file in files:
		var match = regex.search(file)
		if match:
			var ext = match.get_string(1).to_lower()
			var path = assetsFolder + file
			match_visual_resource(ext, path, element)
			break

func match_visual_resource(ext: String, path: String, container):
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
				print("ERROR: La imagen no ha sido cargada correctamente: ", path)
				
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
				print("ERROR: El vídeo no ha sido cargado correctamente: ", path)
				
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
				print("ERROR: El shader no ha cargado correctamente: ", path)
				
		_:
			print("ERROR: Extensión no soportada:", ext) #inicio control errores, acordarse de poner más
