//
//  ArcadeGameScene.swift
//  ArcadeGameTemplate
//

import SpriteKit
import SwiftUI

class ArcadeGameScene: SKScene {
    /**
     * # The Game Logic
     *     The game logic keeps track of the game variables
     *   you can use it to display information on the SwiftUI view,
     *   for example, and comunicate with the Game Scene.
     **/
    var gameLogic: ArcadeGameLogic = ArcadeGameLogic.shared
    
    // Keeps track of when the last update happend.
    // Used to calculate how much time has passed between updates.
    var lastUpdate: TimeInterval = 0
    
    var player: SKShapeNode!
    var asteroid: SKShapeNode!
    
    var isMovingToTheRight: Bool = false
    var isMovingToTheLeft: Bool = false
    
    override func didMove(to view: SKView) {
        self.setUpGame()
        self.setUpPhysicsWorld()
        createFloor()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        
        // Iterate through all nodes in the scene
        // Iterate through all nodes in the scene
        self.children.forEach { node in
            // Check if the node is an asteroid
            if let asteroid = node as? SKSpriteNode, asteroid.name == "asteroid" {
                // Calculate the boundaries of the asteroid sprite
                let asteroidMinX = asteroid.position.x - asteroid.size.width / 2
                let asteroidMaxX = asteroid.position.x + asteroid.size.width / 2
                let asteroidMinY = asteroid.position.y - asteroid.size.height / 2
                let asteroidMaxY = asteroid.position.y + asteroid.size.height / 2

                // Check if the entire asteroid sprite is off-screen
                if asteroidMaxX < 0 || asteroidMinX > self.frame.width ||
                   asteroidMaxY < 0 || asteroidMinY > self.frame.height {
                    // Remove the asteroid from the scene
                    asteroid.removeFromParent()
                }
            }
        }
        
        
        // ...
        
        if isMovingToTheRight{
            self.moveDown()
        }
        
        if isMovingToTheLeft{
            self.moveUp()
        }
        
        // If the game over condition is met, the game will finish
        if self.isGameOver { self.finishGame() }
        
        // The first time the update function is called we must initialize the
        // lastUpdate variable
        if self.lastUpdate == 0 { self.lastUpdate = currentTime }
        
        // Calculates how much time has passed since the last update
        let timeElapsedSinceLastUpdate = currentTime - self.lastUpdate
        // Increments the length of the game session at the game logic
        self.gameLogic.increaseSessionTime(by: timeElapsedSinceLastUpdate)
        
        self.lastUpdate = currentTime
    }
    
}

// MARK: - Game Scene Set Up
extension ArcadeGameScene {
    
    private func setUpGame() {
        self.gameLogic.setUpGame()
        self.backgroundColor = SKColor.white
        
        let playerInitialPosition = CGPoint(x: self.frame.width/2, y: self.frame.height-200)
        self.createPlayer(at: playerInitialPosition)
        
        self.startAsteroidsCycle()
    }
    
    private func setUpPhysicsWorld() {
        // TODO: Customize!
        physicsWorld.gravity = CGVector(dx: 0, dy: -0.9)
        
        physicsWorld.contactDelegate = self
    }
    
    private func restartGame() {
        self.gameLogic.restartGame()
    }
    
    private func createPlayer(at position: CGPoint) {
        self.player = SKShapeNode(circleOfRadius: 25.0)
        self.player.name = "player"
        self.player.fillColor = SKColor.blue
        self.player.strokeColor = SKColor.black
        
        self.player.position = position
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: 10.0)
        player.physicsBody?.affectedByGravity = false
        
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        
        player.physicsBody?.contactTestBitMask = PhysicsCategory.asteroid
        player.physicsBody?.collisionBitMask = PhysicsCategory.asteroid
        
        let xRange = SKRange(lowerLimit: 0, upperLimit: frame.width)
        
        let xConstraint = SKConstraint.positionX(xRange)
        
        self.player.constraints = [xConstraint]
        
        addChild(self.player)
    }
    
    func startAsteroidsCycle() {
        let createAsteroidAction = SKAction.run(createAsteroid)
        let waitAction = SKAction.wait(forDuration: 1.0) //Tiempo de espera de la creación de vacas
        
        let createAndWaitAction = SKAction.sequence([createAsteroidAction, waitAction])
        let asteroidCycleAction = SKAction.repeatForever(createAndWaitAction)
        
        run(asteroidCycleAction)
    }
}

// MARK: - Player Movement
extension ArcadeGameScene {
    
}

// MARK: - Handle Player Inputs
extension ArcadeGameScene {
    
    enum SideOfTheScreen {
        case right, left
    }
    
