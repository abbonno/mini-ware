class_name SaveEncoder

# Guarda un diccionario encriptado en la ruta indicada.
# Usa open_encrypted_with_pass con Globals.SECRET_KEY.
func save_encoded_json(path: String, data: Dictionary) -> void:
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, Globals.SECRET_KEY)
	if file == null:
		print("SAVE ENCODER ERROR: Could not open file for writing: ", path, " | Error: ", FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(data))
	file.close()

# Carga y desencripta un diccionario desde la ruta indicada.
# Devuelve {} si el archivo no existe (primera ejecución) o si hay un error.
func load_encoded_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}  # Normal en primera ejecución, no es un error

	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, Globals.SECRET_KEY)
	if file == null:
		print("SAVE ENCODER ERROR: Could not open file for reading: ", path, " | Error: ", FileAccess.get_open_error())
		return {}

	var content = file.get_as_text()
	file.close()

	if content.strip_edges() == "":
		return {}

	var data_dict = JSON.parse_string(content)
	if typeof(data_dict) == TYPE_DICTIONARY:
		return data_dict
	return {}
