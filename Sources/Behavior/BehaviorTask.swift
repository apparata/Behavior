import Foundation

open class BehaviorTask<Context>: CustomStringConvertible {

    /// If the `state` is `nil`, the task has not started running yet.
    public private(set) var state: BehaviorState?

    public var isFirstRun: Bool {
        state == nil
    }

    open var description: String {
        "\(Self.self)"
    }

    public init() {
        //
    }

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

    /// The `run(for:)` function will be called on every frame update,
    /// from the `tick(for:time:behavior:)` function.
    ///
    /// - Do not call `super.run(for:)` if overriding this function.
    /// - Do not call this function directly.
    open func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        fatalError("Do not call run(for:) directly.")
    }

    /// Remember to call the `super.reset()` if overriding this function.
    open func reset() {
        state = nil
    }
}

public class BuiltInBehaviorTask<Context>: BehaviorTask<Context> {
    //
}
