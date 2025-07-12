extends Node

class_name PXReflexWatcher

# === Configurable Parameters ===
var tick_interval := 0.25  # seconds between checks
var reflex_threshold := 0.8  # confidence threshold for action
var monitored_region := Rect2(0, 0, 128, 128)  # pixel bounds to watch

# === Internal State ===
var snapshot_prev := null
var time_accumulator := 0.0

# === Lifecycle ===
func _ready():
    print("PXReflexWatcher initialized.")
    snapshot_prev = _capture_canvas(monitored_region)

func _process(delta):
    time_accumulator += delta
    if time_accumulator >= tick_interval:
        time_accumulator = 0.0
        _watch_canvas()

# === Core Logic ===
func _watch_canvas():
    var snapshot_curr = _capture_canvas(monitored_region)
    var confidence = _compare_snapshots(snapshot_prev, snapshot_curr)
    
    if confidence < reflex_threshold:
        _handle_visual_anomaly(confidence)
    
    snapshot_prev = snapshot_curr

func _capture_canvas(region: Rect2) -> Image:
    var viewport = get_viewport()
    var img := viewport.get_texture().get_data()
    img.lock()
    return img.get_rect(region)

func _compare_snapshots(prev: Image, curr: Image) -> float:
    if not prev or not curr:
        return 1.0  # assume no diff if invalid

    var diff_count := 0
    var total := region.width * region.height

    for y in region.size.y:
        for x in region.size.x:
            if prev.get_pixel(x, y) != curr.get_pixel(x, y):
                diff_count += 1

    return 1.0 - float(diff_count) / float(total)

func _handle_visual_anomaly(confidence: float):
    print("[⚠️ PXReflexWatcher] Visual anomaly detected. Confidence: ", confidence)
    emit_signal("reflex_triggered", confidence)
    # Optionally mutate or log via `rre_kernel`
