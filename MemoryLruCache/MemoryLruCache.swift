//
//  MemoryLruCache.swift
//  MemoryLruCache
//
//  Created by joinhov on 16/8/26.
//  Copyright © 2016年 chengkaizone. All rights reserved.
//

import UIKit

/**
 图片内存缓存算法(FIFO)
 注意同步问题
 */
public class MemoryLruCache {
    
    private var lock: NSLock!
    // 保存图片引用
    private var dataCache: [String:UIImage]!
    // 用于保存顺序 --- 维护lru算法(开销会比新建对象来维护要小)
    private var orderKeys: [String]!
    
    private var maxCapacity: Int = 100;
    
    class func sharedInstance() ->MemoryLruCache {
        
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: MemoryLruCache!
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = MemoryLruCache(maxCapacity: 100)
        }
        
        return Static.instance
    }
    
    private init(maxCapacity: Int) {
        
        lock = NSLock()
        self.maxCapacity = maxCapacity
        dataCache = [String : UIImage]()
        orderKeys = [String]()
    }
    
    public class func initConfig(maxCapacity: Int) {
        
        MemoryLruCache.sharedInstance().maxCapacity = maxCapacity
    }

    /// 用下标保存图片
    public class func put(key: String!, image: UIImage!) ->Void {
        
        if image == nil {
            NSLog("image is nil.");
            return
        }
        
        if key == nil {
            NSLog("key is nil.");
            return
        }
        
        let instance = MemoryLruCache.sharedInstance()
        
        instance.lock.lock()
        
        let cacheImage = instance.dataCache[key]
        if cacheImage != nil {// 直接替换数据
            instance.dataCache[key] = image
            instance.lock.unlock()
            return
        }
        
        instance.dataCache[key] = image
        instance.orderKeys.append(key)
        
        if instance.dataCache.count > instance.maxCapacity {// 清理掉最近没有使用的数据
            // 按照FIFO规则, 移除第一项
            let cacheKey = instance.orderKeys.first!
            instance.dataCache.removeValueForKey(cacheKey)
            instance.orderKeys.removeFirst()
        }
        
        instance.lock.unlock()
    }
    
    /// 用下标获取图片
    public class func value(key: String!) ->UIImage? {
        
        if key == nil {
            return nil
        }
        
        let instance = MemoryLruCache.sharedInstance()
        
        instance.lock.lock()
        if !instance.orderKeys.contains(key) {
            instance.lock.unlock()
            return nil
        }
        
        let cacheImage = instance.dataCache[key]
        
        let index = instance.orderKeys.indexOf(key)!
        instance.orderKeys.removeAtIndex(index)
        // 排序 放到最后的位置
        instance.orderKeys.append(key)
        
        instance.lock.unlock()
        return cacheImage
    }
    
    /** 取出第一个元素 */
    public class func first(removeEnabled: Bool = false) ->UIImage? {
        
        let instance = MemoryLruCache.sharedInstance()
        instance.lock.lock()
        if instance.orderKeys.count == 0 {
            instance.lock.unlock()
            return nil
        }
        
        let key = instance.orderKeys.first!
        
        let cacheImage = instance.dataCache[key]
        if cacheImage == nil {
            instance.lock.unlock()
            return cacheImage
        }
        
        instance.orderKeys.removeFirst()
        
        if removeEnabled {
            instance.dataCache.removeValueForKey(key)
        } else {
            // 排序 放到最后的位置
            instance.orderKeys.append(key)
        }

        instance.lock.unlock()
        return cacheImage
    }
    
    public class func pop() ->UIImage? {
        
        return first(true)
    }
    
    public class func last(removeEnabled: Bool = false) ->UIImage? {
        
        let instance = MemoryLruCache.sharedInstance()
        
        instance.lock.lock()
        if instance.orderKeys.count == 0 {
            instance.lock.unlock()
            return nil
        }
        
        let key = instance.orderKeys.last!
        
        let cacheImage = instance.dataCache[key]
        
        if removeEnabled {
            instance.orderKeys.removeLast()
            instance.dataCache.removeValueForKey(key)
        }
        
        instance.lock.unlock()
        return cacheImage
    }
    
    /// 移除指定图片
    public func remove(key: String) ->UIImage? {
        let instance = MemoryLruCache.sharedInstance()
        instance.lock.lock()
        if instance.orderKeys.count == 0 {
            instance.lock.unlock()
            return nil
        }
        
        let flag = instance.orderKeys.contains(key)
        if flag {
            let image = instance.dataCache.removeValueForKey(key)
            instance.lock.unlock()
            return image
        }
        
        instance.lock.unlock()
        return nil;
    }
    
    /// 清除所有数据
    public class func clear() {
        
        let instance = MemoryLruCache.sharedInstance()
        instance.lock.lock()
        
        instance.orderKeys.removeAll()
        instance.dataCache.removeAll()
        
        instance.lock.unlock()
    }
    
    public class func printLog() {
        
        let instance = MemoryLruCache.sharedInstance()
        instance.lock.lock()
        
        NSLog("orderKeys: \(instance.orderKeys)")
        NSLog("dataCache: \(instance.dataCache)")
        
        instance.lock.unlock()
    }
    

}
