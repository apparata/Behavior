import Foundation
import OSLog

/// A utility task that logs a message and succeeds.
///
/// The `Log` task outputs a message to the system logger using OSLog and immediately
/// succeeds. It's useful for debugging behavior trees and tracking execution flow.
///
/// ## Behavior
///
/// - Evaluates the message (static or context-based)
/// - Logs the message using OSLog at trace level
/// - Returns `.succeeded` immediately
///
/// ## Returns
///
/// - `.succeeded` (always succeeds)
///
/// ## Example
///
/// ```swift
/// Sequence {
///     Log("Starting attack sequence")
///     FindTarget()
///     Log { context in "Attacking \(context.targetName)" }
///     Attack()
/// }
/// ```
///
/// - Note: The message closure is strongly referenced.
public final class Log<Context>: BuiltInBehaviorTask<Context> {

    private let message: (Context) -> String

    /// Creates a log task with a static message.
    ///
    /// - Parameter message: The message to log.
    public init(_ message: String) {
        self.message = { _ in message }
    }

    /// Creates a log task with a context-based message.
    ///
    /// - Parameter message: A closure that generates a message from the context.
    public init(_ message: @escaping (Context) -> String) {
        self.message = message
    }

    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        let string = message(context)
        Logger.behavior.trace("\(string)")
        return .succeeded
    }
}

fileprivate extension Logger {
    static let behavior = Logger(subsystem: "io.apparata.behavior", category: "Behavior")
}
