import Foundation
import OSLog

/// The `Log` task logs a message to the console and returns `.succeeded`.
///
/// NOTE: The message closure is strongly referenced.
///
/// Returns:
/// - `.succeeded`
///
public final class Log<Context>: BuiltInBehaviorTask<Context> {

    private let message: (Context) -> String

    public init(_ message: String) {
        self.message = { _ in message }
    }

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
