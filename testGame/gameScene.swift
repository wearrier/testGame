//
//  gameScene.swift
//  testGame
//
//  Created by wearrier on 2026/04/23.
//

import SpriteKit
import SwiftUI

class gameScene: SKScene
{
    var enemyNode: SKShapeNode!
    var playerNode: SKShapeNode!
    var sword: SKSpriteNode!


    let playerMoveSpeed: CGFloat = 10
    let enemyMoveSpeed: CGFloat = 2

    var isEnemyDead: Bool = false
    var isGameOver: Bool = false
    var isSwing: Bool = false

    var scoreLabel = SKLabelNode(fontNamed: "Gothic-Bold")
    var score = 0

    override func didMove(to view: SKView)
    {
        backgroundColor = .white
        
        setupUI()
        setupPlayer()
        setupSword()
        setupEnemy()
        
        physicsWorld.contactDelegate = self
    }
    
    func setupUI()
    {
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 80)
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .black
        addChild(scoreLabel)
        
        updateScore()
    }
    func updateScore()
    {
        scoreLabel.text = "EnemyDead: \(score)"
    }

    func setupPlayer()
    {
        playerNode = SKShapeNode(circleOfRadius: 20)
        playerNode.fillColor = .black
        playerNode.position = CGPoint(x: 20, y: 500)
        
        let playerBody = SKPhysicsBody(circleOfRadius: 20)
        playerBody.isDynamic = false
        playerBody.categoryBitMask = physicsCategory.player
        playerBody.contactTestBitMask = physicsCategory.enemy
        playerBody.collisionBitMask = physicsCategory.none
        playerBody.node?.zPosition = 1
        
        playerNode.physicsBody = playerBody
        addChild(playerNode)
    }
    
    func setupSword()
    {
        //剣の初期化
        sword = SKSpriteNode()
        sword.color = .blue
        sword.position = CGPoint(x: 30, y: 0)
        sword.size = CGSize(width: 10, height: 100)
        sword.anchorPoint = CGPoint(x: 0.5, y: 0)
        
        //物理ボディの設定
        let swordBody = SKPhysicsBody(rectangleOf: sword.size)
        swordBody.affectedByGravity = false
        swordBody.isDynamic = true
        swordBody.contactTestBitMask = physicsCategory.enemy
        swordBody.collisionBitMask = physicsCategory.none
        swordBody.node?.zPosition = 1
        swordBody.usesPreciseCollisionDetection = true
        
        //剣に物理ボディを適用
        sword.physicsBody = swordBody
        
        playerNode.addChild(sword)
    }
    
    func swingSword()
    {
        //振ってたら振らない
        if isSwing
        {
            return
        }
        self.isSwing = true
        
        //振り下ろす
        let swingAction = SKAction.rotate(byAngle: -.pi, duration: 0.2)
        //当たり判定を有効化
        let activeCollision = SKAction.run
        {
            self.sword.physicsBody?.categoryBitMask =
            physicsCategory.sword
        }
        
        //ちょっと待とう
        let wait = SKAction.wait(forDuration: 0.1)
        
        //戻る時に多段ヒットしないように
        let deactiveCollision = SKAction.run
        {
            self.sword.physicsBody?.categoryBitMask =
            physicsCategory.none
        }
        //戻す
        let removeAction = SKAction.rotate(byAngle: .pi, duration: 0.2)
        
        //これまでの動作をシーケンス化
        let sequence = SKAction.sequence([
            swingAction,
            activeCollision,
            wait,
            removeAction,
            deactiveCollision
        ])
        
        //剣にシーケンス化した動作を実行
        sword.run(sequence)
        {
            self.sword.physicsBody?.categoryBitMask = physicsCategory.none
            
            self.isSwing = false
        }
    }

    func setupEnemy()
    {
        //敵の設定
        enemyNode = SKShapeNode(circleOfRadius: 20)
        enemyNode.fillColor = .red
        enemyNode.strokeColor = .clear
        spawnEnemy()
        
        //物理ボディの設定
        let enemyBody = SKPhysicsBody(circleOfRadius: 20)
        enemyBody.affectedByGravity = false
        enemyBody.isDynamic = true
        enemyBody.categoryBitMask = physicsCategory.enemy
        enemyBody.contactTestBitMask = physicsCategory.sword
        enemyBody.collisionBitMask = physicsCategory.none
        enemyBody.node?.zPosition = 1
        enemyBody.usesPreciseCollisionDetection = true
        
        //敵に物理ボディを適用
        enemyNode.physicsBody = enemyBody
        
        addChild(enemyNode)
    }
    
    func spawnEnemy()
    {
        let randomSpawn = CGFloat.random(in: 300...1000)
        enemyNode.position = CGPoint(x: randomSpawn, y: randomSpawn)
        isEnemyDead = false
    }
    
    //敵を倒した時のエフェクト
    func enemyRemove()
    {
        if isEnemyDead
        {
            score += 1
            updateScore()
            return
        }
        else if !isEnemyDead
        {
            let fadeOut = SKAction.fadeOut(withDuration: 0.1)
            let fadeIn = SKAction.fadeIn(withDuration: 0.1)
            let remove = SKAction.removeFromParent()
            let flash = SKAction.sequence([
                fadeOut,
                fadeIn,
                fadeOut,
                fadeIn,
                fadeOut,
                remove
            ])
            
            enemyNode.run(flash)
        }
    }

    func showGameOver()
    {
        playerNode.removeFromParent()
        backgroundColor = .gray
        let GameOVerText = SKLabelNode(fontNamed: "gothic-Bold")
        GameOVerText.numberOfLines = 0
        GameOVerText.text = "Game Over\nScore: \(score)"
        GameOVerText.fontSize = 100
        GameOVerText.fontColor = .red
        GameOVerText.position = CGPoint(x: 700, y: 500)
        addChild(GameOVerText)
        isGameOver = false
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        if isEnemyDead
        {
            spawnEnemy()
        }
        
        enemyMove()
    }
    
    func enemyMove()
    {
        let dx = playerNode.position.x - enemyNode.position.x
        let dy = playerNode.position.y - enemyNode.position.y
        
        let angle = atan2(dy, dx)
        
        let vx = cos(angle) * enemyMoveSpeed
        let vy = sin(angle) * enemyMoveSpeed
        
        enemyNode.position = CGPoint(x: enemyNode.position.x + vx, y: enemyNode.position.y + vy)
    }

    override func keyDown(with event: NSEvent)
    {
        switch event.keyCode
        {
        case 49: //スペース
            //スウィングさせる
            swingSword()
            
        case 13, 126: //Ansi-W, ↑
            playerNode.position.y += playerMoveSpeed
    
        case 0, 123: //Ansi-A, ←
            playerNode.position.x -= playerMoveSpeed
            
        case 1, 125: //Ansi-S, ↓
            playerNode.position.y -= playerMoveSpeed
            
        case 2, 124: //Ansi-D, →
            playerNode.position.x += playerMoveSpeed
            
        default:
            print(event.keyCode)
        }
    }
}

extension gameScene: SKPhysicsContactDelegate
{
    func didBegin(_ contact: SKPhysicsContact)
    {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if (firstBody.categoryBitMask == physicsCategory.sword && secondBody.categoryBitMask == physicsCategory.enemy) && !isEnemyDead ||
            (firstBody.categoryBitMask == physicsCategory.enemy && secondBody.categoryBitMask == physicsCategory.sword) &&
            !isEnemyDead
        {
            isEnemyDead = true
            enemyRemove()
            print("敵を撃破")
        }
        
        if (firstBody.categoryBitMask == physicsCategory.player && secondBody.categoryBitMask == physicsCategory.enemy) && (!isGameOver && !isEnemyDead) ||
            (firstBody.categoryBitMask == physicsCategory.enemy && secondBody.categoryBitMask == physicsCategory.player) && (!isGameOver && !isEnemyDead)
        {
            isGameOver = true
            showGameOver()
            print("ゲームオーバー")
        }
    }
}
