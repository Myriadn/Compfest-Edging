# Compfest Edging

## Overview
Later.

## Project Structure
```lua
compfest-edging/
├── assets/              -- Game assets
│   ├── fonts/           -- Font files
│   ├── images/          -- Image files and sprites
│   └── sounds/          -- Sound effects and music
├── conf/                -- Configuration files
├── lib/                 -- Third-party libraries
├── src/                 -- Source code
│   ├── entities/        -- Game entities
│   ├── states/          -- Game states
│   ├── systems/         -- Game systems
│   └── utils/           -- Utility functions
├── conf.lua             -- Love2D configuration
├── main.lua             -- Entry point
└── README.md            -- This file
```

## Getting Started

### Prerequisites
- [Love2D](https://love2d.org/) version 11.5 or later

## Development Guidelines

### Code Style
- Use PascalCase for class names
- Use camelCase for variables and functions
- Use 4 spaces for indentation
- Add comments to explain complex logic
- Separate code into logical modules

### Git Workflow
1. Create a branch for your feature: `git checkout -b feature/feature-name`
2. Make your changes
3. Commit with meaningful messages: `git commit -m "Add feature X"`
4. Push to your branch: `git push origin feature/feature-name`
5. Create a pull request

## Adding New Content

### Adding a New Entity
1. Create a new file in `src/entities/`
2. Inherit from the base Entity class
3. Implement required methods: `update()`, `draw()`, etc.

### Adding a New Game State
1. Create a new file in `src/states/`
2. Inherit from the base gameState class
3. Implement required methods: `load()`, `update()`, `draw()`, etc.

### Adding Assets
1. Place assets in their respective folders under `assets/`
2. Load assets in the appropriate game state

## License
Later..

## Contributors
@Myriadn, @seymourrisey ,@azwinrx
