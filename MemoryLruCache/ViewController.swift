//
//  ViewController.swift
//  MemoryLruCache
//
//  Created by joinhov on 16/8/26.
//  Copyright © 2016年 chengkaizone. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        image = UIImage(named: "AppIcon")
        
        MemoryLruCache.put("111", image: image)
        MemoryLruCache.put("222", image: image)
        MemoryLruCache.put("333", image: image)
        MemoryLruCache.put("222", image: image)
        MemoryLruCache.put("444", image: image)
        
        
        MemoryLruCache.printLog()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBOutlet weak var addAction: UIButton!
    @IBAction func addAction(sender: AnyObject) {
        
        MemoryLruCache.put("\(NSDate())", image: image)
        
        MemoryLruCache.printLog()
    }

    @IBAction func firstAction(sender: AnyObject) {
        
        MemoryLruCache.first()
        MemoryLruCache.printLog()
    }
    
    @IBAction func lastAction(sender: AnyObject) {
        
        MemoryLruCache.last()
        MemoryLruCache.printLog()
    }
    
    @IBAction func popAction(sender: AnyObject) {
        
        MemoryLruCache.pop()
        MemoryLruCache.printLog()
    }
    
}

