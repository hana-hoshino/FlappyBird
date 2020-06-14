//
//  GameScene.swift
//  FlappyBird
//
//  Created by 星野　花 on 2020/06/09.
//  Copyright © 2020 Kana.h. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var itemNode:SKNode!
    var bird:SKSpriteNode!
    
    let birdCategory: UInt32 = 1 << 0
    let groundCategory: UInt32 = 1 << 1
    let wallCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    let itemCategory: UInt32 = 1 << 4
    
    var score = 0
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    var itemScore = 0
    var itemScoreLabelNode:SKLabelNode!
    var bestItemScoreLabelNode:SKLabelNode!
    let userDefaults:UserDefaults = UserDefaults.standard
    
    //タップ時のサウンド
    var player0:AVAudioPlayer?
    
    
    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        physicsWorld.contactDelegate = self
        
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        scrollNode = SKNode()
        addChild(scrollNode)
        
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        itemNode = SKNode()
        scrollNode.addChild(itemNode)
        
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupItem()
        setupScoreLabel()
    }
    
    func setupItem() {
        // アイテムの画像を読み込む
        let itemTexture = SKTexture(imageNamed: "item")
        itemTexture.filteringMode = .linear
        
        // 移動する距離を計算
        let movingItemDistance = CGFloat(self.frame.size.width * 1.3 + itemTexture.size().width)
        
        // 画面外まで移動するアクションを作成
        let moveItem = SKAction.moveBy(x: -movingItemDistance, y: 0, duration: 5)
        
        // 自身を取り除くアクションを作成
        let removeItem = SKAction.removeFromParent()
        
        // 2つのアニメーションを順に実行するアクションを作成
        let itemAnimation = SKAction.sequence([moveItem, removeItem])
        
        // 鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        // 隙間位置の上下の振れ幅を鳥のサイズの3倍とする
        let random_y_range = birdSize.height * 3
        
        // 表示位置計算
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_item_lowest_y = center_y - itemTexture.size().height / 2 - random_y_range / 2
        
        // アイテムを生成するアクションを作成
        let  createItemAnimation = SKAction.run({
            // アイテム関連のノードを乗せるノードを作成
            let item = SKNode()
            item.position = CGPoint(x: self.frame.size.width * 1.3 + itemTexture.size().width / 2, y:0)
            item.zPosition = -50
            
            // 0〜random_y_rangeまでのランダム値を生成
            let random_y = CGFloat.random(in: 0..<random_y_range)
            // Y軸の下限にランダムな値を足して、Y座標を決定
            let under_item_y = under_item_lowest_y + random_y
            
            // アイテム作成
            let itemNew = SKSpriteNode(texture: itemTexture)
            itemNew.position = CGPoint(x:0, y:under_item_y)
            
            // スプライトに物理演算を設定する
            itemNew.physicsBody = SKPhysicsBody(rectangleOf: itemTexture.size())
            itemNew.physicsBody?.categoryBitMask = self.itemCategory
            itemNew.physicsBody?.contactTestBitMask = self.birdCategory
            
            // 衝突の時に動かないように設定する
            itemNew.physicsBody?.isDynamic = false
            
            item.addChild(itemNew)
            
            item.run(itemAnimation)
            
            self.itemNode.addChild(item)
        })
        
        // 次のアイテム作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        // アイテムを作成->時間待ち->アイテムを作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createItemAnimation, waitAnimation]))
        
        itemNode.run(repeatForeverAnimation)
    }
    
    func setupGround() {
        
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        let needGroundNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width , y: 0, duration: 5)
        
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        for i in 0..<needGroundNumber {
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2  + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )
            
            sprite.run(repeatScrollGround)
            
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            sprite.physicsBody?.isDynamic = false
            
            scrollNode.addChild(sprite)
        }
    }
    
    func setupCloud(){
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20)
        
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        for i in 0..<needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100
            
            sprite.position = CGPoint(
                x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                y: self.size.height - cloudTexture.size().height / 2
            )
            
            sprite.run(repeatScrollCloud)
            
            scrollNode.addChild(sprite)
        }
    }
    
    func setupWall() {
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        
        let removeWall = SKAction.removeFromParent()
        
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        let slit_length = birdSize.height * 3
        
        let random_y_range = birdSize.height * 3
        
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_range / 2
        
        let  createWallAnimation = SKAction.run({
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y:0)
            wall.zPosition = -50
            
            let random_y = CGFloat.random(in: 0..<random_y_range)
            let under_wall_y = under_wall_lowest_y + random_y
            
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x:0, y:under_wall_y)
            
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            under.physicsBody?.isDynamic = false
            
            wall.addChild(under)
            
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x:0, y:under_wall_y + wallTexture.size().height + slit_length)
            
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            
            upper.physicsBody?.isDynamic = false
            
            wall.addChild(upper)
            
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            
            wall.run(wallAnimation)
            
            self.wallNode.addChild(wall)
        })
        
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
        
    }
    
    func setupBird(){
        let  birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let  birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        let textureAnimation = SKAction.animate(with: [birdTextureA,birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(textureAnimation)
        
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        
        bird.physicsBody?.allowsRotation = false
        
        // 衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory
        
        
        bird.run(flap)
        
        addChild(bird)
    }
    
    //画面をタップしたときのメソッド
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (scrollNode.speed > 0) {
            bird.physicsBody?.velocity = CGVector.zero
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
            //効果音鳴らす
            let soundURL = Bundle.main.url(forResource: "nyu1", withExtension: "mp3")
            do {
                player0 = try AVAudioPlayer(contentsOf: soundURL!)
                player0?.play()
            } catch {
                print("error...")
            }
            
        } else if (bird.speed == 0) {
            restart()
        }
    }
    
    //なにかが衝突したときのメソッド
    func didBegin(_ contact: SKPhysicsContact) {
        //ゲームオーバーのとき
        if scrollNode.speed <= 0 {
            return
        }
        
        //スコアカテゴリに衝突したとき？？
        if(contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            var bestScore = userDefaults.integer(forKey: "BEST")
            if (score > bestScore){
                bestScore = score
                bestScoreLabelNode.text = "Best Score: \(bestScore)"
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }
        }
                
        else if ((contact.bodyA.categoryBitMask & itemCategory) == itemCategory || (contact.bodyB.categoryBitMask & itemCategory) == itemCategory) {
            print("アイテムGET")
            //以下上と同じ
            print("ScoreUp")
            itemScore += 1
            itemScoreLabelNode.text = "Score:\(itemScore)"
            
            var bestItemScore = userDefaults.integer(forKey: "BEST_ITEM")
            if (itemScore > bestItemScore){
                bestItemScore = itemScore
                bestScoreLabelNode.text = "Best Item Score: \(bestItemScore)"
                userDefaults.set(bestItemScore, forKey: "BEST_ITEM")
                userDefaults.synchronize()
            }
            //アイテムを消す
            SKAction.removeFromParent()
        } else {
            print("GameOver")
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi)*CGFloat(bird.position.y)*0.01, duration: 1)
            bird.run(roll, completion: {
                self.bird.speed = 0
            })
        }
    }
    
    func restart() {
        score = 0
        scoreLabelNode.text = "Score:\(score)"
        
        bird.position = CGPoint(x: self.size.width * 0.2, y: self.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0
        
        wallNode.removeAllChildren()
        
        bird.speed = 1
        scrollNode.speed = 1
    }
    
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.height-60)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.height-90)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
}


