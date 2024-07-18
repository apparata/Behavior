import Foundation
import Behavior

class IsAlive<Context: HasHealth>: BehaviorTask<Context> {

    override func run(
        for entity: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        if entity.health > 0 {
            return .succeeded
        } else {
            return .failed
        }
    }
}
