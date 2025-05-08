//
//  Logger.swift
//  QikiTest
//
//  Created by Miamedia Developer on 08/04/24.
//

import Foundation
import Logger

struct Log {
    public static var shared = Log()
    public var logFileURL = URL.init(string: "")
    private var fileLogging: FileLogging?
    public var fileLogHandler: FileLogHandler?
    
    public mutating func initialiseLogger() {
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, 
                                                             in: .userDomainMask,
                                                             appropriateFor: nil,
                                                             create: false
        )
        logFileURL = documentDirectory.appendingPathComponent("Logs.log")
        
        do {
            fileLogging = try FileLogging.init(to: logFileURL!)
        } catch {
            print("Cannot initialise file logging...")
        }
        
        guard fileLogging != nil else {
            return
        }
        fileLogHandler = fileLogging!.handler(label: "")
    }
    
    public mutating func writeToLogFile(atLevel level: LogLevel,
                                        withMessage message: @autoclosure () -> String
    ) {
        guard fileLogHandler != nil else {
            return
        }
        
        fileLogHandler!.log(level: level,
                            message: message()
        )
    }
}
