extends Node2D # Or TextureRect, ViewportContainer, depending on your setup

class_name PXCanvas

# This node represents the "pixel substrate" or the active canvas
# that can have zTXt metadata injected into it.
# In a full PXOS, this would manage the actual 8.png or similar pixel data.

# A dictionary to store the zTXt metadata associated with this canvas.
# In a real system, this would be tied to the actual PNG data and saved/loaded with it.
var ztxt_metadata := {}

func _ready():
    print("PXCanvas initialized. Ready to receive zTXt injections.")
    # In a real PXOS, you might load existing zTXt metadata from a loaded 8.png here.
    # _load_ztxt_from_image_source()

# This method is called by ReflexLogger to inject zTXt data.
func inject_ztxt(ztxt_line: String):
    # Parse the ztxt_line (e.g., "pxlogs/reflex/timestamp = "message"")
    var parts = ztxt_line.split(" = \"", true, 1)
    if parts.size() == 2:
        var key = parts[0]
        var value = parts[1].replace("\"", "") # Remove trailing quote
        ztxt_metadata[key] = value
        print("[PXCanvas] Stored zTXt in memory: ", key, " = ", value)
        
        # --- IMPORTANT: Actual PNG zTXt injection is complex ---
        # Godot's built-in Image.save_png() does not directly support
        # injecting tEXt/zTXt chunks into the PNG metadata.
        # To achieve true zTXt injection into a PNG file, you would typically need:
        # 1. A custom Godot C++ module that wraps a PNG library (like libpng)
        #    to manipulate chunks.
        # 2. An external command-line tool (e.g., `pngcrush`, `exiftool`)
        #    called via `OS.execute()` after saving the PNG.
        # 3. If PXOS is exported to HTML5, JavaScript on the browser side could
        #    use `canvas.toDataURL()` and then a specialized JS library to add PNG chunks.
        #
        # For this conceptual implementation, we are storing it in an in-memory dictionary.
        # The next step would be to figure out how to persistently save this metadata
        # alongside the visual state (e.g., when saving the 8.png).
        # _update_png_with_ztxt() # This function would trigger the actual PNG write
    else:
        print("[PXCanvas ERROR] Invalid zTXt format received: ", ztxt_line)

# Placeholder for saving the canvas content as a PNG with zTXt metadata.
func save_canvas_with_ztxt(path: String):
    print("[PXCanvas] (Placeholder) Saving canvas to ", path, " with zTXt metadata.")
    print("[PXCanvas] Current zTXt metadata to be saved: ", ztxt_metadata)
    # Here, you would implement the logic to:
    # 1. Capture the current visual state of the canvas (e.g., from a Viewport).
    # 2. Save it as a PNG.
    # 3. Inject the `ztxt_metadata` dictionary into the PNG's tEXt/zTXt chunks.

# Placeholder for loading zTXt metadata from an image source.
func _load_ztxt_from_image_source():
    # If this canvas is displaying an 8.png, this would parse its zTXt chunks
    # upon loading the image. This also requires custom implementation.
    print("[PXCanvas] (Placeholder) Loading zTXt from image source.")
