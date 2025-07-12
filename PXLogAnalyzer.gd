extends Node

class_name PXLogAnalyzer

# === Public Method ===

func analyze_digest(path: String):
	var file := File.new()
	if file.file_exists(path):
		file.open(path, File.READ)
		var json_str := file.get_as_text()
		file.close()
		
		var parsed = JSON.parse(json_str)
		if parsed.error != OK:
			print("[PXLogAnalyzer ERROR] Failed to parse JSON.")
			return
		_process_log_entries(parsed.result.entries)
	else:
		print("[PXLogAnalyzer] .pxdigest not found: ", path)

# === Internal Processing ===

func _process_log_entries(entries: Array):
	var tile_counts := {}
	var event_types := {}
	var timestamps := []
	
	for entry in entries:
		var key = entry["key"]
		var value = entry["value"]
		var tile = _extract_tile_from(value)
		var reflex = _extract_reflex_from(value)
		var ts = key.replace("pxlogs/reflex/", "")
		timestamps.append(ts)

		# Count per tile
		if tile in tile_counts:
			tile_counts[tile] += 1
		else:
			tile_counts[tile] = 1

		# Count reflex types
		if reflex in event_types:
			event_types[reflex] += 1
		else:
			event_types[reflex] = 1

	# 🔎 Output summary
	print("[PXLogAnalyzer]")
	print("🧠 Analyzed %d reflex events" % entries.size())
	print("🔥 Hot Tile: ", _max_key(tile_counts), " (%d events)" % tile_counts[_max_key(tile_counts)])
	print("🔁 Most common reflex: ", _max_key(event_types), " (%d occurrences)" % event_types[_max_key(event_types)])
	print("📈 Timestamps:", timestamps)

func _extract_tile_from(msg: String) -> String:
	var parts = msg.split(" at ")
	return parts.size() > 1 ? parts[1].split(" ")[0] : "Unknown"

func _extract_reflex_from(msg: String) -> String:
	if msg.find("repaired via") != -1:
		return msg.split("repaired via ")[1]
	return "unknown"

func _max_key(dict: Dictionary) -> String:
	var max_k = ""
	var max_v = -1
	for k in dict.keys():
		if dict[k] > max_v:
			max_v = dict[k]
			max_k = k
	return max_k
