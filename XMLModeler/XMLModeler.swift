//
//  XMLModeler.swift
//  SwiftSyntaxPractise
//
//  Created by 徐伟亭 on 2017/12/12.
//  Copyright © 2017年 TerraNova. All rights reserved.
//

import UIKit

public class XMLModel {
    
    public struct ParseOptions: OptionSet{
        public let rawValue: UInt
        public init(rawValue: UInt){ self.rawValue = rawValue }
        public static let shouldProcessNamespaces = ParseOptions(rawValue: 0)
        
    }
    
    enum RawType {
        case list,single,null
    }
    
    var rawType: RawType = .null
    
    var rawlist:[XMLElement] = []
    var rawSingle:XMLElement = XMLElement(name: "")
    var rawNull = NSNull()
    
    
    var rootValue: Any{
        get{
            switch rawType {
            case .list:
                return rawlist
            case .single:
                return rawSingle
            case .null:
                return rawNull
            }
        }
        set{
            switch newValue {
            case let single as XMLElement:
                rawSingle = single
                rawType = .single
            case let list as [XMLElement]:
                rawlist = list
                rawType = .list
            default:
                rawNull = NSNull()
                rawType = .null
            }
            
        }
    }
    

    public init(data: Data?, options: ParseOptions = []){
        if let data = data {
            
            let original = XMLModelerParser().parse(data: data, options: options).childElement
            if original.count == 1{
                rootValue = original[0]
            }else if original.count > 1 {
                rootValue = original
            }
        }else{
            /// handle the data is nil error
            fatalError("The data is nil")
        }
    }
    
    public convenience init(xmlString: String, options: ParseOptions = []){
        let data = xmlString.data(using: .utf8)
        self.init(data: data, options: options)
    }
    
    init(rootValue:Any){
        self.rootValue = rootValue
    }
    
    public subscript(key: String) -> XMLModel {
        if rawType == .list && !rawlist.contains(where: { $0.name != key }){
            return self     
        }else if rawType == .single && rawSingle.name == key{
            let new = XMLModel(rootValue: rawSingle.childElement.map{ $0.copy() })
            new.filterElements{ $0.index -= 1 }
            return new
        }else{
            fatalError("chect out the key")
        }
    }
    
    public subscript(index: Int) -> XMLModel{
        if rawType == .list && rawlist.count > index{
            return XMLModel(rootValue: rawlist[index])
        }else{
            fatalError("chect out the index")
        }
    }
    
    func filterElements(_ operate: (XMLElement) -> ()) {
        if rawType == .single {
            rawSingle.filterThorough(operate)
        }else if rawType == .list{
            rawlist.forEach{ $0.filterThorough(operate) }
        }else{
            fatalError("handle the error")
        }
    }
    
}

extension XMLModel: CustomStringConvertible{
    
    public var description: String{
        if rawType == .single {
            return self.rawSingle.description
        }else if rawType == .list{
            var string = [String]()
            rawlist.forEach{ string.append($0.description) }
            return string.joined(separator: "\n")
        }else{
            fatalError("")
        }
    }
}


public let RootElementName = "XMLModelerParserRootElementName"

public class XMLModelerParser: NSObject, XMLParserDelegate{
    
    fileprivate var root = XMLElement(name: RootElementName)
    
    private var parentStack = Stack<XMLElement>()
    
    func parse(data: Data, options:XMLModel.ParseOptions) -> XMLElement {
        
        parentStack.removeAll()
        
        parentStack.push(root)
        
        let parser = XMLParser(data: data)
        
        switch options {
        case .shouldProcessNamespaces:
            parser.shouldProcessNamespaces = true
        default:()
        }
        
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
        
        if let first = string.first,first != "\n" {
            parentStack.top.text += string
        }
        
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        _ = parentStack.pop()
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


/**
 XML 元素模型
 如何将XML元素模型化 ？
 
 */
public class XMLElement {
    
    /// 该属性默认是不变的，为了准守NSCopying协议而改成可变
    public var name: String
    /// 该属性初始认为是不可变，由于支持XMLModel进行unwrap处理，为了重新调整层级关系改为可变
    public var index: Int
    
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

extension XMLElement: NSCopying{
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let element = XMLElement(name: "")
        element.name = name
        element.index = index
        element.text = text
        element.attributes = attributes
        for item in childElement {
            element.childElement.append(item.copy() as! XMLElement)
        }
        return element
    }
}

extension XMLElement: CustomStringConvertible{
    
    public var description: String{
        
        let attributesString = attributes.reduce("", { $0 + " " + $1.1.description })
        
        var startTag = String(repeating: "    ", count: index-1) + "<\(name)\(attributesString)>"
        if !childElement.isEmpty { startTag += "\n"}
        
        var endTag: String
        if childElement.isEmpty {
            endTag = "</\(name)>"
        }else{
            endTag = String(repeating: "    ", count: index-1) + "</\(name)>"
        }
        
        if !(index == 1) { endTag += "\n" }
        
        if childElement.isEmpty {
            return startTag + text + endTag
        }else{
            let mid = childElement.reduce("") {$0 + $1.description}
            return startTag + mid + endTag
        }
    }
    
    func filterThorough(_ operate: (XMLElement) -> ()) {
        operate(self)
        childElement.forEach{ $0.filterThorough(operate) }
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






























