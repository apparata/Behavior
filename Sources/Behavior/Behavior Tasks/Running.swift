import Foundation

/// The `Run` task does nothing and returns `.running`.
///
/// Returns:
/// - `.running`
///
public final class Run<Context>: BuiltInBehaviorTask<Context> {
    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        .running
    }
}
