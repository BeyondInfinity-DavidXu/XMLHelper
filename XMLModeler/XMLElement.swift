//
//  XMLElement.swift
//  XMLModeler
//
//  Created by 徐伟亭 on 2017/12/21.
//  Copyright © 2017年 TerraNova. All rights reserved.
//

import UIKit

/// Define the XML element
public class XMLElement {
    
    /// Define the XML element attribute
    public struct Attribute{
        
        /// The name of the attribute
        public let name: String
        
        /// The text of the attribute
        public let text: String
    }
    
    /// The name of the element
    public let name: String
    
    /// Indicates that the current element in the element hierarchy
    public var index: Int
    
    /// The text of the element, if it not exists,the string is empty
    public var text: String = ""
    
    /// The child elements of the element, if it not exists,the array is empty
    public var childElement: [XMLElement] = []
    
    ///The attributes of the element,if it not exists,the dictionary is empty
    public var attributes: [String: Attribute] = [:]

    /// Create and return an element
    internal init(name: String, index: Int = 0){
        self.name = name
        self.index = index
    }
    
    internal func addChildElement(name: String,index: Int,attributes: [String: String]) -> XMLElement
    {
        let element = XMLElement(name: name, index: index)
        
        childElement.append(element)
        
        for (key, value) in attributes {
            element.attributes[key] = Attribute(name: key, text: value)
        }
        
        return element
    }
    
    func thorough(operation: (XMLElement) -> Void ) {
        operation(self)
        childElement.forEach{ $0.thorough(operation: operation) }
    }
}


extension XMLElement.Attribute: CustomStringConvertible{
    
    public var description: String{
        return "\(name)=\"\(text)\""
    }
}

extension XMLElement: CustomStringConvertible{
    
    public var description: String{
        
        let attributesString = attributes.reduce("", { $0 + " " + $1.1.description })
        
        var startTag = String(repeating: "    ", count: index) + "<\(name)\(attributesString)>"
        if !childElement.isEmpty { startTag += "\n"}
        
        var endTag: String
        if childElement.isEmpty {
            endTag = "</\(name)>"
        }else{
            endTag = String(repeating: "    ", count: index) + "</\(name)>"
        }
        
        if !(index == 0) { endTag += "\n" }
        
        if childElement.isEmpty {
            return startTag + text + endTag
        }else{
            let mid = childElement.reduce("") {$0 + $1.description}
            return startTag + mid + endTag
        }
    }
}


extension XMLElement: NSCopying{
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let element = XMLElement(name: name, index: index)
        element.text = text
        element.attributes = attributes
        element.childElement = childElement.map{ $0.copy() as! XMLElement }
        return element
    }
}

