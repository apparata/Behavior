import Foundation

/// The execution state of a behavior task.
///
/// Behavior tasks return one of three states during execution:
/// - ``running``: The task is still executing and needs more ticks to complete
/// - ``succeeded``: The task has completed successfully
/// - ``failed``: The task has completed with a failure
public enum BehaviorState {

    /// The task has not yet completed and is still executing.
    ///
    /// Tasks in this state will continue to be ticked on subsequent frames.
    case running

    /// The task has completed successfully.
    ///
    /// Tasks in this state will not be executed again unless reset.
    case succeeded

    /// The task has completed with a failure.
    ///
    /// Tasks in this state will not be executed again unless reset.
    case failed
}
