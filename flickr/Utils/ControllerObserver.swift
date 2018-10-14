//
//  ControllerObserver.swift
//  flickr
//
//  Created by Jade McPherson on 10/13/18.
//  Copyright © 2018 Jade McPherson. All rights reserved.
//

import Foundation

private class BrittleWrapper {
    weak var value: AnyObject?
    
    init(value: AnyObject) {
        self.value = value
    }
}

class ControllerObserver<T> {
    fileprivate var weakObservers = [BrittleWrapper]()
    
    func addObserver(_ observer: T) {
        weakObservers.append(BrittleWrapper(value: observer as AnyObject))
    }
    
    func removeObserver(_ observer: T) {
        guard weakObservers.count > 0 else { return }
        for (index, o) in weakObservers.enumerated().reversed() {
            if o.value === (observer as AnyObject) {
                weakObservers.remove(at: index)
            }
        }
    }
    
    func invoke(_ invocation: (T) -> ()) {
        for (index, o) in weakObservers.enumerated().reversed() {
            if let ov = o.value as? T {
                invocation(ov)
            } else {
                //weak instances got killed so remove them
                weakObservers.remove(at: index)
            }
        }
    }
}

