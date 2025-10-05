import Testing
@testable import Behavior

@Suite("Utility Tasks")
struct UtilityTasksTests {

    let time = BehaviorTime(elapsed: 0.016, accumulated: 0, actual: 0)

    @Test("Condition succeeds when true")
    func conditionSucceedsWhenTrue() {
        let context = TestContext()
        context.value = 10
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Condition { $0.value > 5 }
            }
        }

        let result = behavior.tick(time: time)
        #expect(result == .succeeded)
    }

    @Test("Condition fails when false")
    func conditionFailsWhenFalse() {
        let context = TestContext()
        context.value = 3
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Condition { $0.value > 5 }
            }
        }

        let result = behavior.tick(time: time)
        #expect(result == .failed)
    }

    @Test("Action executes and returns state")
    func actionExecutesAndReturnsState() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Action { ctx in
                    ctx.value = 42
                    return .succeeded
                }
            }
        }

        let result = behavior.tick(time: time)
        #expect(result == .succeeded)
        #expect(behavior.context.value == 42)
    }

    @Test("Action with time uses timing info")
    func actionWithTimeUsesTimingInfo() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Action { ctx, time in
                    ctx.value = Int(time.elapsed * 1000)
                    return .succeeded
                }
            }
        }

        let result = behavior.tick(time: BehaviorTime(elapsed: 0.032, accumulated: 0, actual: 0))
        #expect(result == .succeeded)
        #expect(behavior.context.value == 32)
    }

    @Test("Log always succeeds")
    func logAlwaysSucceeds() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Log("Test message")
            }
        }

        let result = behavior.tick(time: time)
        #expect(result == .succeeded)
    }

    @Test("Log with context generates message")
    func logWithContextGeneratesMessage() {
        let context = TestContext()
        context.value = 100
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Log { ctx in "Value is \(ctx.value)" }
            }
        }

        let result = behavior.tick(time: time)
        #expect(result == .succeeded)
    }

    @Test("Random selects one child")
    func randomSelectsOneChild() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Random {
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
        #expect(behavior.context.executed.count == 1)
        #expect(["A", "B", "C"].contains(behavior.context.executed[0]))
    }

    @Test("Random with weights respects distribution")
    func randomWithWeightsRespectsDistribution() {
        let context = TestContext()
        // Weighted to always select first option
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Random(weights: [1.0, 0.0, 0.0]) {
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
        #expect(behavior.context.executed == ["A"])
    }

    @Test("Random returns child result")
    func randomReturnsChildResult() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Random(weights: [1.0]) {
                    Action { _ in .failed }
                }
            }
        }

        let result = behavior.tick(time: time)
        #expect(result == .failed)
    }

    @Test("Random caches selection across ticks")
    func randomCachesSelectionAcrossTicks() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Random {
                    Action { ctx in
                        ctx.value += 1
                        return ctx.value >= 3 ? .succeeded : .running
                    }
                }
            }
        }

        _ = behavior.tick(time: time)
        #expect(behavior.context.value == 1)

        _ = behavior.tick(time: time)
        #expect(behavior.context.value == 2)

        let result = behavior.tick(time: time)
        #expect(result == .succeeded)
        #expect(behavior.context.value == 3)
    }
}
