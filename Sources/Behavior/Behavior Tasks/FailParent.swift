import Foundation

/// The `FailParent` task will force a tagged parent to complete with `.failed` on the next tick.
///
/// NOTE: Only applies within a tree and does not cross subtree boundaries.
///
/// Returns:
/// - `.running` if the tagged parent was found.
/// - `.failed` if the tagged parent was not found.
///
/// **Example:**
///
/// ```swift
/// While(SomeCondition()) {
///     Fallback {
///         SomeTask()
///         FailParent("loop")
///     }
/// }.tag("loop")
/// ```
///
public final class FailParent<Context>: BuiltInBehaviorTask<Context> {

    public let parentTag: Tag

    init(_ parentTag: Tag) {
        self.parentTag = parentTag
    }

    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {

        var upstreamTask: BehaviorTask<Context>? = self.parent

        while upstreamTask != nil {
            if upstreamTask?.tag == parentTag {
                upstreamTask?.state = .failed
                return .running
            } else {
                upstreamTask = upstreamTask?.parent
            }
        }

        // Parent task with specified tag not found.
        return .failed
    }
}
