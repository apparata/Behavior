import Foundation

/// A decorator task that waits for a duration or tick count before succeeding.
///
/// The `Wait` task delays execution by running for a specified time duration
/// or number of ticks before completing with success.
///
/// ## Behavior
///
/// - Runs for the specified duration (in seconds) or number of ticks
/// - Accumulates time/ticks on each frame
/// - Succeeds when the duration/tick count is reached
///
/// ## Returns
///
/// - `.running` if time or ticks remain
/// - `.succeeded` if the duration or tick count has been reached
///
/// ## Example
///
/// ```swift
/// Sequence {
///     Attack()
///     Wait(2.0)          // Wait 2 seconds
///     PlayVictorySound()
/// }
///
/// // Or wait by tick count:
/// Wait(ticks: 60)        // Wait 60 frames
/// ```
public final class Wait<Context>: BuiltInBehaviorTask<Context> {

    private let duration: TimeInterval?
    private let ticks: Int?

    private var accumulatedDuration: TimeInterval = 0
    private var accumulatedTicks: Int = 0

    /// Creates a wait task that waits for a time duration.
    ///
    /// - Parameter duration: The duration to wait in seconds (minimum: 0).
    public init(_ duration: TimeInterval) {
        self.duration = max(0, duration)
        self.ticks = nil
    }

    /// Creates a wait task that waits for a number of ticks.
    ///
    /// - Parameter ticks: The number of frames/ticks to wait (minimum: 0).
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
