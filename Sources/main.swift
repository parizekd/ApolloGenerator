// The Swift Programming Language
// https://docs.swift.org/swift-book


import ArgumentParser
import Foundation

struct FilesGenerator: ParsableCommand {
    
    func run() {
        let fragmentsGenerator = FragmentsGenerator()
        fragmentsGenerator.generateFragments()
        
        
        
//        let path = "../Sources/Operations/Queries/GetArticleDetailQuery.graphql.swift"
        
       
        
        
//
//        do {
//            let contents = try String(contentsOfFile: path, encoding: .utf8)
//            let lines = contents.split(whereSeparator: \.isNewline).compactMap { String($0) }
//
//            
////           getFragmentsDefinitionFromQuery(queryFileLines: lines)
////
//            var x = 0
//            
//        } catch let error as NSError {
//            print("Ooops! Something went wrong: \(error)")
//        }
        
    }

    
    
//
//    private func getFragmentsDefinitionFromQuery(queryFileLines: [String]) -> [String] {
//        
////      Find apollo query definition
//        var fragmentIndexex: [Int] = queryFileLines.enumerated().compactMap {
//            $1.contains("public static let operationDocument: ApolloAPI.OperationDocument") ? $0 : nil
//        }
//        
////      Fragments are always defined three lines below query definition
//        fragmentIndexex = fragmentIndexex.compactMap { $0 + 3 }
//        
//        
//        var result: [String] = []
//        for index in fragmentIndexex {
//            if queryFileLines[index].contains("fragments: ") {
//                var resultString = queryFileLines[index].replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
//
//                resultString = resultString.replacingOccurrences(of: "fragments:", with: "", options: NSString.CompareOptions.literal, range: nil)
//                resultString = resultString.replacingOccurrences(of: "[", with: "", options: NSString.CompareOptions.literal, range: nil)
//                resultString = resultString.replacingOccurrences(of: "]", with: "", options: NSString.CompareOptions.literal, range: nil)
//                resultString = resultString.replacingOccurrences(of: ".self", with: "", options: NSString.CompareOptions.literal, range: nil)
//                
//                
//                let splittedFragments = resultString.split(separator: (",")).compactMap { String($0) }
//                
//                result.append(contentsOf: splittedFragments)
//            }
//        }
//        
//        
//        return result
//    }
    
}

FilesGenerator.main()
