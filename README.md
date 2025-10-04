# Behavior

A Swift behavior tree implementation for real-time game AI and interactive applications.

## Overview

Behavior trees are hierarchical structures used to model complex decision-making logic. This package provides a clean, declarative API for building behavior trees using Swift's result builders, making it easy to create sophisticated AI behaviors for games and interactive applications.

## Features

- **Clean DSL Syntax** - Build behavior trees using Swift result builders
- **Generic Context** - Use any type as context for your behaviors
- **Comprehensive Task Library** - Includes all standard behavior tree nodes
- **Time-based Execution** - Built-in support for time deltas and frame-based ticking
- **State Caching** - Automatic state management to avoid redundant execution
- **Modular Trees** - Reference and reuse subtrees across your behavior

## Quick Start

```swift
import Behavior

// Define your context - this can be any type that holds state
struct GameEntity {
    var health: Int
    var position: Vector2
    var target: GameEntity?
}

// Create a behavior tree using the declarative DSL
let behavior = Behavior(for: entity) {

    // Root tree - the entry point, executed on every tick
    Tree("Root") {
        Sequence {
            // Check if entity is alive
            Condition { $0.health > 0 }

            // Try to attack, if that fails then flee
            Fallback {
                Subtree("Attack")  // References the "Attack" tree below
                Subtree("Flee")    // Runs if "Attack" fails
            }
        }
    }

    // Attack tree - finds and attacks a target
    Tree("Attack") {
        Sequence {
            FindTarget()      // Must succeed to continue
            MoveToTarget()    // Must succeed to continue
            DealDamage()      // Final action
        }
    }

    // Flee tree - finds safety and moves there
    Tree("Flee") {
        Sequence {
            FindSafeSpot()    // Find somewhere safe
            MoveTo()          // Move to that location
        }
    }
}

// Execute the behavior tree each frame with timing information
let time = BehaviorTime(
    elapsed: deltaTime,                   // Time since last frame
    accumulated: totalTime,               // Total time behavior has run
    actual: Date().timeIntervalSince1970  // Current timestamp
)
behavior.tick(time: time)
```

## Core Concepts

### Behavior

The `Behavior` class is the main entry point. It manages a collection of named trees and executes them each tick.

### Trees

Trees are named collections of tasks that can be referenced and reused. Every behavior requires a root tree named `"Root"`.

### Tasks

Tasks are the building blocks of behavior trees. They return one of three states:
- `.running` - Task is still executing
- `.succeeded` - Task completed successfully
- `.failed` - Task completed with failure

## Available Tasks

### Composite Tasks

- **Sequence** - Executes children in order until one fails
- **Fallback** - Tries children in order until one succeeds
- **Parallel** - Runs all children simultaneously, fails if any fail
- **Race** - Runs all children simultaneously, succeeds on first success

### Control Flow

- **Tree** - Named tree definition for modular design
- **Subtree** - References another tree by name
- **While** - Repeats while a condition succeeds
- **Repeat** - Repeats a sequence N times or infinitely

### Decorators

- **Not** - Inverts the child's result
- **Mute** - Always succeeds regardless of child result
- **Wait** - Waits for a duration or tick count
- **Retry** - Retries a failed task up to N times
- **Timeout** - Fails if child exceeds time limit
- **Cooldown** - Prevents re-execution for a duration

### Utility Tasks

- **Condition** - Evaluates a boolean closure
- **Action** - Executes a closure returning a state
- **Log** - Logs a message and succeeds
- **Random** - Randomly selects one child (with optional weights)

### Control Tasks

- **Succeed** - Always succeeds immediately
- **Fail** - Always fails immediately
- **Run** - Always returns running
- **SucceedParent** - Forces a tagged parent to succeed
- **FailParent** - Forces a tagged parent to fail

## Custom Tasks

Create custom tasks by subclassing `BehaviorTask`:

```swift
class FindTarget<Context: GameEntity>: BehaviorTask<Context> {
    override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        guard let target = findNearestEnemy(to: context) else {
            return .failed
        }
        context.target = target
        return .succeeded
    }
}
```

## Advanced Features

### Tagging

Tag tasks to reference them from child tasks:

```swift
While(SomeCondition()) {
    Fallback {
        SomeTask()
        SucceedParent("loop")  // Exits the While loop
    }
}.tag("loop")
```

### Weighted Random Selection

```swift
Random(weights: [0.6, 0.3, 0.1]) {
    CommonAction()     // 60% chance
    UncommonAction()   // 30% chance
    RareAction()       // 10% chance
}
```

### Time-based Actions

```swift
Action { context, time in
    context.position.x += speed * time.elapsed
    return context.position.x >= target ? .succeeded : .running
}
```

## Platform Support

- iOS 15.0+
- macOS 12.0+
- tvOS 15.0+
- visionOS 1.0+

## Requirements

- Swift 5.10+
- Xcode 15.0+

## License

This package is available under the BSD Zero Clause License. See the LICENSE file for more information.
