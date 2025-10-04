import Foundation

/// A control task that forces a tagged parent task to fail.
///
/// The `FailParent` task searches up the tree hierarchy for a parent with a matching tag
/// and forces it to complete with `.failed` on the next tick. This allows breaking out of
/// loops or sequences early with a failure state.
///
/// ## Behavior
///
/// - Searches up the parent hierarchy for a task with the specified tag
/// - Sets the tagged parent's state to `.failed`
/// - Returns `.running` if parent was found (parent will complete next tick)
/// - Returns `.failed` if no matching parent was found
///
/// ## Limitations
///
/// - Only searches within the current tree (does not cross subtree boundaries)
/// - The parent must be tagged using `.tag()` method
///
/// ## Returns
///
/// - `.running` if the tagged parent was found
/// - `.failed` if the tagged parent was not found
///
/// ## Example
///
/// ```swift
/// While(SomeCondition()) {
///     Fallback {
///         SomeTask()
///         FailParent("loop")  // Exits the While loop with failure
///     }
/// }.tag("loop")
/// ```
public final class FailParent<Context>: BuiltInBehaviorTask<Context> {

    /// The tag of the parent task to fail.
    public let parentTag: Tag

    public init(_ parentTag: Tag) {
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
