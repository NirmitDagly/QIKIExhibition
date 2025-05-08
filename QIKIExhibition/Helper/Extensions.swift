//
//  Extensions.swift
//  QikiTest
//
//  Created by Miamedia Developer on 09/08/24.
//

import Foundation

extension Bool {
    func isTodayWeeekend() -> Bool {
        let date = Date()
        let calendar = Calendar.current
        
        if calendar.isDateInWeekend(date) {
            return true
        } else {
            return false
        }
    }
    
    func toString() -> String {
        return self ? "true" : "false"
    }
}

extension DispatchQueue {
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async(flags: .barrier, execute: {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    completion()
                }
            }
        })
    }
    
    private struct QueueReference { weak var queue: DispatchQueue? }
    
    private static let key: DispatchSpecificKey<QueueReference> = {
        let key = DispatchSpecificKey<QueueReference>()
        setupSystemQueuesDetection(key: key)
        return key
    }()
    
    private static func registerDetection(of queues: [DispatchQueue], key: DispatchSpecificKey<QueueReference>) {
        queues.forEach { $0.setSpecific(key: key, value: QueueReference(queue: $0)) }
    }
    
    private static func setupSystemQueuesDetection(key: DispatchSpecificKey<QueueReference>) {
        let queues: [DispatchQueue] = [
            .main,
            .global(qos: .background),
            .global(qos: .default),
            .global(qos: .unspecified),
            .global(qos: .userInitiated),
            .global(qos: .userInteractive),
            .global(qos: .utility)
        ]
        registerDetection(of: queues, key: key)
    }
    
    static func registerDetection(of queue: DispatchQueue) {
        registerDetection(of: [queue], key: key)
    }
    
    static var currentQueueLabel: String? { current?.label }
    
    static var current: DispatchQueue? { getSpecific(key: key)?.queue }
}
