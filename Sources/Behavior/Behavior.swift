import Foundation

/// A string identifier for naming behavior trees.
public typealias BehaviorTreeName = String

/// A behavior tree execution engine that manages the execution of hierarchical task trees.
///
/// The `Behavior` class is the main entry point for creating and running behavior trees.
/// It manages a collection of named trees, executes the root tree, and tracks the overall state.
///
/// ## Overview
///
/// Behavior trees are hierarchical structures used to model complex decision-making logic,
/// commonly used in game AI. The tree is executed by calling ``tick(time:)`` each frame,
/// which processes the tree from the root down through its children.
///
/// ## Usage
///
/// ```swift
/// let behavior = Behavior(for: gameEntity) {
///     Tree("Root") {
///         Sequence {
///             FindTarget()
///             MoveToTarget()
///             Attack()
///         }
///     }
/// }
///
/// // Each frame:
/// let time = BehaviorTime(elapsed: deltaTime, accumulated: totalTime, actual: currentTime)
/// behavior.tick(time: time)
/// ```
public class Behavior<Context> {

    /// The context object passed to all tasks during execution.
    public let context: Context

    /// The root tree that is executed when the behavior ticks.
    public let root: Tree<Context>

    /// A dictionary of all named trees in this behavior.
    public let trees: [BehaviorTreeName: Tree<Context>]

    /// The number of times the root tree should be executed.
    public let iterations: BehaviorIterations

    private let repeater: Repeat<Context>

    /// The current state of the behavior.
    ///
    /// If the `state` is `nil`, the behavior has not started running yet.
    public private(set) var state: BehaviorState?

    /// Creates a behavior with a pre-defined dictionary of trees.
    ///
    /// - Parameters:
    ///   - context: The context object available to all tasks.
    ///   - root: The name of the root tree to execute (default: "Root").
    ///   - iterations: How many times to execute the root tree (default: once).
    ///   - trees: A dictionary mapping tree names to tree instances.
    public init?(
        for context: Context,
        root: BehaviorTreeName = "Root",
        iterations: BehaviorIterations = .count(1),
        trees: [BehaviorTreeName: Tree<Context>]
    ) {
        self.context = context
        self.iterations = iterations
        self.trees = trees
        let tree = trees[root] ?? Tree(root) { Fail() }
        self.root = tree
        repeater = Repeat(iterations, [tree])
    }

    /// Creates a behavior using a result builder to define trees.
    ///
    /// - Parameters:
    ///   - context: The context object available to all tasks.
    ///   - root: The name of the root tree to execute (default: "Root").
    ///   - iterations: How many times to execute the root tree (default: once).
    ///   - builder: A result builder closure that returns a dictionary of trees.
    public init?(
        for context: Context,
        root: BehaviorTreeName = "Root",
        iterations: BehaviorIterations = .count(1),
        @BehaviorBuilder<Context> _ builder: () -> [String: Tree<Context>]
    ) {
        self.context = context
        self.iterations = iterations
        self.trees = builder()
        let tree = trees[root] ?? Tree(root) { Fail() }
        self.root = tree
        repeater = Repeat(iterations, [tree])
    }

    /// Executes one step of the behavior tree.
    ///
    /// Call this method each frame to advance the behavior tree execution.
    /// The tree will only run if it's in a `.running` state or hasn't started yet.
    /// Once completed (succeeded or failed), subsequent ticks return the cached state.
    ///
    /// - Parameter time: The timing information for this tick. If nil, uses a default 60fps time step.
    /// - Returns: The current state of the behavior after this tick.
    public func tick(time: BehaviorTime? = nil) -> BehaviorState {

        let time = time ?? BehaviorTime(elapsed: 0.016, accumulated: 0, actual: 0)

        switch state {
        case .none, .running:
            let state = Repeat {
                root
            }.tick(for: context, time: time, behavior: self)
            self.state = state
            return state
        case .succeeded:
            return .succeeded
        case .failed:
            return .failed
        }
    }

    /// Resets the behavior and all its trees to their initial state.
    ///
    /// This clears the cached state and resets all tasks in all trees,
    /// allowing the behavior to be run again from the beginning.
    public func reset() {
        state = nil
        for (_, tree) in trees {
            tree.reset()
        }
    }
}
