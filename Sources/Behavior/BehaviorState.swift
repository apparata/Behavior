import Foundation

public enum BehaviorState {

    /// The task has not yet completed.
    case running

    /// The task has completed in success.
    case succeeded

    /// The task has completed failure.
    case failed
}
