import Testing
@testable import Behavior

class TestContext {
    var value: Int = 0
    var executed: [String] = []
}

@Suite("Composite Tasks")
struct CompositeTasksTests {

    let time = BehaviorTime(elapsed: 0.016, accumulated: 0, actual: 0)

    @Test("Sequence succeeds when all children succeed")
    func sequenceSucceedsWhenAllChildrenSucceed() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Sequence {
                    Action { ctx in
                        ctx.executed.append("A")
                        return .succeeded
                    }
                    Action { ctx in
                        ctx.executed.append("B")
                        return .succeeded
                    }
                    Action { ctx in
                        ctx.executed.append("C")
                        return .succeeded
                    }
                }
            }
        }

        let result = behavior.tick(time: time)
        #expect(result == .succeeded)
        #expect(behavior.context.executed == ["A", "B", "C"])
    }

    @Test("Sequence fails when a child fails")
    func sequenceFailsWhenChildFails() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Sequence {
                    Action { ctx in
                        ctx.executed.append("A")
                        return .succeeded
                    }
                    Action { ctx in
                        ctx.executed.append("B")
                        return .failed
                    }
                    Action { ctx in
                        ctx.executed.append("C")
                        return .succeeded
                    }
                }
            }
        }

        let result = behavior.tick(time: time)
        #expect(result == .failed)
        #expect(behavior.context.executed == ["A", "B"])
    }

    @Test("Fallback succeeds on first success")
    func fallbackSucceedsOnFirstSuccess() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Fallback {
                    Action { ctx in
                        ctx.executed.append("A")
                        return .failed
                    }
                    Action { ctx in
                        ctx.executed.append("B")
                        return .succeeded
                    }
                    Action { ctx in
                        ctx.executed.append("C")
                        return .succeeded
                    }
                }
            }
        }

        let result = behavior.tick(time: time)
        #expect(result == .succeeded)
        #expect(behavior.context.executed == ["A", "B"])
    }

    @Test("Fallback fails when all children fail")
    func fallbackFailsWhenAllChildrenFail() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Fallback {
                    Action { ctx in
                        ctx.executed.append("A")
                        return .failed
                    }
                    Action { ctx in
                        ctx.executed.append("B")
                        return .failed
                    }
                    Action { ctx in
                        ctx.executed.append("C")
                        return .failed
                    }
                }
            }
        }

        let result = behavior.tick(time: time)
        #expect(result == .failed)
        #expect(behavior.context.executed == ["A", "B", "C"])
    }

    @Test("Parallel succeeds when all children succeed")
    func parallelSucceedsWhenAllChildrenSucceed() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Parallel {
                    Action { ctx in
                        ctx.executed.append("A")
                        return .succeeded
                    }
                    Action { ctx in
                        ctx.executed.append("B")
                        return .succeeded
                    }
                    Action { ctx in
                        ctx.executed.append("C")
                        return .succeeded
                    }
                }
            }
        }

        let result = behavior.tick(time: time)
        #expect(result == .succeeded)
        #expect(behavior.context.executed == ["A", "B", "C"])
    }

    @Test("Parallel fails immediately when a child fails")
    func parallelFailsImmediatelyWhenChildFails() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Parallel {
                    Action { ctx in
                        ctx.executed.append("A")
                        return .succeeded
                    }
                    Action { ctx in
                        ctx.executed.append("B")
                        return .failed
                    }
                    Action { ctx in
                        ctx.executed.append("C")
                        return .succeeded
                    }
                }
            }
        }

        let result = behavior.tick(time: time)
        #expect(result == .failed)
        #expect(behavior.context.executed == ["A", "B"])
    }

    @Test("Race succeeds on first success")
    func raceSucceedsOnFirstSuccess() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Race {
                    Action { ctx in
                        ctx.executed.append("A")
                        return .failed
                    }
                    Action { ctx in
                        ctx.executed.append("B")
                        return .succeeded
                    }
                    Action { ctx in
                        ctx.executed.append("C")
                        return .failed
                    }
                }
            }
        }

        let result = behavior.tick(time: time)
        #expect(result == .succeeded)
        #expect(behavior.context.executed == ["A", "B"])
    }

    @Test("Race fails when all children fail")
    func raceFailsWhenAllChildrenFail() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Race {
                    Action { ctx in
                        ctx.executed.append("A")
                        return .failed
                    }
                    Action { ctx in
                        ctx.executed.append("B")
                        return .failed
                    }
                    Action { ctx in
                        ctx.executed.append("C")
                        return .failed
                    }
                }
            }
        }

        let result = behavior.tick(time: time)
        #expect(result == .failed)
        #expect(behavior.context.executed == ["A", "B", "C"])
    }
}
