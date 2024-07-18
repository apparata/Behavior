import Foundation

// MARK: - Example

#if EXAMPLE
let behavior = Behavior {

    Tree("Root") {
        While(IsInPlay()) {
            Fallback {
                Sequence {
                    AcquireSpawnDirection()
                    Spawn()
                    Repeat {
                        Subtree("Chase")
                    }
                }
                Subtree("Player Died")
            }
        }
    }
    
    Tree("Chase") {
        While(PlayerIsAlive()) {
            Fallback {
                While(IsAlive()) {
                    StartChasing()
                    ChasePlayer()
                    LineUpAttack()
                    AttackPlayer()
                    Recharge()
                }
                Subtree("Die")
            }
        }
    }
    
    Tree("Die") {
        Die()
        Wait(3.0)
        SinkBelowGround()
        Recycle()
    }
    
    Tree("Player Died") {
        CelebrateVictory()
    }
}
#endif
