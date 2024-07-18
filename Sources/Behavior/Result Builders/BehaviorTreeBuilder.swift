import Foundation

@resultBuilder public struct BehaviorTreeBuilder<Context> {

    public static func buildExpression(_ expression: BehaviorTask<Context>) -> BehaviorTask<Context> {
        expression
    }

    public static func buildBlock(_ parts: BehaviorTask<Context>...) -> [BehaviorTask<Context>] {
        parts
    }
}
