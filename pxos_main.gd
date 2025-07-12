extends Node2D # Or Control, depending on your root node type

# This script manages the main PXOS scene and connects its components.

onready var px_log_analyzer = $PXLogAnalyzer # Assuming PXLogAnalyzer is a child
onready var px_reflex_dashboard = $PXReflexDashboard # Assuming PXReflexDashboard is a child
onready var px_reflex_trainer = $PXReflexTrainer # Assuming PXReflexTrainer is a child
onready var reflex_logger = $ReflexLogger # Assuming ReflexLogger is a child

func _ready():
    print("PXOSMain scene initialized.")
    
    # Connect dashboard signals to appropriate handlers
    if px_reflex_dashboard:
        px_reflex_dashboard.connect("request_analysis", self, "_on_dashboard_request_analysis")
        px_reflex_dashboard.connect("request_trainer", self, "_on_dashboard_request_trainer")
    else:
        print("[PXOSMain ERROR] PXReflexDashboard node not found.")

    # Connect ReflexLogger signal for auto-triggering trainer
    if reflex_logger:
        reflex_logger.connect("reflex_threshold_met", self, "_on_reflex_threshold_met")
    else:
        print("[PXOSMain ERROR] ReflexLogger node not found.")

# Handler for the dashboard's request_analysis signal
func _on_dashboard_request_analysis():
    if px_log_analyzer:
        px_log_analyzer.analyze_digest("user://pxdigest/pxlogs_reflex.pxdigest")
    else:
        print("[PXOSMain ERROR] Cannot run analysis: PXLogAnalyzer not available.")

# Handler for the dashboard's request_trainer signal
func _on_dashboard_request_trainer():
    print("[PXOSMain] Received request to start trainer.")
    if px_reflex_trainer:
        var tile_nodes = []
        for child in get_children(): # Iterate through direct children of PXOSMain
            if child is PXTile_TestGlitch: # Check if it's an instance of your test tile class
                tile_nodes.append(child)
        
        px_reflex_trainer.start_training(tile_nodes)
    else:
        print("[PXOSMain ERROR] PXReflexTrainer not available.")

# Handler for the reflex_threshold_met signal from ReflexLogger
func _on_reflex_threshold_met(current_event_count: int):
    print("[PXOSMain] Auto-triggering trainer due to reflex threshold met (%d events)." % current_event_count)
    # Automatically start the trainer
    _on_dashboard_request_trainer() # Reuse the existing trainer start logic
