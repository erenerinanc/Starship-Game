//
//  GameScene.swift
//  Project17
//
//  Created by Eren Erinanc on 18.02.2021.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var starField: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var enemyCount = 0
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    
    var gameTimer: Timer?
    var timeInterval = 1.0
    
    var isGameOver = false
    var gameOverLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starField = SKEmitterNode(fileNamed: "starfield")!
        starField.position = CGPoint(x: 1024, y: 384)
        starField.advanceSimulationTime(10)
        addChild(starField)
        starField.zPosition = -1
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        startGame()
        }
    
    func startGame() {
        scoreLabel?.removeFromParent()
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        startTimer()
    }
    
    func startTimer() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    @objc func createEnemy() {
        guard !isGameOver else { return }
        guard let enemy = possibleEnemies.randomElement() else { return }

        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)

        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        enemyCount += 1
        
        if enemyCount.isMultiple(of: 20) {
            timeInterval -= 0.1
            startTimer()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
            gameOverLabel?.removeFromParent()
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        player.removeFromParent()
        isGameOver = true
        
        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 100
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        addChild(gameOverLabel)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let ac = UIAlertController(title: "Do you want to start a new game?", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "New Game", style: .default) { [weak self] _ in
                self?.isGameOver = false
                self?.startGame()
            })
            ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
            self.view?.window?.rootViewController?.present(ac, animated: true)
        }
    }
}
