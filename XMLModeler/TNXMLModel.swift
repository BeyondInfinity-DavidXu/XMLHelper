//
//  TNXMLModel.swift
//  SwiftSyntaxPractise
//
//  Created by 徐伟亭 on 2017/12/12.
//  Copyright © 2017年 TerraNova. All rights reserved.
//

import UIKit

public class XMLModeler {
    
    public struct ParserOptions {
        
        public var shouldProessLazy = false
        
        public var shouldProcessNamespaces = false
        
        public var shouldReportNamespacePrefixes = false
        
        public var shouldResolveExternalEntities = false
        
        public var encoding = String.Encoding.utf8
    }
    
    public typealias ConfigAction = (inout ParserOptions) -> Void
    
    public let options: ParserOptions
    
    public init(_ options: ParserOptions){
        self.options = options
    }
    
    public class func config(_ configAction: ConfigAction) -> XMLModeler{
        var options = ParserOptions()
        configAction(&options)
        return XMLModeler(options)
    }
    
}



public struct XMLAttribute {
    public let name: String
    public let text: String
}

extension XMLAttribute: CustomStringConvertible{
    public var description: String{
        return "\(name)=\"\(text)\""
    }
}

public class XMLElement {
    
    public let name: String
    
    public let index: Int
    
    public var text: String = ""
    
    public var childElement:[XMLElement] = []
    
    public var attributes: [String: XMLAttribute] = [:]
    
    init(name: String, index: Int = 0){
        self.name = name
        self.index = index
    }
    
    public func attribute(name: String) -> XMLAttribute?{
        return attributes[name]
    }
    
    func addChildEelement(name: String, index: Int,attributes: [String: String]) -> XMLElement {
        
        let element = XMLElement(name: name, index: index)
        
        childElement.append(element)
        
        for (key, value) in attributes {
            element.attributes[key] = XMLAttribute(name: key, text: value)
        }
        
        return element
    }
    
}

struct Stack<Element> {
    
    var items = [Element]()
    
    mutating func push(_ item: Element){
        items.append(item)
    }
    
    mutating func pop() -> Element {
        return items.removeLast()
    }
    
    var top:Element{
        return items.last!
    }
    
    mutating func removeAll(){
        items.removeAll(keepingCapacity: false)
    }
}


public let RootElementName = "XMLModelerParserRootElementName"

public class XMLModelerParser: NSObject, XMLParserDelegate{
    
    var root = XMLElement(name: RootElementName)
    
    var parentStack = Stack<XMLElement>()
    
    func parse(_ data: Data) -> XMLElement {
        
        parentStack.removeAll()
        
        parentStack.push(root)
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return root
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        let index = parentStack.items.count
        
        let currentNode = parentStack.top.addChildEelement(name: elementName, index: index, attributes: attributeDict)
        
        parentStack.push(currentNode)
    
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {

        parentStack.top.text += string
        
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        _ = parentStack.pop()
    }
    
    
}



























