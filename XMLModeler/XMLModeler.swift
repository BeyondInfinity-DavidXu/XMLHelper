//
//  XMLModeler.swift
//  SwiftSyntaxPractise
//
//  Created by 徐伟亭 on 2017/12/12.
//  Copyright © 2017年 TerraNova. All rights reserved.
//

import UIKit

/// Use the XMLModel the possibility of error
public enum XMLModelError: Error{
    case `default`
    case unsupportKey
    case wrongKey
    case unknowInitValue
    case outOfIndex
    case unsupportIndex
    case noEelement
}

extension XMLModelError: CustomNSError{
    public static var errorDomain: String{ return "XMLModel_Error" }
    
    public var errorUserInfo: [String : Any]{
        switch self {
        case .default:
            return [NSLocalizedDescriptionKey: "the default error"]
        case .unsupportKey:
            return [NSLocalizedDescriptionKey: "the current level of xml is list,The key is not supported"]
        case .unsupportIndex:
            return [NSLocalizedDescriptionKey: "the current level of xml is single,The index is not supported"]
        case .wrongKey:
            return [NSLocalizedDescriptionKey: "the key is not the current element name"]
        case .unknowInitValue:
            return [NSLocalizedDescriptionKey: "the value is not the XMLModel Init acceptable"]
        case .outOfIndex:
            return [NSLocalizedDescriptionKey: "the index value out of index"]
        case .noEelement:
            return [NSLocalizedDescriptionKey: "Current XMLModel has no element"]
        }
    }
}
/**
 当前错误处理方式来自SwiftyJSON,实际上缺少错误处理的方式，这种错误处理的方式缺少反馈，不能准确的定位错误，只是提供了大概的错误方向
 */

/// Used for packaging, parsing, and obtain the XML data
public class XMLModel {
    
    private enum RawType {
        case list,single,error
    }
    
    private var rawType: RawType = .error
    private var rawlist:[XMLElement] = []
    private var rawSingle:XMLElement = XMLElement(name: "")
    private var error: XMLModelError = .default
    
    private var rootValue: Any{
        get{
            switch rawType {
            case .list:
                return rawlist
            case .single:
                return rawSingle
            case .error:
                return error
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
            case let error as XMLModelError:
                rawType = .error
                self.error = error
            default:
                rawType = .error
                error = XMLModelError.unknowInitValue
            }
        }
    }

    private init(rootValue:Any){
        self.rootValue = rootValue
    }
}

extension XMLModel {
    
    /// Used to set the resolution options, currently only support shouldProcessNamespaces
    public struct ParseOptions: OptionSet{
        public let rawValue: UInt
        public init(rawValue: UInt){ self.rawValue = rawValue }
        public static let shouldProcessNamespaces = ParseOptions(rawValue: 0)
    }
    
    /// The core init func
    public convenience init(data: Data, options: ParseOptions = []){
        let root = XMLModelParser().parse(data: data, options: options)
        self.init(rootValue: root)
    }
}
/**
 当前的初始化方法只有最核心的方法，后期会加入一些更加便捷的方法，同时也会带来更多的错误，在错误处理没有完全准备好之前，只提供最核心的初始化方法，这其中的错误处理也就交给了使用者
 */

/// subscript
extension XMLModel{
    
    public subscript(key: String) -> XMLModel {
        switch rawType{
        case .single:
            let match = rawSingle.childElement.filter{ $0.name == key }
            let copyMatch = match.map{ $0.copy() as! XMLElement }
            copyMatch.forEach{ $0.filterThorough{ $0.index -= 1 } }
            if copyMatch.count == 1 {
                return XMLModel(rootValue: copyMatch[0])
            }else if copyMatch.count > 1 {
                return XMLModel(rootValue: copyMatch)
            }else{
                return XMLModel(rootValue: XMLModelError.wrongKey)
            }
        default:
            return XMLModel(rootValue: XMLModelError.unsupportKey)
        }
    }
    
