import XCTest
@testable import Behavior

protocol HasHealth {
    var health: Int { get }
}

class Entity: HasHealth {

    var health: Int = 1

    init() {
        //
    }
}

class ImmortalEntity {
    init() {
        //
    }
}

final class BehaviorTests: XCTestCase {

    func testBehaviorBuilder() {

        let npc = Entity()

        let behavior = Behavior(for: npc) {
            Tree("Root") {
                While(IsAlive()) {
                    Say("Hello")
                }
            }
        }
        dump(behavior!.trees)
        let time = BehaviorTime(
            elapsed: 0.016,
            accumulated: 0,
            actual: Date().timeIntervalSince1970
        )
        let result = behavior!.tick(time: time)
        dump(result)
    }
}
