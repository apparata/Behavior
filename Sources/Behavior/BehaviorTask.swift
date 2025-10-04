import Foundation

/// The base class for all behavior tree tasks.
///
/// `BehaviorTask` provides the core execution model for behavior trees. Subclasses override
/// the ``run(for:time:behavior:)`` method to implement custom behavior logic.
///
/// ## Execution Model
///
/// Tasks use a state-caching mechanism:
/// 1. The first call to ``tick(for:time:behavior:)`` executes ``run(for:time:behavior:)``
/// 2. The result is cached in ``state``
/// 3. Subsequent ticks return the cached state without re-execution
/// 4. Call ``reset()`` to clear the cache and allow re-execution
///
/// ## Creating Custom Tasks
///
/// ```swift
/// class MyTask<Context>: BehaviorTask<Context> {
///     override func run(for context: Context, time: BehaviorTime, behavior: Behavior<Context>) -> BehaviorState {
///         // Custom logic here
///         return .succeeded
///     }
/// }
/// ```
open class BehaviorTask<Context>: CustomStringConvertible {

    /// A string identifier that can be used to reference this task.
    public typealias Tag = String

    /// The current execution state of this task.
    ///
    /// If the `state` is `nil`, the task has not started running yet.
    public internal(set) var state: BehaviorState?

    /// Returns `true` if this is the first execution of the task.
    public var isFirstRun: Bool {
        state == nil
    }

    /// An optional tag for identifying this task.
    public private(set) var tag: Tag?

    /// The parent task in the behavior tree hierarchy.
    public weak var parent: BehaviorTask<Context>?

    /// A textual representation of this task.
    open var description: String {
        "\(Self.self)"
    }

    /// Creates a new behavior task.
    public init() {
        //
    }

    /// Executes one step of the task with state caching.
    ///
    /// This method checks the cached state and only calls ``run(for:time:behavior:)``
    /// if the task hasn't completed yet. Once a task returns `.succeeded` or `.failed`,
    /// subsequent ticks return the cached result.
    ///
    /// - Parameters:
    ///   - context: The context object for this behavior.
    ///   - time: Timing information for this tick.
    ///   - behavior: The parent behavior instance.
    /// - Returns: The current state after this tick.
    public func tick(for context: Context, time: BehaviorTime, behavior: Behavior<Context>) -> BehaviorState {
        switch state {
        case .none, .running:
            let state = run(for: context, time: time, behavior: behavior)
            self.state = state
            return state
        case .succeeded:
            return .succeeded
        case .failed:
            return .failed
        }
    }

    /// Executes the task's custom logic.
    ///
    /// Override this method in subclasses to implement custom behavior.
    /// This method is called by ``tick(for:time:behavior:)`` when the task needs to run.
    ///
    /// - Important: Do not call `super.run(for:time:behavior:)` when overriding.
    /// - Important: Do not call this method directly; use ``tick(for:time:behavior:)`` instead.
    ///
    /// - Parameters:
    ///   - context: The context object for this behavior.
    ///   - time: Timing information for this tick.
    ///   - behavior: The parent behavior instance.
    /// - Returns: The state after executing this task's logic.
    open func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        fatalError("Override run(for:time:behavior:) in \(type(of: self)). Do not call this method directly.")
    }

    /// Resets the task to its initial state.
    ///
    /// This clears the cached state, allowing the task to be executed again.
    /// Override this method to reset any internal state, but remember to call `super.reset()`.
    open func reset() {
        state = nil
    }

    /// Assigns a tag to this task for identification.
    ///
    /// Tags are used by tasks like ``SucceedParent`` and ``FailParent`` to reference
    /// specific parent tasks in the hierarchy.
    ///
    /// - Parameter tag: A string identifier for this task.
    /// - Returns: This task instance for method chaining.
    public func tag(_ tag: Tag) -> BehaviorTask<Context> {
        self.tag = tag
        return self
    }
}

/// Base class for built-in behavior tasks provided by the framework.
///
/// This class exists primarily to distinguish framework-provided tasks from user-defined tasks.
public class BuiltInBehaviorTask<Context>: BehaviorTask<Context> {
    //
}
