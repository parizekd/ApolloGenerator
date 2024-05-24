//
//  File.swift
//  
//
//  Created by David Pařízek on 24.05.2024.
//

import Foundation
import RegexBuilder

final class PropertyTypeHelper {
    
    enum BasicTypes: String {
        case integer = "Int"
        case optionalInteger = "Int?"
        case string = "String"
        case optionalString = "String?"
        case bool = "Bool"
        case optionalBool = "Bool?"
    }
    
    static func isArray(propety: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "\\[[^\\]]*\\]", options: [.caseInsensitive])
        let range = NSRange(location: 0, length: propety.count)
        let matches = regex.matches(in: propety, options: [], range: range)
        return matches.first != nil
    }
    
    static func getPropertyTypeWithoutArrayBrackets(property: String) -> String {
        var testable = property
        if testable.first == "[" && testable.last == "?" {
            testable = String(testable.dropLast())
        }
        
        if Self.isArray(propety: testable) {

            testable = String(String(testable.dropFirst()).dropLast())
        }
        
        return testable
    }
    
    static func getNonOptionalPropertyType(property: String) -> String {
        var result = Self.getPropertyTypeWithoutArrayBrackets(property: property)
        
        if result.last == "?" {
            result = String(result.dropLast())
        }
        
        return result
    }
    
    static func isBasicType(property: String) -> Bool {
        let testable = Self.getPropertyTypeWithoutArrayBrackets(property: property)
        
        return BasicTypes(rawValue: testable) != nil
    }
    
}
