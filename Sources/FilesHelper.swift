//
//  File.swift
//  
//
//  Created by David Pařízek on 24.05.2024.
//

import Foundation

final class FilesHelper {
    
    func getFilesFromFolder(folderPath: String) -> [URL] {
        let url = URL(fileURLWithPath: folderPath)
        var files = [URL]()
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    if fileAttributes.isRegularFile! {
                        files.append(fileURL)
                    }
                } catch { print(error, fileURL) }
            }
            return files
        }
        
        return []
    }
    
    func createFile(path: String, filename: String, content: String) throws {
        if (FileManager.default.createFile(atPath: path + "/\(filename).swift", contents: content.data(using: .utf8), attributes: nil)) {
            print("\(filename) created successfully at \(path)")
        } else {
            print("File not created.")
        }
    }
    
}
