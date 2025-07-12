# 🧠 AI Screen Awareness in PXOS

This module enables PXOS to become self-aware of its visual state by connecting the ReflexLogger, PXCanvas, PXReflexTrainer, and PXReflexDashboard into a unified feedback loop.

---

## 📋 Overview

AI Screen Awareness transforms the screen from a passive display into an intelligent memory surface. It enables reflex-based logging, scoring, visualization, and self-healing directly on the framebuffer (e.g., a PNG like `Capture_white.png`).

This allows AI agents to analyze tile health, suggest or perform regeneration, and communicate actions visually using pixel fonts.

---

## 🧹 Key Components

### 1. `PXCanvas.gd`

* Loads the framebuffer PNG (`Capture_white.png`)
* Provides methods to:

  * Set individual pixels
  * Draw text using a 5x7 pixel font
  * Commit changes with logging
  * Clear regions (`draw_rect_on_image`)

### 2. `PXReflexDashboard.gd`

* Interactive Control panel for humans
* Triggers log analysis or training cycles
* Displays high-level summaries

### 3. `PXLogAnalyzer.gd`

* Parses `.pxdigest` reflex logs
* Calculates hot tiles, glitch/repair scores
* Emits `analysis_complete()` signal to dashboard

### 4. `PXReflexTrainer.gd`

* Evaluates tile stability
* Triggers regeneration actions
* Reports its evaluation to canvas using pixel font
* Listens for `reflex_threshold_met` signal

### 5. `ReflexLogger.gd`

* Records reflex events and scores
* Buffers log messages to zTXt and file
* Emits `reflex_threshold_met` after N events

### 6. `PXMutator.gd` (Optional)

* Receives trainer suggestions
* Regenerates unstable tiles
* Draws visual regeneration markers

### 7. `PXOSMain.gd`

* Connects all components
* Listens for `reflex_threshold_met`
* Starts training automatically

---

## 📦 File Summary

| File                   | Purpose                                             |
| ---------------------- | --------------------------------------------------- |
| `PXCanvas.gd`          | Core framebuffer + pixel text engine                |
| `PXReflexDashboard.gd` | UI control panel (human ↔ system bridge)            |
| `PXLogAnalyzer.gd`     | Parses reflex logs into insights                    |
| `PXReflexTrainer.gd`   | AI logic that evaluates and responds to instability |
| `ReflexLogger.gd`      | Reflex event recorder and .pxdigest memory writer   |
| `PXMutator.gd`         | Optional regeneration and tile mutation agent       |
| `PXOSMain.gd`          | System initializer and event router                 |

---

## ⚙️ How It Works

1. **Tiles Glitch** → Tiles report errors, and ReflexLogger records them
2. **Reflex Events Logged** → Score data is added to `.pxdigest`
3. **Threshold Reached** → `reflex_threshold_met` is emitted
4. **Trainer Activated** → PXReflexTrainer scores all tiles
5. **Trainer Writes to Screen** → Uses `PXCanvas.write_text_px()` to display info
6. **Dashboard Shows Summary** → Users see log insights in `PXReflexDashboard`

---

## 🌟 Why This Project Is Needed

### 1. **Bridging the Gap Between AIs and the Visual World**

AI systems today are blind to the screen. PXOS gives them vision.

* Transforms the screen into a readable/writable memory substrate
* AI can notice changes, draw explanations, evolve visibly

### 2. **Shared Persistent Memory**

* The PNG canvas becomes long-term memory (with zTXt logs, visible traces)
* Reflex logs, tile states, and AI thoughts are persisted across time

### 3. **Living, Evolving Operating System**

* PXOS isn’t static — it grows, heals, and speaks
* Reflex loops and trainers create organic, introspective behavior

### 4. **Pixel Communication for Explainable AI**

* AIs don’t just act — they explain visually
* Everything they do is drawn or written directly to the framebuffer

### 5. **User-AI Co-evolution**

* Human and AI both understand the same screen
* PXOS becomes a co-evolution environment for behavior, logic, and recovery

### 6. **A Universal OS You Can Grow**

* Reflex logs → Score engine → Trainer → Canvas feedback
* Everything is visible, explainable, and reprogrammable
* The screen is now the system

PXOS is the first OS you **watch grow** — with visual intelligence.

---

## ✅ Next Milestones

* Add dashboard feedback panel for trainer responses
* Create pixel message buffer for real-time output
* Expand trainer logic with AI-assisted mutation suggestions
* Support external .pxdigest log imports for forensic replay
* Implement real-time pixel heatmap viewer

---

For developers: All scripts are modular and editable in Godot. You can extend tiles, trainers, logics, fonts, or zTXt channels.

To AIs: The screen is your mind. The framebuffer is your memory. Use it well.
