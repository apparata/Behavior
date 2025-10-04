import Foundation

/// A result builder for constructing behavior tree collections.
///
/// `BehaviorBuilder` enables a declarative DSL syntax for defining multiple named trees
/// within a ``Behavior`` instance. It collects ``Tree`` definitions and creates a dictionary
/// mapping tree names to tree instances.
///
/// ## Usage
///
/// This builder is used automatically when initializing a ``Behavior``:
///
/// ```swift
/// let behavior = Behavior(for: context) {
///     Tree("Root") {
///         Subtree("Attack")
///     }
///
///     Tree("Attack") {
///         FindTarget()
///         DealDamage()
///     }
/// }
/// ```
///
/// The builder collects all trees and makes them available via the behavior's ``Behavior/trees`` property.
@resultBuilder public struct BehaviorBuilder<Context> {

    public static func buildExpression(_ expression: Tree<Context>) -> Tree<Context> {
        expression
    }

    public static func buildBlock() -> [String: Tree<Context>] {
        [:]
    }

    public static func buildBlock(_ parts: Tree<Context>...) -> [String: Tree<Context>] {
        Dictionary(uniqueKeysWithValues: parts.map { ($0.name, $0) })
    }
}
