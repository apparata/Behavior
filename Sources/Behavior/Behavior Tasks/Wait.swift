import Foundation

/// Run for `duration` seconds or `ticks` ticks, then succeed.
///
/// Returns:
/// - `.running` if time remains.
/// - `.succeeded` if the duration is over.
///
public final class Wait<Context>: BuiltInBehaviorTask<Context> {

    private let duration: TimeInterval?
    private let ticks: Int?

    private var accumulatedDuration: TimeInterval = 0
    private var accumulatedTicks: Int = 0

    public init(_ duration: TimeInterval) {
        self.duration = max(0, duration)
        self.ticks = nil
    }

    public init(ticks: Int) {
        self.duration = nil
        self.ticks = max(0, ticks)
    }

    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        if !isFirstRun {
            accumulatedDuration += time.elapsed
            accumulatedTicks += 1
        }

        if let duration, accumulatedDuration >= duration {
            return .succeeded
        }

        if let ticks, accumulatedTicks >= ticks {
            return .succeeded
        }

        return .running
    }
}
