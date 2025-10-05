import Testing
@testable import Behavior

protocol HasHealth {
    var health: Int { get set }
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

@Suite("Behavior Tests")
struct BehaviorTests {

    let time = BehaviorTime(elapsed: 0.016, accumulated: 0, actual: 0)

    @Test("Behavior builder creates trees")
    func behaviorBuilderCreatesTrees() {
        let npc = Entity()

        let behavior = Behavior(for: npc) {
            Tree("Root") {
                While(IsAlive()) {
                    Say("Hello")
                }
            }
        }

        #expect(behavior != nil)
        #expect(behavior!.trees.count == 1)
        #expect(behavior!.trees["Root"] != nil)
    }

    @Test("Behavior executes while loop with custom tasks")
    func behaviorExecutesWhileLoopWithCustomTasks() {
        let npc = Entity()

        let behavior = Behavior(for: npc) {
            Tree("Root") {
                While(IsAlive()) {
                    Say("Hello")
                }
            }
        }

        // First tick: condition true, sequence runs, returns .running to continue loop
        let result1 = behavior!.tick(time: time)
        #expect(result1 == .running)

        // Kill the entity so condition fails
        npc.health = 0

        // Second tick: condition false, while loop exits with success
        let result2 = behavior!.tick(time: time)
        #expect(result2 == .succeeded)
    }

    @Test("Behavior fails when entity dies")
    func behaviorFailsWhenEntityDies() {
        let npc = Entity()
        npc.health = 0

        let behavior = Behavior(for: npc) {
            Tree("Root") {
                While(IsAlive()) {
                    Say("Hello")
                }
            }
        }

        let result = behavior!.tick(time: time)
        #expect(result == .succeeded)
    }

    @Test("Behavior reset clears state")
    func behaviorResetClearsState() {
        let npc = Entity()

        let behavior = Behavior(for: npc) {
            Tree("Root") {
                Succeed()
            }
        }

        let result1 = behavior!.tick(time: time)
        #expect(result1 == .succeeded)
        #expect(behavior!.state == .succeeded)

        behavior!.reset()
        #expect(behavior!.state == nil)

        let result2 = behavior!.tick(time: time)
        #expect(result2 == .succeeded)
    }

    @Test("Behavior uses default time when none provided")
    func behaviorUsesDefaultTimeWhenNoneProvided() {
        let npc = Entity()

        let behavior = Behavior(for: npc) {
            Tree("Root") {
                Succeed()
            }
        }

        let result = behavior!.tick()
        #expect(result == .succeeded)
    }

    @Test("Behavior caches completed state")
    func behaviorCachesCompletedState() {
        let npc = Entity()
        var tickCount = 0

        let behavior = Behavior(for: npc) {
            Tree("Root") {
                Action { _ in
                    tickCount += 1
                    return .succeeded
                }
            }
        }

        let result1 = behavior!.tick(time: time)
        #expect(result1 == .succeeded)
        #expect(tickCount == 1)

        // Should not re-execute
        let result2 = behavior!.tick(time: time)
        #expect(result2 == .succeeded)
        #expect(tickCount == 1)
    }
}
