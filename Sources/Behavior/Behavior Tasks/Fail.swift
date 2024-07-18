import Foundation

/// The `Fail` task does nothing and returns `.failed`.
///
/// Returns:
/// - `.failed`
///
public final class Fail<Context>: BuiltInBehaviorTask<Context> {
    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        .failed
    }
}
