//
//  File.swift
//  
//
//  Created by David Pařízek on 24.05.2024.
//

import Foundation


enum FragmentGeneratorError: Error {
    case noFragmentFieldsFound
    case propertyIncorrectFormat(propertyString: String)
    case noFragmentTypeMappingFound(fragmentName: String)
    
    var readableDescription: String {
        switch self {
        case .noFragmentFieldsFound:
            return "Fragment file properties couldnt be read"
        case .propertyIncorrectFormat(let propertyString):
            return "Found a property that cannot be parsed \(propertyString)"
        case .noFragmentTypeMappingFound(let fragmentName):
            return "Cannot find fragment type mapping for \(fragmentName)"
        }
    }
}

final class FragmentsGenerator {
    
    private let filesHelper: FilesHelper = .init()
    
    func generateFragments() {
        
        let fragmentsFolder = "../Sources/Fragments"
        let fragmentFiles = filesHelper.getFilesFromFolder(folderPath: fragmentsFolder)
        
        for fragmentFile in fragmentFiles {
            do {
                let contents = try String(contentsOf: fragmentFile, encoding: .utf8)
                let lines = contents.split(whereSeparator: \.isNewline).compactMap { String($0) }

                generateFragmentFromFile(fileLines: lines, fileUrl: fragmentFile)
            } catch let error as NSError {
                print("Unable to read fragment file:\n\(fragmentFile.absoluteString)\n\(error)")
                exit(-1)
            }
        }
        
    }
    
    func generateFragmentFromFile(fileLines: [String], fileUrl: URL) {
        do {
            let fieldsWithTypes = try getFragmentFieldsWithType(fileLines: fileLines)
            
            let structName = fileUrl.lastPathComponent
                .replacingOccurrences(of: "Fragment", with: "")
                .replacingOccurrences(of: ".graphql", with: "")
                .replacingOccurrences(of: ".swift", with: "")
            
            let fileConetnt = try generateFragmentFileContent(fragmentFields: fieldsWithTypes, structName: structName)
            try filesHelper.createFile(path: "../Generated/Fragments", filename: structName, content: fileConetnt)
        }
        catch let error as FragmentGeneratorError {
            print("Unable to generate fragment:\n\(fileUrl.absoluteString)\n\(error.readableDescription)")
            exit(-1)
        }
        catch let error as NSError {
            print("Unable to generate fragment:\n\(fileUrl.absoluteString)\n\(error)")
            exit(-1)
        }
    }
    
    func getFragmentFieldsWithType(fileLines: [String]) throws -> [PropertyWithType] {
        guard var firstDefinitionIndex = fileLines.firstIndex(where: { $0.contains("public static var __selections: [ApolloAPI.Selection]") }) else {
            throw FragmentGeneratorError.noFragmentFieldsFound
        }
        
        firstDefinitionIndex += 1
        var properties: [PropertyWithType] = []
        
        repeat {
            var currentLineText = fileLines[firstDefinitionIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            
            currentLineText = currentLineText
                .replacingOccurrences(of: ".field(", with: "")
                .replacingOccurrences(of: "\"", with: "")
                .replacingOccurrences(of: ".self", with: "")
                .replacingOccurrences(of: ")", with: "")
                .replacingOccurrences(of: " ", with: "")
            
            currentLineText = String(currentLineText.dropLast())
            
            let fieldNameWithType = currentLineText.components(separatedBy: ",")
            
            guard fieldNameWithType.count == 2 else {
                throw FragmentGeneratorError.propertyIncorrectFormat(propertyString: currentLineText)
            }
            
            if PropertyTypeHelper.isBasicType(property: fieldNameWithType[1]) {
                // Field is basic type so we can basically add it to mapped struct
                properties.append(.init(propertyName: fieldNameWithType[0], propertyType: fieldNameWithType[1]))
            } else {
                // Property is not basic type (Int, String, Bool) so we should try to find mapping in the same definition file
                do {
                    let mappedType = try mapApolloTypeToFragment(typeName: fieldNameWithType[1], fileLines: fileLines)
                    properties.append(.init(propertyName: fieldNameWithType[0], propertyType: mappedType))
                } catch FragmentGeneratorError.noFragmentTypeMappingFound {
                    // No mapping found, append defined type and create nested struct
                    properties.append(.init(propertyName: fieldNameWithType[0], propertyType: fieldNameWithType[1]))
                } catch FragmentGeneratorError.noFragmentFieldsFound {
                    // No mapping found
                    properties.append(.init(propertyName: fieldNameWithType[0], propertyType: fieldNameWithType[1]))
                }
            }
            
            firstDefinitionIndex += 1
        } while fileLines[firstDefinitionIndex].contains(".field")
        
        return properties.filter { $0.propertyName != "__typename" }
    }
    
    func mapApolloTypeToFragment(typeName: String, fileLines: [String]) throws -> String {
        let propertyType = PropertyTypeHelper.getNonOptionalPropertyType(property: typeName)
        
        guard let structDefinitionLine = fileLines.firstIndex(where: { $0.contains("public struct \(propertyType): GQLZ.SelectionSet") }) else {
            throw FragmentGeneratorError.noFragmentFieldsFound
        }
        
        let typeStructLines = Array(fileLines[structDefinitionLine...fileLines.count - 1])
        guard let fragmentTypeLine = typeStructLines.firstIndex(where: { $0.contains(".fragment(") }) else {
            throw FragmentGeneratorError.noFragmentTypeMappingFound(fragmentName: typeName)
        }
        
        let resultType = typeStructLines[fragmentTypeLine]
            .replacingOccurrences(of: "Fragment", with: "")
            .replacingOccurrences(of: ".fragment(", with: "")
            .replacingOccurrences(of: ".self),", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        
        
        return typeName.replacingOccurrences(of: propertyType, with: resultType)
    }
    
    func generateFragmentFileContent(fragmentFields: [PropertyWithType], structName: String) throws -> String {
        let fileName = structName + ".swift"
        
        var propertiesString: String = ""
        
        for property in fragmentFields {
            let printedProperty = "   let \(property.propertyName): \(property.propertyType)\n"
            propertiesString += printedProperty
        }
        
        let fileContent = """
//
//  \(fileName)
//
//  Created on \(Date())
//  Do not change this file. Every changes will be removed during next generation process
//

struct \(structName) {

\(propertiesString)
}
"""

        return fileContent
    }
    
}
