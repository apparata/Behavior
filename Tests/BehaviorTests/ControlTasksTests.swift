import Testing
@testable import Behavior

@Suite("Control Tasks")
struct ControlTasksTests {

    let time = BehaviorTime(elapsed: 0.016, accumulated: 0, actual: 0)

    @Test("Succeed always succeeds")
    func succeedAlwaysSucceeds() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Succeed()
            }
        }

        let result = behavior!.tick(time: time)
        #expect(result == .succeeded)
    }

    @Test("Fail always fails")
    func failAlwaysFails() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Fail()
            }
        }

        let result = behavior!.tick(time: time)
        #expect(result == .failed)
    }

    @Test("Run always runs")
    func runAlwaysRuns() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Run()
            }
        }

        let result1 = behavior!.tick(time: time)
        #expect(result1 == .running)

        let result2 = behavior!.tick(time: time)
        #expect(result2 == .running)
    }

    @Test("SucceedParent forces tagged parent to succeed")
    func succeedParentForcesTaggedParentToSucceed() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                While(Condition { $0.value < 10 }) {
                    Action { ctx in
                        ctx.value += 1
                        return ctx.value >= 3 ? .succeeded : .running
                    }
                    SucceedParent("loop")
                }.tag("loop")
            }
        }

        let result1 = behavior!.tick(time: time)
        #expect(result1 == .running)
        #expect(behavior!.context.value == 1)

        let result2 = behavior!.tick(time: time)
        #expect(result2 == .running)
        #expect(behavior!.context.value == 2)

        let result3 = behavior!.tick(time: time)
        #expect(result3 == .succeeded)
        #expect(behavior!.context.value == 3)
    }

    @Test("SucceedParent fails when parent not found")
    func succeedParentFailsWhenParentNotFound() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                SucceedParent("nonexistent")
            }
        }

        let result = behavior!.tick(time: time)
        #expect(result == .failed)
    }

    @Test("FailParent forces tagged parent to fail")
    func failParentForcesTaggedParentToFail() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                While(Condition { $0.value < 10 }) {
                    Action { ctx in
                        ctx.value += 1
                        return ctx.value >= 3 ? .succeeded : .running
                    }
                    FailParent("loop")
                }.tag("loop")
            }
        }

        let result1 = behavior!.tick(time: time)
        #expect(result1 == .running)
        #expect(behavior!.context.value == 1)

        let result2 = behavior!.tick(time: time)
        #expect(result2 == .running)
        #expect(behavior!.context.value == 2)

        let result3 = behavior!.tick(time: time)
        #expect(result3 == .failed)
        #expect(behavior!.context.value == 3)
    }

    @Test("FailParent fails when parent not found")
    func failParentFailsWhenParentNotFound() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                FailParent("nonexistent")
            }
        }

        let result = behavior!.tick(time: time)
        #expect(result == .failed)
    }

    @Test("Parent control does not cross subtree boundaries")
    func parentControlDoesNotCrossSubtreeBoundaries() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Sequence {
                    Succeed()
                    Subtree("Other")
                }.tag("root-sequence")
            }

            Tree("Other") {
                SucceedParent("root-sequence")
            }
        }

        // Should fail because it can't find the parent across subtree boundary
        let result = behavior!.tick(time: time)
        #expect(result == .failed)
    }

    @Test("Tagging allows identification of tasks")
    func taggingAllowsIdentificationOfTasks() {
        let context = TestContext()
        let behavior = Behavior(for: context) {
            Tree("Root") {
                Fallback {
                    Fail()
                    Sequence {
                        Action { ctx in
                            ctx.value = 1
                            return .succeeded
                        }
                        SucceedParent("fallback")
                    }
                }.tag("fallback")
            }
        }

        let result = behavior!.tick(time: time)
        #expect(result == .succeeded)
        #expect(behavior!.context.value == 1)
    }
}