    public subscript(index: Int) -> XMLModel{
        switch rawType{
        case .list:
            if rawlist.count > index{
                return XMLModel(rootValue: rawlist[index])
            }else{
                return XMLModel(rootValue: XMLModelError.outOfIndex)
            }
        default:
            return XMLModel(rootValue: XMLModelError.unsupportIndex)
        }
    }
    
    private func filterElements(_ operate: (XMLElement) -> ()) {
        switch rawType {
        case .single:
            rawSingle.filterThorough(operate)
        case .list:
            rawlist.forEach{ $0.filterThorough(operate) }
        case .error:
            fatalError(error.localizedDescription)
        }
    }
    
    public var element: XMLElement{
        switch rawType {
        case .single:
            return rawSingle
        default:
            fatalError(XMLModelError.noEelement.localizedDescription)
        }
    }
    
    public var elementValue: XMLElement?{
        switch rawType {
        case .single:
            return rawSingle
        default:
            return nil
        }
    }
    
    public var text: String{
        if element.text.isEmpty {
            fatalError("The element has no text")
        }else{
            return element.text
        }
    }
    
    public var textValue: String?{
        if element.text.isEmpty {
            return nil
        }else{
            return element.text
        }
    }
    
}

extension XMLModel: CustomStringConvertible{
    
    public var description: String{
        switch rawType {
        case .single:
            return self.rawSingle.description
        case .list:
            var string = [String]()
            rawlist.forEach{ string.append($0.description) }
            return string.joined(separator: "\n")
        case .error:
            return error.localizedDescription
        }
    }
}

/// Real XML parsing, the class implements the necessary XMLParserDelegate method
fileprivate class XMLModelParser: NSObject, XMLParserDelegate{
    
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
    
    private let RootElementName = "XMLModelerParserRootElementName"
    
    private var parentStack = Stack<XMLElement>()
    
    func parse(data: Data, options:XMLModel.ParseOptions) -> XMLElement {
        
        parentStack.removeAll()
        
        let root = XMLElement(name: RootElementName)
        
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
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        let index = parentStack.items.count
        let currentNode = parentStack.top.addChildEelement(name: elementName, index: index, attributes: attributeDict)
        parentStack.push(currentNode)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if let first = string.first,first != "\n" {
            parentStack.top.text += string
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        _ = parentStack.pop()
    }
}


/// The XML element attribute model
public struct XMLAttribute {
    /// The name of the attribute
    public let name: String
    /// The text of the attribute
    public let text: String
}

extension XMLAttribute: CustomStringConvertible{
    public var description: String{
        return "\(name)=\"\(text)\""
    }
}

/// The XML element model
public class XMLElement {
    
    /**
     The name of the element,
     the name default is let, in order to follow the NSCopying protocol into a variable
     */
    public var name: String
    
    /// The hierarchy of elements
    public var index: Int
    
    /// The text of the element, if it not exists,the string is empty
    public var text: String = ""
    
    /// The child elements of the element, if it not exists,the array is empty
    public var childElement:[XMLElement] = []
    
    /// The attributes of the element,if it not exists,the dictionary is empty
    public var attributes: [String: XMLAttribute] = [:]
    
    /// The specify name attribute
    public func attribute(name: String) -> XMLAttribute?{
        return attributes[name]
    }
    
    fileprivate init(name: String, index: Int = 0){
        self.name = name
        self.index = index
    }
    
    fileprivate func addChildEelement(name: String, index: Int,attributes: [String: String]) -> XMLElement {
        
        let element = XMLElement(name: name, index: index)
        
        childElement.append(element)
        
        for (key, value) in attributes {
            element.attributes[key] = XMLAttribute(name: key, text: value)
        }
        
        return element
    }
    
    fileprivate func filterThorough(_ operate: (XMLElement) -> ()) {
        operate(self)
        childElement.forEach{ $0.filterThorough(operate) }
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


































