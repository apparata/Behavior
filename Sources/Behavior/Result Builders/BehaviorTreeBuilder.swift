import Foundation

/// A result builder for constructing task sequences within trees.
///
/// `BehaviorTreeBuilder` enables a declarative DSL syntax for defining sequences of tasks
/// within composite nodes like ``Tree``, ``Sequence``, ``Fallback``, etc. It collects
/// individual ``BehaviorTask`` instances into an array.
///
/// ## Usage
///
/// This builder is used automatically in composite task initializers:
///
/// ```swift
/// Tree("Root") {
///     FindTarget()
///     MoveToTarget()
///     Attack()
/// }
///
/// Sequence {
///     CheckAmmo()
///     Reload()
///     Fire()
/// }
/// ```
///
/// The builder collects all tasks in the closure and passes them to the composite task's initializer.
@resultBuilder public struct BehaviorTreeBuilder<Context> {

    public static func buildExpression(_ expression: BehaviorTask<Context>) -> BehaviorTask<Context> {
        expression
    }

    public static func buildBlock(_ parts: BehaviorTask<Context>...) -> [BehaviorTask<Context>] {
        parts
    }
}
