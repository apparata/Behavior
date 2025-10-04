import Foundation

/// A utility task that randomly selects and executes one child.
///
/// The `Random` task picks one child at random (optionally using weights) and executes it.
/// It returns the result of the selected child. The selection happens once when the task
/// starts and persists until reset.
///
/// ## Behavior
///
/// - Randomly selects one child (with optional weights)
/// - Executes the selected child
/// - Returns the selected child's result
/// - Selection is made once and cached until reset
///
/// ## Weighted Selection
///
/// Provide a `weights` array to control probability distribution. Higher weights
/// increase the chance of selection. Weights don't need to sum to 1.
///
/// ## Returns
///
/// - `.running` if the selected child is running
/// - `.succeeded` if the selected child has succeeded
/// - `.failed` if the selected child has failed or no children exist
///
/// ## Example
///
/// ```swift
/// // Equal probability
/// Random {
///     TauntA()
///     TauntB()
///     TauntC()
/// }
///
/// // Weighted selection (60% TauntA, 30% TauntB, 10% TauntC)
/// Random(weights: [0.6, 0.3, 0.1]) {
///     TauntA()
///     TauntB()
///     TauntC()
/// }
/// ```
public final class Random<Context>: BuiltInBehaviorTask<Context> {

    /// Optional weights for probability distribution.
    public let weights: [Double]?

    /// The child tasks to choose from.
    public let children: [BehaviorTask<Context>]
    private var selectedTask: BehaviorTask<Context>?

    /// Creates a random selector with an array of tasks.
    ///
    /// - Parameters:
    ///   - weights: Optional weights for each child (must match the number of children).
    ///   - children: The tasks to choose from.
    public init(weights: [Double]? = nil, _ children: [BehaviorTask<Context>]) {
        self.weights = weights
        self.children = children
        super.init()
        selectTask()
    }

    /// Creates a random selector using a result builder.
    ///
    /// - Parameters:
    ///   - weights: Optional weights for each child (must match the number of children).
    ///   - children: A result builder closure that returns the tasks to choose from.
    public init(
        weights: [Double]? = nil,
        @BehaviorTreeBuilder<Context> _ children: () -> [BehaviorTask<Context>]
    ) {
        self.weights = weights
        self.children = children()
        super.init()
        selectTask()
    }

    public override func run(
        for context: Context,
        time: BehaviorTime,
        behavior: Behavior<Context>
    ) -> BehaviorState {
        guard let task = selectedTask else {
            return .failed
        }
        let result = task.tick(for: context, time: time, behavior: behavior)
        return result
    }

    public override func reset() {
        super.reset()
        for child in children {
            child.reset()
        }
        selectTask()
    }

    private func selectTask() {
        if let weights {
            let zipped = Array(zip(self.children, weights))
            selectedTask = weightedRandomSelection(from: zipped)
        } else {
            selectedTask = self.children.randomElement()
        }
    }
}

/// Selects a random item from an array of weighted items.
///
/// This function takes an array of tuples, where each tuple consists of a value
/// of type `T` and a weight of type `Double`.
///
/// It returns one of the values, randomly selected based on the weight of each item. Items with higher
/// weights are more likely to be selected.
///
/// - Parameter items: An array of tuples where each tuple contains a value of type `T` and
///                    a weight of type `Double`.
/// - Returns: A randomly selected value of type `T` from the input array, based on the provided
///            weights. Returns `nil` if the array is empty or if all weights are zero.
///
/// # Example
///
/// ```swift
/// let items: [(value: String, weight: Double)] = [
///     (value: "A", weight: 0.1),
///     (value: "B", weight: 0.3),
///     (value: "C", weight: 0.6)
/// ]
///
/// if let selectedItem = weightedRandomSelection(from: items) {
///     print("Selected item: \(selectedItem)")
/// } else {
///     print("No item selected.")
/// }
/// ```
///
/// # Notes
///
/// - The weights do not need to sum to 1; the function will handle any positive values.
/// - If the total weight is zero or negative, the function returns `nil`.
/// - In the unlikely event of floating-point precision issues, the last item in the array will be returned.
///
/// - Complexity: O(n), where n is the number of items in the input array.
///
private func weightedRandomSelection<T>(from items: [(value: T, weight: Double)]) -> T? {
    // Ensure there are items to select from
    guard !items.isEmpty else {
        return nil
    }

    // Calculate the total sum of weights
    let totalWeight = items.reduce(0) { $0 + $1.weight }

    // Ensure the total weight is greater than 0
    guard totalWeight > 0 else {
        return nil
    }

    // Generate a random value between 0 and the total weight
    let randomValue = Double.random(in: 0..<totalWeight)

    // Find the item corresponding to the random value
    var cumulativeWeight: Double = 0

    for item in items {
        cumulativeWeight += item.weight
        if randomValue < cumulativeWeight {
            return item.value
        }
    }

    // In case of rounding errors, return the last item's value
    return items.last?.value
}
