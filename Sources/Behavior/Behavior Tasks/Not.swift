import Foundation

/// A decorator task that inverts the result of its child.
///
/// The `Not` task (also known as "Inverter") flips the success/failure state of its child.
/// It's useful for creating negative conditions or inverting logic.
///
/// ## Behavior
///
/// - Executes the child task
/// - Returns `.succeeded` when child returns `.failed`
/// - Returns `.failed` when child returns `.succeeded`
/// - Passes through `.running` unchanged
///
/// ## Returns
///
/// - `.running` when the child is running
/// - `.succeeded` when the child has failed
/// - `.failed` when the child has succeeded
///
/// ## Example
///
/// ```swift
/// Not(HasAmmo())  // Succeeds when player has NO ammo
/// ```
public final class Not<Context>: BuiltInBehaviorTask<Context> {

    /// The child task whose result will be inverted.
    public let child: BehaviorTask<Context>

    /// Creates an inverter decorator.
    ///
    /// - Parameter child: The task whose result will be inverted.
    public init(_ child: BehaviorTask<Context>) {
        self.child = child
    }

    override public func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        switch child.tick(for: context, time: time, behavior: behavior) {
        case .running: .running
        case .succeeded: .failed
        case .failed: .succeeded
        }
    }
}
