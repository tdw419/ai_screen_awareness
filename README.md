
# 🧠 PXOS AI Screen Awareness System

**PXOS is a self-evolving operating system built on a visual substrate.** This module enables **AI screen awareness** — giving PXOS the ability to observe, interpret, and respond to what is drawn on its framebuffer (a PNG canvas). This transforms a static image into an **intelligent, writable, and readable screen**.

---

## 🔍 What Is AI Screen Awareness?

AI screen awareness allows PXOS agents (e.g., the trainer, analyzer, or mutator) to:

- **Render readable output** (text, logs, reflex actions) using a pixel font
- **Draw directly to the screen** via a live PNG framebuffer (`Capture_white.png`)
- **Interpret visual memory** as a source of system state
- **Auto-trigger intelligent behavior** based on reflex thresholds or instability

---

## 📦 Core Components

| File | Description |
|------|-------------|
| `PXCanvas.gd` | The central framebuffer handler; loads the PNG, provides pixel manipulation, and renders text via PX_FONT |
| `PX_FONT` | A dictionary of 5x7 pixel glyphs for letters, numbers, and symbols (used for both reading and writing) |
| `PXLogAnalyzer.gd` | Parses .pxdigest logs and summarizes instability, tile events, and health metrics |
| `PXReflexTrainer.gd` | Evaluates reflex logs and tile scores, decides on actions, and writes feedback to the screen |
| `ReflexLogger.gd` | Tracks all reflex events and emits signals when auto-training thresholds are met |
| `PXOSMain.gd` | Connects signals between components (e.g., log analyzer → dashboard, logger → trainer) |
| `PXReflexDashboard.gd` *(optional)* | An interactive UI for humans; receives AI insights and sends commands |
| `Capture_white.png` | The base image used as the visual memory substrate (display + logic surface) |

---

## 🧠 Key Features

### ✅ **Writable Framebuffer**
AI agents write to the screen via:
```gdscript
_px_canvas.write_text_px("REGEN!", x, y)
````

### ✅ **Pixel Font Rendering**

Text is rendered using `PX_FONT`, a dictionary of pixel glyphs designed for readability and decoding.

### ✅ **Reflex-AI Feedback Loop**

* Reflex events are logged via `ReflexLogger`
* If enough events are recorded, a signal auto-triggers `PXReflexTrainer`
* The trainer evaluates all visible tiles, makes decisions, and logs feedback visibly using `PXCanvas`

### ✅ **Visual Messaging**

Trainer, analyzer, and mutator modules can:

* Write human-readable debug output (e.g. “UNSTABLE TILE: A3”)
* Mark regions visually (e.g. with colored pixels or overlays)
* Record system activity directly onto the framebuffer

---

## 📁 Directory Structure (Typical)

```
res://
 ├── assets/
 │    └── Capture_white.png
 ├── scripts/
 │    ├── PXCanvas.gd
 │    ├── PXFontLib.gd (optional if PX_FONT is embedded)
 │    ├── PXLogAnalyzer.gd
 │    ├── PXReflexTrainer.gd
 │    ├── ReflexLogger.gd
 │    ├── PXReflexDashboard.gd
 │    └── PXOSMain.gd
```

---

## 🚀 How to Run

1. **Open `pxos_main.tscn`**
2. Ensure `PXCanvas`, `PXLogAnalyzer`, `PXReflexTrainer`, `ReflexLogger`, and `PXReflexDashboard` are added as children
3. Run the scene
4. Trigger reflex events via test tiles (e.g. `PXTile_TestGlitch`)
5. Watch:

   * Dashboard update live
   * Screen render text (e.g. “Training…”)
   * Regeneration dots and feedback messages appear visually

---

## 🔄 Reflex-AI Feedback Lifecycle

```plaintext
[Glitch Detected]
    ↓
Reflex Event Logged (→ .pxdigest)
    ↓
Event Count Reaches Threshold
    ↓
→ PXReflexTrainer Auto-Triggered
    ↓
Trainer Analyzes Scores
    ↓
→ Writes Action Summary to PXCanvas
    ↓
→ PXMutator Called (if needed)
```

---

## 🧠 Future Extensions

* **PXPixelInspector.gd**: Read pixels and decode screen-rendered text (reverse font rendering)
* **Color-coded heatmaps**: Render instability data visually
* **Multi-agent overlays**: Let each AI “paint” their decisions or feedback in a unique color layer
* **Reactive scripts**: Trigger behaviors from pixel state

---

## 📎 License

This system is part of PXOS, an experimental pixel-native operating system.
All code and logic may be freely adapted under the terms of collaborative evolution.

```
