extends Node

class_name PXReflexTrainer

# === Exported Parameters ===
# The instability score threshold above which a tile is considered "unstable"
export var instability_threshold := 5.0 

# === Internal References ===
var _reflex_logger = null # Reference to the ReflexLogger for logging trainer actions
var _px_mutator = null    # Reference to the PXMutator for triggering regeneration
var _px_canvas = null     # Reference to the PXCanvas for pixel rendering

# === Visual Reporting Parameters ===
export var trainer_text_start_x := 10 # X position for trainer messages on canvas
export var trainer_text_start_y := 300 # Y position for trainer messages on canvas
export var trainer_text_line_height := 10 # Height per line of trainer text
var _current_trainer_line := 0 # Tracks current line for sequential messages

func _ready():
    # Attempt to get a reference to the ReflexLogger
    _reflex_logger = get_node_or_null("/root/PXOSMain/ReflexLogger") # Adjust path as needed
    if _reflex_logger:
        print("[PXReflexTrainer] Found ReflexLogger.")
    else:
        print("[PXReflexTrainer ERROR] ReflexLogger node not found. Trainer logging will be limited.")

    # Attempt to get a reference to the PXMutator
    _px_mutator = get_node_or_null("/root/PXOSMain/PXMutator") # Adjust path as needed
    if _px_mutator:
        print("[PXReflexTrainer] Found PXMutator.")
    else:
        print("[PXReflexTrainer ERROR] PXMutator node not found. Automatic mutation will not function.")

    # Attempt to get a reference to the PXCanvas
    _px_canvas = get_node_or_null("/root/PXOSMain/PXCanvas") # Adjust path as needed
    if _px_canvas:
        print("[PXReflexTrainer] Found PXCanvas for visual reporting.")
    else:
        print("[PXReflexTrainer ERROR] PXCanvas node not found. Visual reporting will not function.")

    print("PXReflexTrainer initialized. Instability Threshold: ", instability_threshold)

# Main method to start the training/evaluation cycle.
# 'tile_nodes' should be an array of PXTile_TestGlitch (or similar) nodes.
func start_training(tile_nodes: Array):
    _current_trainer_line = 0 # Reset line counter for new cycle
    _report_to_canvas("--- Trainer Cycle Start ---", Color(0.8, 0.5, 0)) # Orange
    print("\n--- [PXReflexTrainer] Initiating training cycle ---")
    if tile_nodes.empty():
        _report_to_canvas("No tiles for evaluation.", Color(1,0,0)) # Red
        print("[PXReflexTrainer] No tiles provided for evaluation.")
        if _reflex_logger:
            _reflex_logger.log_event("Trainer", Rect2(), "training_cycle_skipped", "No tiles to evaluate.")
        return

    for tile in tile_nodes:
        if tile and tile.has_method("get_reflex_scores"):
            var scores = tile.get_reflex_scores()
            var glitch_count = scores.get("glitch_count", 0)
            var repair_count = scores.get("repair_count", 0)
            var instability = 0.0
            
            # Calculate instability: glitch_count / (repair_count + 1) to avoid division by zero
            if repair_count >= 0:
                instability = float(glitch_count) / (repair_count + 1.0)
            else:
                instability = float(glitch_count) # If repair_count is somehow negative, just use glitch_count

            if instability > instability_threshold:
                _report_to_canvas("⚠️ UNSTABLE: %s (I:%.2f)" % [tile.name, instability], Color(1, 0, 0)) # Red
                print("[PXReflexTrainer] ⚠️ Tile '%s' is UNSTABLE! (G:%d, R:%d, I:%.2f)" % [tile.name, glitch_count, repair_count, instability])
                _suggest_action(tile, instability, "unstable")
            else:
                _report_to_canvas("✅ STABLE: %s (I:%.2f)" % [tile.name, instability], Color(0, 1, 0)) # Green
                print("[PXReflexTrainer] ✅ Tile '%s' is stable. (G:%d, R:%d, I:%.2f)" % [tile.name, glitch_count, repair_count, instability])
                _suggest_action(tile, instability, "stable")
        else:
            _report_to_canvas("WARNING: Skipping node (invalid tile).", Color(1,0.5,0)) # Orange
            print("[PXReflexTrainer WARNING] Skipping node: '%s' (not a valid tile or missing get_reflex_scores)." % tile.name)
            
    _report_to_canvas("--- Trainer Cycle End ---", Color(0.8, 0.5, 0)) # Orange
    print("--- [PXReflexTrainer] Training cycle complete ---\n")
    if _reflex_logger:
        _reflex_logger.log_event("Trainer", Rect2(), "training_cycle_completed")

# Suggests an action based on tile instability.
# This is where the AI's adaptive logic would reside.
func _suggest_action(tile_node: Node, instability_score: float, status: String):
    var action_details = ""
    if status == "unstable":
        action_details = "Suggesting regeneration."
        if _px_mutator:
            _px_mutator.regenerate_tile(tile_node) # Call the mutator
            action_details += " (Mutation Requested)"
        else:
            action_details += " (PXMutator not found, cannot mutate)"
    else:
        action_details = "Maintaining current state."

    _report_to_canvas("  Action: %s" % action_details, Color(0.5, 0.5, 1)) # Light blue
    print("[PXReflexTrainer] Action for '%s': %s" % [tile_node.name, action_details])
    
    if _reflex_logger:
        _reflex_logger.log_event(
            "Trainer", 
            tile_node.get_rect(), 
            "tile_evaluated", 
            "Status: %s, Instability: %.2f. Action: %s" % [status, instability_score, action_details],
            tile_node # Pass the tile node for its scores to be logged
        )

# Reports messages directly to the PXCanvas using pixel font.
func _report_to_canvas(message: String, color: Color = Color(0,0,0)): # Default to black text
    if _px_canvas:
        var y_pos = trainer_text_start_y + (_current_trainer_line * trainer_text_line_height)
        # Clear the line before writing new text (draw white rectangle)
        _px_canvas.draw_rect_on_image(Rect2(trainer_text_start_x, y_pos, _px_canvas.rect_size.x - trainer_text_start_x - 10, trainer_text_line_height), Color(1,1,1,1))
        _px_canvas.write_text_px(message, trainer_text_start_x, y_pos, 1, 1, color, Color(1,1,1))
        _current_trainer_line += 1
        # If we go too far down, clear the area or scroll (for now, just print warning)
        if y_pos + trainer_text_line_height > _px_canvas.rect_size.y - 10:
            print("[PXReflexTrainer WARNING] Trainer text exceeding canvas height. Consider clearing or scrolling.")
            # Future: Implement scrolling or clearing a larger area
    else:
        print("[PXReflexTrainer] Cannot report to canvas (PXCanvas not found). Message: ", message)

