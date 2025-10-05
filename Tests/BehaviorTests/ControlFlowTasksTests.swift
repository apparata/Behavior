import Testing
@testable import Behavior

@Suite("Control Flow Tasks")
struct ControlFlowTasksTests {

    let time = BehaviorTime(elapsed: 0.016, accumulated: 0, actual: 0)

    @Test("While executes while condition succeeds")
    func whileExecutesWhileConditionSucceeds() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                While(Condition { return $0.value < 3 }) {
                    Action { ctx in
                        ctx.value += 1
                        ctx.executed.append("\(ctx.value)")
                        return .succeeded
                    }
                }
            }
        }!

        _ = behavior.tick(time: time)
        #expect(behavior.context.value == 1)
        #expect(behavior.context.executed == ["1"])

        _ = behavior.tick(time: time)
        #expect(behavior.context.value == 2)
        #expect(behavior.context.executed == ["1", "2"])

        _ = behavior.tick(time: time)
        #expect(behavior.context.value == 3)
        #expect(behavior.context.executed == ["1", "2", "3"])

        let result = behavior.tick(time: time)
        #expect(result == .succeeded)
        #expect(behavior.context.value == 3)
    }

    @Test("Repeat executes N times")
    func repeatExecutesNTimes() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Repeat(.count(3)) {
                    Action { ctx in
                        ctx.value += 1
                        ctx.executed.append("\(ctx.value)")
                        return .succeeded
                    }
                }
            }
        }

        _ = behavior!.tick(time: time)
        _ = behavior!.tick(time: time)
        let result = behavior!.tick(time: time)

        #expect(result == .succeeded)
        #expect(behavior!.context.value == 3)
        #expect(behavior!.context.executed == ["1", "2", "3"])
    }

    @Test("Repeat fails when sequence fails")
    func repeatFailsWhenSequenceFails() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Repeat(.count(5)) {
                    Action { ctx in
                        ctx.value += 1
                        ctx.executed.append("\(ctx.value)")
                        return ctx.value < 3 ? .succeeded : .failed
                    }
                }
            }
        }

        _ = behavior!.tick(time: time)
        _ = behavior!.tick(time: time)
        let result = behavior!.tick(time: time)

        #expect(result == .failed)
        #expect(behavior!.context.value == 3)
        #expect(behavior!.context.executed == ["1", "2", "3"])
    }

    @Test("Subtree executes named tree")
    func subtreeExecutesNamedTree() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Subtree("Other")
            }

            Tree("Other") {
                Action { ctx in
                    ctx.executed.append("Other")
                    return .succeeded
                }
            }
        }

        let result = behavior!.tick(time: time)
        #expect(result == .succeeded)
        #expect(behavior!.context.executed == ["Other"])
    }

    @Test("Subtree fails when tree not found")
    func subtreeFailsWhenTreeNotFound() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Subtree("NonExistent")
            }
        }

        let result = behavior!.tick(time: time)
        #expect(result == .failed)
    }

    @Test("Tree resets child tasks")
    func treeResetsChildTasks() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Action { ctx in
                    ctx.value += 1
                    return .succeeded
                }
            }
        }

        _ = behavior!.tick(time: time)
        #expect(behavior!.context.value == 1)

        behavior!.reset()
        _ = behavior!.tick(time: time)
        #expect(behavior!.context.value == 2)
    }
}
