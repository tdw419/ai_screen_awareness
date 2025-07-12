extends Control

class_name PXReflexDashboard

# Signals for communicating with other PXOS modules
signal request_analysis()
signal request_trainer() # Future: for triggering the PXReflexTrainer

# === UI Elements ===
onready var output_console = $VBoxContainer/OutputConsole # RichTextLabel for output
onready var input_line_edit = $VBoxContainer/InputContainer/InputLineEdit # LineEdit for user input
onready var send_button = $VBoxContainer/InputContainer/SendButton # Button to send command

onready var analyzed_events_label = $VBoxContainer/DashboardMetrics/AnalyzedEventsLabel
onready var hot_tile_label = $VBoxContainer/DashboardMetrics/HotTileLabel
onready var hot_tile_scores_label = $VBoxContainer/DashboardMetrics/HotTileScoresLabel
onready var common_reflex_label = $VBoxContainer/DashboardMetrics/CommonReflexLabel
onready var last_analysis_time_label = $VBoxContainer/DashboardMetrics/LastAnalysisTimeLabel

# === Lifecycle ===
func _ready():
    # Set up the dashboard's basic appearance
    rect_min_size = Vector2(600, 400) # Increased size for console
    rect_size = Vector2(600, 400) # Initial size
    set_position(Vector2(500, 50)) # Position it on the screen (adjust as needed)
    
    # Add a background panel for better visibility
    var panel = Panel.new()
    panel.set_anchors_preset(Control.PRESET_WIDE) # Make it fill the dashboard
    panel.set_modulate(Color(0, 0, 0, 0.8)) # Semi-transparent black background
    add_child(panel)
    panel.send_to_back() # Ensure labels are on top
    
    # Main VBoxContainer for overall layout
    var main_vbox = VBoxContainer.new()
    main_vbox.set_anchors_preset(Control.PRESET_WIDE, true) # Fill the panel with padding
    main_vbox.set_offset_left(10)
    main_vbox.set_offset_top(10)
    main_vbox.set_offset_right(-10)
    main_vbox.set_offset_bottom(-10)
    add_child(main_vbox)
    
    # --- Dashboard Metrics Section ---
    var metrics_vbox = VBoxContainer.new()
    metrics_vbox.name = "DashboardMetrics"
    main_vbox.add_child(metrics_vbox)

    analyzed_events_label = Label.new()
    analyzed_events_label.name = "AnalyzedEventsLabel"
    analyzed_events_label.set_text("Analyzed Events: N/A")
    analyzed_events_label.add_font_override("font", get_font())
    metrics_vbox.add_child(analyzed_events_label)

    hot_tile_label = Label.new()
    hot_tile_label.name = "HotTileLabel"
    hot_tile_label.set_text("Hot Tile: N/A")
    hot_tile_label.add_font_override("font", get_font())
    metrics_vbox.add_child(hot_tile_label)

    hot_tile_scores_label = Label.new()
    hot_tile_scores_label.name = "HotTileScoresLabel"
    hot_tile_scores_label.set_text("   Scores: G=N/A, R=N/A, I=N/A")
    hot_tile_scores_label.add_font_override("font", get_font(14))
    metrics_vbox.add_child(hot_tile_scores_label)

    common_reflex_label = Label.new()
    common_reflex_label.name = "CommonReflexLabel"
    common_reflex_label.set_text("Common Reflex: N/A")
    common_reflex_label.add_font_override("font", get_font())
    metrics_vbox.add_child(common_reflex_label)
    
    last_analysis_time_label = Label.new()
    last_analysis_time_label.name = "LastAnalysisTimeLabel"
    last_analysis_time_label.set_text("Last Analysis: N/A")
    last_analysis_time_label.add_font_override("font", get_font())
    metrics_vbox.add_child(last_analysis_time_label)

    # Add a separator
    var separator = HSeparator.new()
    separator.set_custom_minimum_size(Vector2(0, 10)) # Some spacing
    main_vbox.add_child(separator)

    # --- Console Output Section ---
    output_console = RichTextLabel.new()
    output_console.name = "OutputConsole"
    output_console.set_v_size_flags(Control.SIZE_EXPAND_FILL) # Take up remaining vertical space
    output_console.set_h_size_flags(Control.SIZE_EXPAND_FILL)
    output_console.set_scroll_follow(true) # Auto-scroll to bottom
    output_console.set_selection_enabled(true)
    output_console.add_font_override("normal_font", get_font(14))
    output_console.add_color_override("default_color", Color(0.8, 0.8, 0.8)) # Light grey text
    main_vbox.add_child(output_console)
    
    # --- Input Section ---
    var input_hbox = HBoxContainer.new()
    input_hbox.name = "InputContainer"
    main_vbox.add_child(input_hbox)

    input_line_edit = LineEdit.new()
    input_line_edit.name = "InputLineEdit"
    input_line_edit.set_h_size_flags(Control.SIZE_EXPAND_FILL)
    input_line_edit.add_font_override("font", get_font(16))
    input_line_edit.add_color_override("font_color", Color(1, 1, 1))
    input_line_edit.add_color_override("font_color_uneditable", Color(0.7, 0.7, 0.7))
    input_line_edit.add_color_override("selection_color", Color(0.2, 0.4, 0.8, 0.5))
    input_line_edit.add_color_override("cursor_color", Color(1, 1, 1))
    input_hbox.add_child(input_line_edit)
    
    send_button = Button.new()
    send_button.name = "SendButton"
    send_button.set_text("Send")
    send_button.add_font_override("font", get_font(16))
    input_hbox.add_child(send_button)

    # Connect signals
    send_button.connect("pressed", self, "_on_SendButton_pressed")
    input_line_edit.connect("text_entered", self, "_on_InputLineEdit_text_entered") # Allow Enter key to send

    _add_response("[PXOS Dashboard] Welcome. Type 'help' for commands.")
    print("PXReflexDashboard initialized with interactive console.")

