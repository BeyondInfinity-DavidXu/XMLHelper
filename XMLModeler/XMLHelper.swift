//
//  XMLModel.swift
//  XMLModel
//
//  Created by GeekXiaowei on 2017/12/12.

import UIKit


/// The possible errors in the process of parsing xml
public enum XMLHelperError: Error{
    /// placeholder error
    case null
    case invalidXMLSting
    case fileNameError(String)
    case invalidSubscriptKey(String)
    case invalidSubscriptIndex(String)
}

extension XMLHelperError: LocalizedError{
    public var errorDescription: String?{
        switch self {
        case .null:
            return "The XMLModel is null"
        case .invalidXMLSting:
            return "The xml string can't be convert to data using UTF8"
        case .fileNameError(let name):
            return "Can't find the name \"\(name)\" of the file in main bundle"
        case .invalidSubscriptKey(let description):
            return description
        case .invalidSubscriptIndex(let description):
            return description
        }
    }
}

/// `XMLModel` represent the xml data,
/// The xml data possible an single XMLElement include some children elements,
/// or a list of XMLElement at the same level.
/// `XMLModel` also responsible for parsing XML data, xml string and xml file
public class XMLHelper {

    private enum RawType {
        case list,single,error
    }

    private var rawType: RawType = .error
    private var rawlist:[XMLElement] = []
    private var rawSingle:XMLElement = XMLElement(name: "")
    private var error: XMLHelperError = .null

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
            case let error as XMLHelperError:
                rawType = .error
                self.error = error
            default:
                rawType = .error
                error = XMLHelperError.null
            }
        }
    }
    
    private init(rootValue: Any) {
        self.rootValue = rootValue
    }
    
    static let root_name = "xml_helper_root"
    
    /**
     The core init method,Passing data for parse and config options,can throw errors
     
     - parameter data: the xml data for parse
     
     - parameter options: the xml parsing options
     
     - returns : an XMLModel object or throw a error
     */
    public init(data: Data, options: ParseOptions = []) throws {
        
        let delegate = XMLHelperDelegate()
        
        let root = XMLElement(name: XMLHelper.root_name)
        
        delegate.elementStack.push(root)
        
        let parser = XMLParser(data: data)
        
        parser.delegate = delegate
        
        if options.contains(ParseOptions.shouldProcessNamespaces) {
            parser.shouldProcessNamespaces = true
        }
        
        parser.parse()
        
        if let error = delegate.parseError {
            throw error
        }else{
            self.rootValue = root
        }
    }
}

extension XMLHelper: CustomStringConvertible {
    
    public var description: String{
        switch rawType {
        case .single:
            return self.rawSingle.description
        case .list:
            var string = [String]()
            rawlist.forEach{ string.append($0.description) }
            return string.joined(separator: "\n")
        case .error:
            return error.errorDescription ?? "The error no description"
        }
    }
}



extension XMLHelper {

    /// Some xml parse options
    public struct ParseOptions: OptionSet{
        public let rawValue: UInt
        public init(rawValue: UInt){ self.rawValue = rawValue }
        /// This option can process the xml name spaces
        public static let shouldProcessNamespaces = ParseOptions(rawValue: 0)
        /// Convert the xml to json,you can read the json
        public static let shouldConvertToJson = ParseOptions(rawValue: 1)
    }

    /**
     The convenience init method,for parse xml string with options,can throw errors
     
     - parameter xmlString: the xml string for parse,the string will be convert to data using UTF8
     
     - parameter options: the xml parsing options
     
     - returns : an XMLModel object or throw a error
     */
    public convenience init(xmlString: String, options: ParseOptions = []) throws {
        guard let data = xmlString.data(using: .utf8) else {
            throw XMLHelperError.invalidXMLSting
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
        guard !name.isEmpty else { preconditionFailure("The name is an empty string ") }
        guard let url = Bundle.main.url(forResource: name, withExtension: "xml") else {
            throw XMLHelperError.fileNameError(name)
        }
        let data = try Data(contentsOf: url)
        try self.init(data: data, options: options)
    }
    
    /// Just the wrapper of `init(data: Data, options: ParseOptions = []) throws`,the init method throw error cause crash
    public class func parse(data: Data, options: ParseOptions = []) -> XMLHelper{
        do {
            return try XMLHelper(data: data, options: options)
        } catch {
            preconditionFailure("XMLModel parse data error \(error)")
        }
    }
    
    /// Just the wrapper of `convenience init(xmlString: String, options: ParseOptions = []) throws`,the init method throw error cause crash
    public class func parse(xmlString: String, options: ParseOptions = []) -> XMLHelper{
        do {
            return try XMLHelper(xmlString: xmlString, options: options)
        } catch  {
            preconditionFailure("XMLModel parse xmlString error \(error)")
        }
    }
    
    /// Just the wrapper of `convenience init(xmlfile name: String, options: ParseOptions = []) throws`,the init method throw error cause crash
    public class func parse(xmlfile name: String, options: ParseOptions = []) -> XMLHelper{
        do {
            return try XMLHelper(xmlfile: name, options: options)
        } catch {
            preconditionFailure("XMLModel parse xmlfile error \(error)")
        }
    }
}


extension XMLHelper{

    public subscript(key: String) -> XMLHelper {
        
        func makeError(description: String) -> XMLHelper {
            let error = XMLHelperError.invalidSubscriptKey(description)
            return XMLHelper(rootValue: error)
        }
        
        switch rawType{
        case .single:
            let match = rawSingle.childElements.filter{ $0.name == key }
            let copyMatch = match.map{ $0.copy }
            copyMatch.forEach{ $0.thorough{ $0.level -= 1 } }
            if copyMatch.count == 1 {
                return XMLHelper(rootValue: copyMatch[0])
            }else if copyMatch.count > 1 {
                return XMLHelper(rootValue: copyMatch)
            }else{
                let description = "The key: \"\(key)\" didn't match the element name,check out it"
                return makeError(description: description)
            }
        case .list:
            let description = "Current xml is list,unsupport key:\(key)"
            return makeError(description: description)
        default:
            let description = "There is an error\(error)"
            return makeError(description: description)
        }
    }
    
    
    public subscript(index: Int) -> XMLHelper{
        
        func makeError(description: String) -> XMLHelper {
            let error = XMLHelperError.invalidSubscriptIndex(description)
            return XMLHelper(rootValue: error)
        }
        
        switch rawType{
        case .list:
            if rawlist.count > index{
                return XMLHelper(rootValue: rawlist[index])
            }else{
                let description = "The index:\(index) out of index"
                return makeError(description: description)
            }
        case .single:
            let description = "Current xml is not a list,unsupport index:\(index)"
            return makeError(description: description)
        case .error:
            let description = "Current XMLModel is an error\(error)"
            return makeError(description: description)
        }
    }
    
}


extension XMLHelper{
    
    /// The element of the current level,none optional value
    public var element: XMLElement{
        switch rawType {
        case .single:
            return rawSingle
        case .list:
            fatalError("Current XMLModel a list of XMLElements ,no element value")
        case .error:
            fatalError("XMLModel is an error")
        }
    }
    
    /// The element of the current level,optional value
    public var elementValue: XMLElement?{
        switch rawType {
        case .single:
            return rawSingle
        default:
            return nil
        }
    }
}



