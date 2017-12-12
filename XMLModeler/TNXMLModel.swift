//
//  TNXMLModel.swift
//  SwiftSyntaxPractise
//
//  Created by 徐伟亭 on 2017/12/12.
//  Copyright © 2017年 TerraNova. All rights reserved.
//

import UIKit



public struct XMLAttribute {
    public let name: String
    public let text: String
}

extension XMLAttribute: CustomStringConvertible{
    public var description: String{
        return "\(name)=\"\(text)\""
    }
}

public struct XMLElement {
    
    public let name: String
    
    public var text: String?
    
    public var attributes: [String: XMLAttribute]?
    
    public var childElement:[XMLElement] = []
    
//    public var index: Int
    
    public var count: Int?{
        return childElement?.count
    }
    
    init(name: String,
         attributes:[String: XMLAttribute]?,
         text: String?,
         childElement: [XMLElement]?)
    {
        self.name = name
        self.text = text
        self.attributes = attributes
        self.childElement = childElement
    }
    
    public func attribute(name: String) -> XMLAttribute?{
        return attributes?[name]
    }
    
    mutating func addElement(child: XMLElement){
        if self.childElement == nil{
            self.childElement = []
        }
        self.childElement!.append(child)
    }
    
    @discardableResult
    mutating func addEelement(name: String,
                              attributes: [String: XMLAttribute]?,
                              text: String?,
                              childElement: [XMLElement]?) -> XMLElement
    {
        let element = XMLElement(name: name,
                                 attributes: attributes,
                                 text: text,
                                 childElement: childElement)
        
        if self.childElement == nil{
            self.childElement = []
        }
        self.childElement!.append(element)
        return element
    }
    
}

extension XMLElement: CustomStringConvertible{
    public var description: String{
        
        var description = [String]()
        
        var startTag = name
        
        if let attributes = self.attributes {
            startTag += attributes.reduce(""){ $0 + " " + $1.value.description}
        }
        
        description.append("<\(startTag)>")
        
        let separator:String
        
        if let child = childElement {
            
            for item in child {
                description.append("  \(item.description)")
            }
            
            separator = "\n"
            
            if let text = self.text {
                description.insert("  \(text)", at: 1)
            }
            
        }else{
            separator = ""
            
            if let text = self.text {
                description.insert(text, at: 1)
            }
        }
        
        description.append("</\(name)>")
        
        return description.joined(separator: separator)
    }
}


























