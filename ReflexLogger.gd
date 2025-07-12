extends Node

class_name ReflexLogger

# === Internal State ===
# Buffer to hold log entries before potential flushing to file or zTXt/pxdigest
var log_buffer := []

# === Public Methods ===

# Logs a reflex event with detailed information.
# This method will be called by other modules (e.g., rre_kernel.gd, PXTile_TestGlitch).
func log_event(tile_name: String, region: Rect2, event_type: String, details: String = ""):
    var timestamp_dict := OS.get_datetime()
    # Format timestamp for zTXt key (YYYY-MM-DDTHH:MM:SS)
    var timestamp_key := "%04d-%02d-%02dT%02d:%02d:%02d" % [
        timestamp_dict.year, timestamp_dict.month, timestamp_dict.day,
        timestamp_dict.hour, timestamp_dict.minute, timestamp_dict.second
    ]
    
    # Construct the log message
    var log_message := "%s at %s (Region: %d,%d,%d,%d)" % [
        event_type, tile_name,
        int(region.position.x), int(region.position.y), int(region.size.x), int(region.size.y)
    ]
    if not details.empty():
        log_message += " - " + details

    # Format for zTXt: pxlogs/reflex/{timestamp_key} = "{message}"
    var ztxt_log_line := "pxlogs/reflex/%s = \"%s\"" % [timestamp_key, log_message]
    
    # Add to in-memory buffer
    log_buffer.append(ztxt_log_line)
    
    # Print to console for immediate feedback
    print("[ReflexLogger] ", ztxt_log_line)
    
    # Optional: Persist immediately to a plain text file for fallback/debugging
    _write_to_file("user://pxlogs/reflex_agent.log", ztxt_log_line)
    
    # Future: Implement actual zTXt injection into canvas or .pxdigest export
    _write_to_ztxt_or_pxdigest(ztxt_log_line)

# Returns the entire log buffer. Useful for batch export to .pxdigest.
func get_all_logs() -> Array:
    return log_buffer

# Clears the in-memory log buffer.
func clear_logs():
    log_buffer.clear()
    print("[ReflexLogger] Log buffer cleared.")

# === Private Helper Methods ===

# Writes a single log line to a specified file.
# This is a simple file append for basic persistence.
func _write_to_file(path: String, line: String):
    var file := File.new()
    # Check if the directory exists, create if not (Godot 3.x)
    var dir = Directory.new()
    var dir_path = path.get_base_dir()
    if not dir.dir_exists(dir_path):
        dir.make_dir_recursive(dir_path)
        
    if file.open(path, File.WRITE_READ) == OK:
        file.seek_end() # Move to the end of the file
        file.store_line(line) # Store the line
        file.close()
    else:
        print("[ReflexLogger ERROR] Could not open file for writing: ", path)

# Placeholder for zTXt injection into canvas or .pxdigest export.
# This would involve more complex logic depending on your PXOS architecture.
func _write_to_ztxt_or_pxdigest(ztxt_line: String):
    # In a real PXOS environment, this would interact with the underlying
    # pixel substrate or a .pxdigest manager.
    # For now, we'll just print a placeholder message.
    # Future implementation might look like:
    # get_parent().get_node("PXCanvas").inject_ztxt(ztxt_line)
    # or
    # PXDigestManager.add_entry(ztxt_line)
    # print("[ReflexLogger] (Placeholder) Attempting to write to zTXt/.pxdigest: ", ztxt_line)
    pass # No actual implementation here yet