# Updates the dashboard with new analysis data.
func update_dashboard(report: Dictionary):
    print("[PXReflexDashboard] Updating dashboard with new report.")
    analyzed_events_label.set_text("Analyzed Events: %d" % report.get("analyzed_events", 0))
    hot_tile_label.set_text("Hot Tile: %s (%d events)" % [report.get("hot_tile_name", "N/A"), report.get("hot_tile_count", 0)])
    
    hot_tile_scores_label.set_text("   Scores: G=%.1f, R=%.1f, I=%.2f" % [
        report.get("hot_tile_avg_glitch", 0.0), 
        report.get("hot_tile_avg_repair", 0.0), 
        report.get("hot_tile_avg_instability", 0.0)
    ])

    common_reflex_label.set_text("Common Reflex: %s (%d occurrences)" % [report.get("common_reflex_type", "N/A"), report.get("common_reflex_count", 0)])
    
    var timestamp_dict := OS.get_datetime()
    var time_str := "%02d:%02d:%02d" % [timestamp_dict.hour, timestamp_dict.minute, timestamp_dict.second]
    last_analysis_time_label.set_text("Last Analysis: %s" % time_str)
    
    _add_response("[PXOS Dashboard] Analysis complete.")

# Handles the "Send" button press
func _on_SendButton_pressed():
    _process_input()

# Handles the "Enter" key press in the LineEdit
func _on_InputLineEdit_text_entered(text: String):
    _process_input()

# Processes the user input from the LineEdit
func _process_input():
    var input_text = input_line_edit.text.strip_edges()
    if input_text.empty():
        return

    _add_response("[User] " + input_text) # Echo user input
    input_line_edit.clear() # Clear the input field

    _handle_command(input_text.to_lower()) # Process command (case-insensitive)

# Interprets and executes commands
func _handle_command(cmd: String):
    match cmd:
        "help":
            _add_response("Available commands:")
            _add_response("  'analyze' - Run reflex log analysis.")
            _add_response("  'clear' - Clear console output.")
            _add_response("  'trainer start' - (Future) Start the reflex trainer.")
            _add_response("  'exit' - Close the dashboard (not implemented yet).")
        "analyze":
            emit_signal("request_analysis")
            _add_response("📊 Running analysis...")
        "clear":
            output_console.clear()
            _add_response("Console cleared.")
        "trainer start":
            emit_signal("request_trainer")
            _add_response("🧠 Initiating reflex trainer... (Not yet implemented)")
        _:
            _add_response("❓ Unknown command: '" + cmd + "'. Type 'help' for commands.")

# Appends a response message to the RichTextLabel console.
func _add_response(text: String):
    output_console.append_bbcode(text + "\n")
    output_console.scroll_to_line(output_console.get_line_count() - 1) # Ensure auto-scroll

# Helper to get a default font
func get_font(size: int = 16) -> Font:
    var font = DynamicFont.new()
    var font_data = DynamicFontData.new()
    font.font_data = font_data
    font.size = size
    font.color = Color(1, 1, 1) # White text for visibility on dark background
    return font
