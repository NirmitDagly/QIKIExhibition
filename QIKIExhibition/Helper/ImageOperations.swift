//
//  ImageOperations.swift
//  QikiTest
//
//  Created by Nirmit Dagly on 16/4/2025.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import Logger

public class ImageOperations {
    static let shared = ImageOperations()
    
    func checkImageDirectoryExists() -> Bool {
        var isDirectoryExists = false
        
        let fileManager = FileManager.default
        do {
            let appSupportURL = try fileManager.url(for: .documentDirectory,
                                                    in: .userDomainMask,
                                                    appropriateFor: nil,
                                                    create: true
            )
            
            let directoryURL = appSupportURL.appendingPathComponent("Images",
                                                                    isDirectory: true
            )
            
            if fileManager.fileExists(atPath: directoryURL.path) {
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "Image directory exist at \(directoryURL.path)."
                )
                isDirectoryExists = true
            } else {
                Log.shared.writeToLogFile(atLevel: .error,
                                          withMessage: "Image directory does not exist."
                )
                
                isDirectoryExists = false
            }
        } catch {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "Error occurred while checking image directory existance with: \(error)"
            )
        }
        
        return isDirectoryExists
    }
    
    func createImageDirectory() {
        do {
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(for: .documentDirectory,
                                                    in: .userDomainMask,
                                                    appropriateFor: nil,
                                                    create: true
            )
            
            let directoryURL = appSupportURL.appendingPathComponent("Images",
                                                                    isDirectory: true
            )
            
            try fileManager.createDirectory(at: directoryURL,
                                            withIntermediateDirectories: true
            )
        } catch {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "Error creating database directory or opening database: \(error)"
            )
        }
    }
    
    func getImageDirectoryPath() {
        let fileManager = FileManager.default
        do {
            let appSupportURL = try fileManager.url(for: .documentDirectory,
                                                    in: .userDomainMask,
                                                    appropriateFor: nil,
                                                    create: true
            )
            
            let directoryURL = appSupportURL.appendingPathComponent("Images",
                                                                    isDirectory: true
            )
            
            imageDirectoryPath = directoryURL.path
        } catch {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "Error occurred while checking image directory existance with: \(error)"
            )
        }
    }
    
    func getAssociatedImage(forProduct id: Int) -> (image1: Image, image2: UIImage) {
        var image = Image("QLogo")
        var image1 = UIImage.init()
        let imageURL = imageDirectoryPath.appending("/\(id).png")
            
        if FileManager.default.fileExists(atPath: imageURL) {
            image1 = UIImage.init(contentsOfFile: imageURL)!
            image = Image(uiImage: image1)
        }
        
        return (image, image1)
    }
    
    func checkImageExistsOrNot(forProduct id: Int) -> Bool {
        if FileManager.default.fileExists(atPath: imageDirectoryPath.appending("/\(id).png")) {
            return true
        } else {
            return false
        }
    }
    
    func saveImageToDirectory(atPath path: String,
                              andImage image: UIImage
    ) {
        guard image != UIImage() else {
            Log.shared.writeToLogFile(atLevel: .info,
                                      withMessage: "User has not selected any image. Hence, I am not saving it to local disk.")
            return
        }
        
        if let data = image.pngData() {
            do {
                try data.write(to: URL.init(fileURLWithPath: path)) // Writing an Image in the Documents Directory
            } catch {
                print("Unable to Write Image Data on Disk at path: \(path)")
            }
        }
    }
    
    func deleteImageFromDirectory(atPath path: String) {
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                Log.shared.writeToLogFile(atLevel: .error,
                                          withMessage: "I am unable to find the image in directory to delete at path: \(error)."
                )
            }
        } else {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "I am unable to find the image in directory to delete at path: \(path)."
            )
        }
    }
}
