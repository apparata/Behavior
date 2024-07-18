import Foundation
import Behavior

public class Say<Context>: BehaviorTask<Context> {

    public let text: String

    public init(_ text: String) {
        self.text = text
    }

    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        print(text)
        return .succeeded
    }
}
