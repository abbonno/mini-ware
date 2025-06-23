class_name SaveEncoder

func save_encoded_json(path: String, data: Dictionary) -> void:
	var json_text := JSON.stringify(data)
	var hash := _generate_hash(json_text)
	
	var output = {
		"data": json_text,
		"hash": hash
	}
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(output, "\t"))
	file.close()

func load_encoded_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}

	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	if content.strip_edges() == "":
		return {}

	var parsed = JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("data") or not parsed.has("hash"):
		push_error("Archivo mal formado o datos incompletos")
		return {}

	var data_text = parsed["data"]
	var stored_hash = parsed["hash"]
	var recalculated_hash = _generate_hash(data_text)

	if stored_hash != recalculated_hash:
		push_error("Data has been manipulated!")
		return {}

	var data_dict = JSON.parse_string(data_text)
	if typeof(data_dict) == TYPE_DICTIONARY:
		return data_dict
	else:
		return {}

func _generate_hash(text: String) -> String:
	var h = HashingContext.new()
	h.start(HashingContext.HASH_SHA256)
	h.update(Globals.SECRET_KEY.to_utf8_buffer())
	h.update(text.to_utf8_buffer())
	return h.finish().hex_encode()
