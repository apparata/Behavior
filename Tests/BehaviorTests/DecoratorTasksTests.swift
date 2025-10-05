import Testing
@testable import Behavior

@Suite("Decorator Tasks")
struct DecoratorTasksTests {

    let time = BehaviorTime(elapsed: 0.016, accumulated: 0.016, actual: 0)

    @Test("Not inverts success to failure")
    func notInvertsSuccessToFailure() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Not(Succeed())
            }
        }

        let result = behavior!.tick(time: time)
        #expect(result == .failed)
    }

    @Test("Not inverts failure to success")
    func notInvertsFailureToSuccess() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Not(Fail())
            }
        }

        let result = behavior!.tick(time: time)
        #expect(result == .succeeded)
    }

    @Test("Not passes through running")
    func notPassesThroughRunning() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Not(Run())
            }
        }

        let result = behavior!.tick(time: time)
        #expect(result == .running)
    }

    @Test("Mute converts failure to success")
    func muteConvertsFailureToSuccess() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Mute(Fail())
            }
        }

        let result = behavior!.tick(time: time)
        #expect(result == .succeeded)
    }

    @Test("Mute keeps success as success")
    func muteKeepsSuccessAsSuccess() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Mute(Succeed())
            }
        }

        let result = behavior!.tick(time: time)
        #expect(result == .succeeded)
    }

    @Test("Wait succeeds after duration")
    func waitSucceedsAfterDuration() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Wait(0.05)
            }
        }

        let result1 = behavior!.tick(time: BehaviorTime(elapsed: 0.016, accumulated: 0.016, actual: 0))
        #expect(result1 == .running)

        let result2 = behavior!.tick(time: BehaviorTime(elapsed: 0.016, accumulated: 0.032, actual: 0))
        #expect(result2 == .running)

        let result3 = behavior!.tick(time: BehaviorTime(elapsed: 0.016, accumulated: 0.048, actual: 0))
        #expect(result3 == .running)

        let result4 = behavior!.tick(time: BehaviorTime(elapsed: 0.02, accumulated: 0.05, actual: 0))
        #expect(result4 == .succeeded)
    }

    @Test("Wait succeeds after tick count")
    func waitSucceedsAfterTickCount() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Wait(ticks: 3)
            }
        }

        let result1 = behavior!.tick(time: time)
        #expect(result1 == .running)

        let result2 = behavior!.tick(time: time)
        #expect(result2 == .running)

        let result3 = behavior!.tick(time: time)
        #expect(result3 == .succeeded)
    }

    @Test("Retry succeeds on first attempt")
    func retrySucceedsOnFirstAttempt() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Retry(3, Action { ctx in
                    ctx.value += 1
                    return .succeeded
                })
            }
        }

        let result = behavior!.tick(time: time)
        #expect(result == .succeeded)
        #expect(behavior!.context.value == 1)
    }

    @Test("Retry retries on failure")
    func retryRetriesOnFailure() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Retry(3, Action { ctx in
                    ctx.value += 1
                    return ctx.value >= 2 ? .succeeded : .failed
                })
            }
        }

        let result1 = behavior!.tick(time: time)
        #expect(result1 == .running)
        #expect(behavior!.context.value == 1)

        let result2 = behavior!.tick(time: time)
        #expect(result2 == .succeeded)
        #expect(behavior!.context.value == 2)
    }

    @Test("Retry fails after max attempts")
    func retryFailsAfterMaxAttempts() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Retry(3, Action { ctx in
                    ctx.value += 1
                    return .failed
                })
            }
        }

        let result1 = behavior!.tick(time: time)
        #expect(result1 == .running)

        let result2 = behavior!.tick(time: time)
        #expect(result2 == .running)

        let result3 = behavior!.tick(time: time)
        #expect(result3 == .failed)
        #expect(behavior!.context.value == 3)
    }

    @Test("Timeout succeeds within time limit")
    func timeoutSucceedsWithinTimeLimit() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Timeout(0.1, Succeed())
            }
        }

        let result = behavior!.tick(time: BehaviorTime(elapsed: 0.05, accumulated: 0, actual: 0))
        #expect(result == .succeeded)
    }

    @Test("Timeout fails when time exceeded")
    func timeoutFailsWhenTimeExceeded() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Timeout(0.05, Run())
            }
        }

        let result1 = behavior!.tick(time: BehaviorTime(elapsed: 0.03, accumulated: 0.03, actual: 0))
        #expect(result1 == .running)

        let result2 = behavior!.tick(time: BehaviorTime(elapsed: 0.03, accumulated: 0.06, actual: 0))
        #expect(result2 == .running)

        let result3 = behavior!.tick(time: BehaviorTime(elapsed: 0.03, accumulated: 0.09, actual: 0))
        #expect(result3 == .failed)
    }

    @Test("Cooldown prevents re-execution")
    func cooldownPreventsReExecution() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                While(Condition { ctx in ctx.value < 3 }) {
                    Cooldown(0.1, Action { ctx in
                        ctx.value += 1
                        return .succeeded
                    })
                }
            }
        }

        // First execution
        let result1 = behavior!.tick(time: BehaviorTime(elapsed: 0.016, accumulated: 0.016, actual: 0))
        #expect(result1 == .running)
        #expect(behavior!.context.value == 1)

        // During cooldown - returns cached result without re-executing
        let result2 = behavior!.tick(time: BehaviorTime(elapsed: 0.05, accumulated: 0.066, actual: 0))
        #expect(result2 == .running)
        #expect(behavior!.context.value == 1)

        // After cooldown expires - executes again
        let result3 = behavior!.tick(time: BehaviorTime(elapsed: 0.06, accumulated: 0.126, actual: 0))
        #expect(result3 == .running)
        #expect(behavior!.context.value == 2)

        // After cooldown expires again - executes one more time
        let result4 = behavior!.tick(time: BehaviorTime(elapsed: 0.1, accumulated: 0.226, actual: 0))
        #expect(result4 == .running)
        #expect(behavior!.context.value == 3)

        // Condition now fails, loop exits
        let result5 = behavior!.tick(time: BehaviorTime(elapsed: 0.016, accumulated: 0.326, actual: 0))
        #expect(result5 == .succeeded)
        #expect(behavior!.context.value == 3)
    }
}
