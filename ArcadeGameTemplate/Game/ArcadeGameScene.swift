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
        let waitAction = SKAction.wait(forDuration: 3.0)
        
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

        let positionX = frame.width - 50
        let positionY = frame.height - 500
        
        return CGPoint(x: positionX, y: positionY)
    }
    
    private func newAsteroid(at position: CGPoint) {
        let newAsteroid = SKShapeNode(circleOfRadius: 25)
        newAsteroid.name = "asteroid"
        newAsteroid.fillColor = SKColor.red
        newAsteroid.strokeColor = SKColor.black
        
        newAsteroid.position = position
        
        newAsteroid.physicsBody = SKPhysicsBody(circleOfRadius: 15.0)
        newAsteroid.physicsBody?.affectedByGravity = true
        
        newAsteroid.physicsBody?.categoryBitMask = PhysicsCategory.asteroid
        newAsteroid.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.floor
        newAsteroid.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.floor

        
        newAsteroid.physicsBody?.restitution = 0.5 // Adjust this value as needed

        // Set the initial velocity to move the asteroid to the left
        let initialVelocity = CGVector(dx: -100, dy: 0) // Adjust the dx value as needed
        newAsteroid.physicsBody?.velocity = initialVelocity

        addChild(newAsteroid)
        
        newAsteroid.run(SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            SKAction.removeFromParent()
        ]))
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
