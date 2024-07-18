import Foundation

public typealias BehaviorTreeName = String

public class Behavior<Context> {

    public let context: Context

    public let root: Tree<Context>

    public let trees: [BehaviorTreeName: Tree<Context>]

    public let iterations: BehaviorIterations

    private let repeater: Repeat<Context>

    /// If the `state` is `nil`, the task has not started running yet.
    public private(set) var state: BehaviorState?

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

    public func reset() {
        state = nil
        for (_, tree) in trees {
            tree.reset()
        }
    }
}
