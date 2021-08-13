//
//  RunLoopListener.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 6/21/21.
//

import Foundation

class RunLoopInteractor {
    static let shared = RunLoopInteractor()
    private var lock = NSLock()
    private var eventQueue: [(Animation?) -> Void] = []
    private var animationLock = NSLock()
    private var currentAnimation: Animation?
    
    private func performWithLock<T>(_ work: () -> T) -> T {
        lock.lock()
        let val = work()
        lock.unlock()
        return val
    }
    
    private func performWithAnimationLock(_ work: () -> Void) {
        animationLock.lock()
        work()
        animationLock.unlock()
    }
    
    func emptyQueue() -> [(Animation?) -> Void] {
        return performWithLock {
            let values = eventQueue
            eventQueue = []
            return values
        }
    }
    
    func updateAnimation(_ animation: Animation?) {
        performWithAnimationLock {
            currentAnimation = animation
        }
        
    }
    
    func add(operation: @escaping (Animation?) -> Void) {
        performWithLock {
            eventQueue.append(operation)
        }
    }
    
    private init() {
        let displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink.add(to: .main, forMode: .common)
    }
    
    @objc func tick() {
        var animation: Animation?
        performWithAnimationLock {
            animation = self.currentAnimation
            self.currentAnimation = nil
        }
        self.emptyQueue().forEach { $0(animation) }
    }
}
