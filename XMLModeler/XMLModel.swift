//
//  XMLModel.swift
//  XMLModel
//
//  Created by GeekXiaowei on 2017/12/12.

import UIKit

/// Can the element out and into the stack
fileprivate protocol Stackable {
    
    associatedtype Element
    
    mutating func push(_ element:Element)
    
    mutating func pop() -> Element?
    
    var top: Element? { get }
}

/// A stack for parse the xml elemnt
fileprivate struct XMLParseStack: Stackable {
    
    private var items: [XMLElement] = []
    
    /// Push new element into the stack
    fileprivate mutating func push(_ element: XMLElement) {
        items.append(element)
    }
    
    @discardableResult
    /// Pop the last element out the stack and return the last element if current stack have one
    fileprivate mutating func pop() -> XMLElement? {
        if items.isEmpty {
            return nil
        }else{
            return items.removeLast()
        }
    }
    
    /// The top element of the stack if the cyrrent stack have one
    fileprivate var top: XMLElement?{ return items.last }
    
    /// Remove all element from stack and with out keeping capacity
    fileprivate mutating func removeAll(){
        items.removeAll(keepingCapacity: false)
    }
    
    /// The count of stack items
    fileprivate var count: Int{
        return items.count
    }
}

/// The possible errors in the process of parsing xml
public enum XMLModelError: String,Error{
    case null = "The XMLModel is null"
    case invalidXMLSting = "The xml string can't be convert to data using UTF8"
    case fileNameError = "Can't find the name of the file in main bundle"
}

/// `XMLModel` represent the xml data,
/// The xml data possible an single XMLElement include some children elements,
/// or a list of XMLElement at the same level.
/// `XMLModel` also responsible for parsing XML data, xml string and xml file
public class XMLModel: NSObject {

    private enum RawType {
        case list,single,error
    }

    private var rawType: RawType = .error
    private var rawlist:[XMLElement] = []
    private var rawSingle:XMLElement = XMLElement(name: "")
    private var error: XMLModelError = .null

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
                error = XMLModelError.null
            }
        }
    }
    
    private init(rootValue: Any) {
        super.init()
        self.rootValue = rootValue
    }
    
    private var parentElementStack: XMLParseStack?
    
    private var parseError: Error?
    
    /**
     The core init method,Passing data for parse and config options,can throw errors
     
     - parameter data: the xml data for parse
     
     - parameter options: the xml parsing options
     
     - returns : an XMLModel object or throw a error
     */
    public init(data: Data, options: ParseOptions = []) throws {
        super.init()
        
        parentElementStack = XMLParseStack()
        
        let root = XMLElement(name: root_name)
        
        parentElementStack?.push(root)
        
        let parser = XMLParser(data: data)
        
        parser.delegate = self
        
        parser.parse()
        
        if let error = self.parseError {
            throw error
        }else{
            self.rootValue = root
        }
    }
}

extension XMLModel {
    
    public override var description: String{
        switch rawType {
        case .single:
            return self.rawSingle.description
        case .list:
            var string = [String]()
            rawlist.forEach{ string.append($0.description) }
            return string.joined(separator: "\n")
        case .error:
            return error.rawValue
        }
    }
}

let root_name = "xml_model_root_name"

extension XMLModel: XMLParserDelegate{
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        let currentNode = parentElementStack!.top!
        
        let cutrrentIndex = parentElementStack!.count
        
        let childNode = currentNode.addChildElement(name:elementName, index:cutrrentIndex, attributes: attributeDict)
        
        parentElementStack?.push(childNode)
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        if let first = string.first,first != "\n" {
            parentElementStack?.top?.text += string
        }
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        parentElementStack?.pop()
    }
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError
    }
    
}


extension XMLModel {

    /// Some xml parse options
    public struct ParseOptions: OptionSet{
        public let rawValue: UInt
        public init(rawValue: UInt){ self.rawValue = rawValue }
        ///
        public static let shouldProcessNamespaces = ParseOptions(rawValue: 0)
    }

    /**
     The convenience init method,for parse xml string with options,can throw errors
     
     - parameter xmlString: the xml string for parse,the string will be convert to data using UTF8
     
     - parameter options: the xml parsing options
     
     - returns : an XMLModel object or throw a error
     */
    public convenience init(xmlString: String, options: ParseOptions = []) throws {
        guard let data = xmlString.data(using: .utf8) else {
            throw XMLModelError.invalidXMLSting
        }
        try self.init(data: data, options: options)
    }
    
    /**
     The convenience init method,Passing xml file name for parse and config options
     
     - parameter xmlfile: the xml file for parse,the string will be convert to data using UTF8
 
     - parameter options: the xml parsing options
     
     - returns : an XMLModel object or throw a error
     */
    public convenience init(xmlfile name: String, options: ParseOptions = []) throws {
        guard let url = Bundle.main.url(forResource: name, withExtension: "xml") else {
            throw XMLModelError.fileNameError
        }
        let data = try Data(contentsOf: url)
        try self.init(data: data, options: options)
    }
    
    /// Just the wrapper of `init(data: Data, options: ParseOptions = []) throws`,the init method throw error cause crash
    public class func parse(data: Data, options: ParseOptions = []) -> XMLModel{
        do {
            return try XMLModel(data: data, options: options)
        } catch {
            preconditionFailure("XMLModel parse data error \(error)")
        }
    }
    
    /// Just the wrapper of `convenience init(xmlString: String, options: ParseOptions = []) throws`,the init method throw error cause crash
    public class func parse(xmlString: String, options: ParseOptions = []) -> XMLModel{
        do {
            return try XMLModel(xmlString: xmlString, options: options)
        } catch  {
            preconditionFailure("XMLModel parse xmlString error \(error)")
        }
    }
    
    /// Just the wrapper of `convenience init(xmlfile name: String, options: ParseOptions = []) throws`,the init method throw error cause crash
    public class func parse(xmlfile name: String, options: ParseOptions = []) -> XMLModel{
        do {
            return try XMLModel(xmlfile: name, options: options)
        } catch {
            preconditionFailure("XMLModel parse xmlfile error \(error)")
        }
    }
}

/// subscript for key and index,Inspired by the Array,subscript no optional value
extension XMLModel{

    public subscript(key: String) -> XMLModel {
        switch rawType{
        case .single:
            let match = rawSingle.childElement.filter{ $0.name == key }
            let copyMatch = match.map{ $0.copy() as! XMLElement }
            copyMatch.forEach{ $0.thorough{ $0.index -= 1 } }
            if copyMatch.count == 1 {
                return XMLModel(rootValue: copyMatch[0])
            }else if copyMatch.count > 1 {
                return XMLModel(rootValue: copyMatch)
            }else{
                preconditionFailure("The key:\(key) didn't match the element name,check out it")
            }
        case .list:
            preconditionFailure("Current xml is list,unsupport key:\(key)")
        default:
            preconditionFailure("There is an error\(error)")
        }
    }

    public subscript(index: Int) -> XMLModel{
        switch rawType{
        case .list:
            if rawlist.count > index{
                return XMLModel(rootValue: rawlist[index])
            }else{
                preconditionFailure("The index:\(index) out of index")
            }
        case .single:
            preconditionFailure("Current xml is not a list,unsupport index:\(index)")
        case .error:
            preconditionFailure("There is an error\(error)")
        }
    }
    
    
}


extension XMLModel{

    public var element: XMLElement{
        switch rawType {
        case .single:
            return rawSingle
        case .list:
            fatalError("")
        case .error:
            fatalError("")
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
            fatalError("")
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








































