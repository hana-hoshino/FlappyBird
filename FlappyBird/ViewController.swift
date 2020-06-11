//
//  ViewController.swift
//  FlappyBird
//
//  Created by 星野　花 on 2020/06/09.
//  Copyright © 2020 Kana.h. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        let scene = GameScene(size:skView.frame.size)
        skView.presentScene(scene)
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
}

