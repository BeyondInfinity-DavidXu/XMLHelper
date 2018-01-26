//
//  XMLElement.swift
//  XMLModeler
//
//  Created by 徐伟亭 on 2018/1/24.
//  Copyright © 2018年 TerraNova. All rights reserved.
//

import Foundation

/// Represent the XML element
public class XMLElement: CustomStringConvertible{
    
    /// Define the XML element attribute
    public struct Attribute: CustomStringConvertible{
        
        /// The name of the attribute
        public let name: String
        
        /// The text of the attribute
        public let text: String
        
        public var description: String{
            return "\(name)=\"\(text)\""
        }
    }
    
    /// The name of the element
    public let name: String
    
    /// Indicates that the current element in the element hierarchy
    public var level: Int
    
    /// The text of the element, if the text is not exist,the string is empty
    public var text: String = ""
    
    /// The child elements of the element, if it not exists,the array is empty
    public var childElements: [XMLElement] = []
    
    ///The attributes of the element,if it not exists,the dictionary is empty
    public var attributes: [String: Attribute] = [:]
    
    /// Create and return an element
    public init(name: String,
                level: Int = 0,
                attributes: [String: Attribute] = [:])
    {
        self.name = name
        self.level = level
        self.attributes = attributes
    }
    
    public func addChild(element: XMLElement){
        childElements.append(element)
    }
    
    internal func addChildElement(name: String, level: Int, attributes: [String: String]) -> XMLElement
    {
        let element = XMLElement(name: name, level: level)
        
        childElements.append(element)
        
        for (key, value) in attributes {
            element.attributes[key] = Attribute(name: key, text: value)
        }
        
        return element
    }
    
    public func thorough(operation: (XMLElement) -> Void ) {
        operation(self)
        childElements.forEach{ $0.thorough(operation: operation) }
    }
    
    public func removeEmptyElements(){
        childElements = childElements.filter{ !($0.text.isEmpty && $0.childElements.isEmpty) }
        childElements.forEach{ $0.removeEmptyElements() }
    }
    
    /// The xml description
    public var description: String{
        
        let attributesString = attributes.reduce("", { $0 + " " + $1.1.description })
        
        var startTag = String(repeating: "    ", count: level) + "<\(name)\(attributesString)>"
        if !childElements.isEmpty { startTag += "\n"}
        
        var endTag: String
        if childElements.isEmpty {
            endTag = "</\(name)>"
        }else{
            endTag = String(repeating: "    ", count: level) + "</\(name)>"
        }
        
        if !(level == 0) { endTag += "\n" }
        
        if childElements.isEmpty {
            return startTag + text + endTag
        }else{
            let mid = childElements.reduce("") {$0 + $1.description}
            return startTag + mid + endTag
        }
    }
    
    public var copy: XMLElement{
        let copy = XMLElement(name: name, level: level, attributes: attributes)
        copy.text = text
        copy.childElements = childElements.map{ $0.copy }
        return copy
    }
    
    /// The interface Convert to json
    public var dictionary: [String: Any]{
        if childElements.isEmpty {
            return [name: text]
        }else if childElements.count == 1{
            return [name: childElements.first!.dictionary]
        }else{
            let dicts = childElements.map{ $0.dictionary }
            
            var dict: [String: Any] = [:]
            
            var isArray = !dicts.contains{ $0.keys.count != 1 }
            
            if isArray == true{
                let keys = dicts.map{$0.keys.first!}
                var optionKey: String?
                for key in keys{
                    if optionKey == nil{
                        optionKey = key
                    }else{
                        if key != optionKey{
                            isArray = false
                        }
                    }
                }
            }
            
            if isArray{
                return [name: dicts]
            }else{
                for item in dicts{
                    for (key,value) in item{
                        dict[key] = value
                    }
                }
                return [name: dict]
            }
        }
    }
    
}










