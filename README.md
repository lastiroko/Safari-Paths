# Safari Paths

An interactive educational game built with Godot 4.4 that teaches children basic arithmetic and cognitive skills through animal-themed mini-games using the scientifically-proven spaced repetition of gamified challenges.

## About

Safari Paths guides young learners through a series of progressively challenging tasks led by two animal characters — **Monkey** and **Elephant**. Children earn points by completing math problems, sorting exercises, and pattern-matching tasks, reinforcing foundational skills through play.

### Game Flow

```
Welcome Page → Monkey Level (2 tasks) → Level Transition → Elephant Level (2 tasks) → End Scene
```

## Features

- **Four Educational Mini-Games** — Addition, Subtraction, Fruit Sorting, and Letter-Color Matching
- **Two Themed Levels** — Monkey Level and Elephant Level, each with unique tasks
- **Progressive Scoring System** — earn up to 1,400 points across all tasks
- **Audio & Visual Feedback** — background music, sound effects, and animated character expressions
- **Restart Support** — replay the entire game with a full state reset

## Mini-Games

| Task | Level | Type | Description |
|------|-------|------|-------------|
| Addition | Monkey | Math | Solve random addition problems (numbers 1–5) with multiple choice |
| Fruit Sorting | Monkey | Classification | Identify and pick ripe fruits from a grid |
| Letter Matching | Elephant | Pattern Matching | Match 5 letters to their corresponding colors |
| Subtraction | Elephant | Math | Solve random subtraction problems with multiple choice |

## Tech Stack

- **Engine:** Godot 4.4
- **Language:** GDScript
- **Rendering:** GL Compatibility
- **Testing:** GUT (Godot Unit Testing)
- **Resolution:** 1200 x 650 px

## Prerequisites

- [Godot 4.4](https://godotengine.org/download/) or higher

## Getting Started

### Clone the repository

```bash
git clone https://github.com/lastiroko/Safari-Paths.git
cd Safari-Paths
```

### Run the game

1. Open Godot 4.4
2. Click **Import** and select the `project.godot` file
3. Press **F5** or click the **Play** button to run

### Run tests

Tests use the GUT addon (included in `addons/gut/`). Open the project in Godot and run the test scenes from the GUT panel.

## Project Structure

```
├── scripts/
│   ├── globals/
│   │   └── GameManager.gd         # Global state manager (points, audio, game state)
│   ├── levels/
│   │   ├── Welcome_Page.gd        # Main menu
│   │   ├── Monkey_Level.gd        # Monkey level controller
│   │   ├── Elephant_Level.gd      # Elephant level controller
│   │   ├── level_transition.gd    # Between-level transition
│   │   └── end_scene.gd           # Game completion screen
│   └── tasks/
│       ├── addition_task.gd       # Addition mini-game
│       ├── fruit_sort_task.gd     # Fruit sorting mini-game
│       ├── Match_Letters_Task.gd  # Letter-color matching mini-game
│       └── Subtraction_Task.gd    # Subtraction mini-game
├── scenes/                        # Godot scene files (.tscn)
├── assets/                        # Audio, images, fonts
├── tests/                         # Unit, integration, system, and performance tests
├── documentation/                 # Project documentation (PDFs)
└── project.godot                  # Godot project configuration
```

## Architecture

The game follows a **scene-based MVC architecture** with signal-driven communication:

- **GameManager** (Singleton) — global state, points, and audio management
- **Level Controllers** — manage character animations, HUD, and task loading
- **Task Scripts** — self-contained mini-game logic that emit `task_completed` signals
- **Scenes** — UI layouts defined in `.tscn` files

## Testing

The project includes a comprehensive test suite:

| Type | Coverage |
|------|----------|
| **Unit** | Individual task logic, GameManager state |
| **Integration** | Scene transitions, audio system, multi-system interaction |
| **System / E2E** | Full gameplay flow (0 → 1,400 points) |
| **Error Handling** | Null references, edge cases |
| **Regression** | Known bug fixes |
| **Performance** | Benchmark validation |

## Documentation

Detailed project documentation is available in the `documentation/` directory:

- Project Documentation
- Requirements Documentation
- Architectural Documentation
- Test Documentation
- User Documentation
- Acceptance Documentation

## Team

Developed by **SDI Blue Whales** — Software Engineering, SoSe 2025
