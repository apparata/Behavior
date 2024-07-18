import Foundation

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