    private func sideTouched(for position: CGPoint) -> SideOfTheScreen {
        if position.x < self.frame.width / 2 {
            return .left
        } else {
            return .right
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        switch sideTouched(for: touchLocation) {
        case .right:
            self.isMovingToTheRight = true
            print("ℹ️ Touching the RIGHT side.")
        case .left:
            self.isMovingToTheLeft = true
            print("ℹ️ Touching the LEFT side.")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isMovingToTheRight = false
        self.isMovingToTheLeft = false
    }
    
}


// MARK: - Game Over Condition
extension ArcadeGameScene {
    
    /**
     * Implement the Game Over condition.
     * Remember that an arcade game always ends! How will the player eventually lose?
     *
     * Some examples of game over conditions are:
     * - The time is over!
     * - The player health is depleated!
     * - The enemies have completed their goal!
     * - The screen is full!
     **/
    
    var isGameOver: Bool {
        // TODO: Customize!
        
        // Did you reach the time limit?
        // Are the health points depleted?
        // Did an enemy cross a position it should not have crossed?
        
        return gameLogic.isGameOver
    }
    
    private func finishGame() {
        
        // TODO: Customize!
        
        gameLogic.isGameOver = true
    }
    
}

// MARK: - Register Score
extension ArcadeGameScene {
    
    private func registerScore() {
        // TODO: Customize!
    }
    
}

// MARK: - Asteroids
extension ArcadeGameScene {
    
    private func createAsteroid() {
        let asteroidPosition = self.randomAsteroidPosition()
        newAsteroid(at: asteroidPosition)
    }
    
    private func randomAsteroidPosition() -> CGPoint {
        let positionY = frame.height * 0.275 // Altura donde las vacas serán creadas
        
        // Randomly choose left or right side
        let positionX: CGFloat
        if Bool.random() { // Randomly returns true or false
            positionX = frame.width // Right side
        } else {
            positionX = 0 // Left side
        }
        
        return CGPoint(x: positionX, y: positionY)
    }

    
    private func newAsteroid(at position: CGPoint) {
        
        //let newAsteroid = SKShapeNode(circleOfRadius: 25)
        
        let asteroidTexture = SKTexture(imageNamed: "Cow")
        let newAsteroid = SKSpriteNode(texture: asteroidTexture)
        
        newAsteroid.name = "asteroid"
        
        //newAsteroid.fillColor = SKColor.red
        //newAsteroid.strokeColor = SKColor.black
        
        newAsteroid.position = position
        
        newAsteroid.size = CGSize(width: 70, height: 70)
        
        //newAsteroid.physicsBody = SKPhysicsBody(circleOfRadius: 15.0)
        //newAsteroid.physicsBody?.affectedByGravity = true
        
        newAsteroid.physicsBody = SKPhysicsBody(texture: asteroidTexture, size: newAsteroid.size)
        newAsteroid.physicsBody?.affectedByGravity = true
        
        newAsteroid.physicsBody?.categoryBitMask = PhysicsCategory.asteroid
        newAsteroid.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.floor
        newAsteroid.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.floor

        
        newAsteroid.physicsBody?.restitution = 0.5 // Adjust this value as needed to set the bounce

        let initialVelocityX: CGFloat = position.x > frame.midX ? -200 : 200 // Move left if on the right, right if on the left
        newAsteroid.physicsBody?.velocity = CGVector(dx: initialVelocityX, dy: 0)
        
        // Flip the image based on the direction of movement
        newAsteroid.xScale = initialVelocityX > 0 ? 1.0 : -1.0

        addChild(newAsteroid)
        
//        newAsteroid.run(SKAction.sequence([
//            SKAction.wait(forDuration: 5.0),
//            SKAction.removeFromParent()
//        ]))
    }
}


extension ArcadeGameScene{
    private func createFloor() {
        // Calculate the position for the floor
        let floorHeight: CGFloat = 1
        let floorPositionY = frame.height * 0.25

        // Create a floor node
        let floor = SKNode()
        floor.position = CGPoint(x: frame.midX, y: floorPositionY)
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: floorHeight))
        floor.physicsBody?.isDynamic = false // Floor should not move
        
        floor.physicsBody?.categoryBitMask = PhysicsCategory.floor
        floor.physicsBody?.contactTestBitMask = PhysicsCategory.asteroid
        floor.physicsBody?.collisionBitMask = PhysicsCategory.asteroid
        
        floor.physicsBody?.restitution = 0.5
        
        addChild(floor)

        // Create a visible line for the floor
        let floorLine = SKShapeNode(rectOf: CGSize(width: frame.width, height: 2))
        floorLine.fillColor = SKColor.black // Set the color of the line
        floorLine.position = CGPoint(x: frame.midX, y: floorPositionY)
        addChild(floorLine)
    }



}

// Mark - Player Movement

extension ArcadeGameScene{
    
    private func moveUp(){
        self.player.physicsBody?
            .applyForce(CGVector(dx: 0, dy: 5))
        
        print("Moving Left: \(player.physicsBody!.velocity)")
        
    }
    
    private func moveDown(){
        self.player.physicsBody?
            .applyForce(CGVector(dx: 0, dy: -5))
        
        print("Moving Rigth: \(player.physicsBody!.velocity)")
    }
}

struct PhysicsCategory {
    static let none : UInt32 = 0
    static let all : UInt32 = UInt32.max
    static let player : UInt32 = 0b1
    static let asteroid : UInt32 = 0b10
    static let floor: UInt32 = 0b100
}


extension ArcadeGameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody = contact.bodyA
        let secondBody: SKPhysicsBody = contact.bodyB
        
        // Check if the collision is between an asteroid and the player
        if (firstBody.categoryBitMask == PhysicsCategory.asteroid && secondBody.categoryBitMask == PhysicsCategory.player) ||
           (firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.asteroid) {
            
            if let asteroidNode = firstBody.node?.name == "asteroid" ? firstBody.node : secondBody.node {
                asteroidNode.removeFromParent()
            }
        }
        
        // Additional collision logic can be added here if needed
    }
}
