//
//  XMLModel_Extension.swift
//  XMLModeler
//
//  Created by 徐伟亭 on 2017/12/25.
//  Copyright © 2017年 TerraNova. All rights reserved.
//

import Foundation


extension XMLModel{
    
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


public protocol XMLModelCodable{
    
    static func decode(xmlModel:XMLModel) -> Self
}



extension String: XMLModelCodable{
    
    public static func decode(xmlModel: XMLModel) -> String {
        return xmlModel.element.text
    }
}

extension Double: XMLModelCodable{
    
    public static func decode(xmlModel: XMLModel) -> Double {
        if let value = Double(xmlModel.element.text) {
            return value
        }else{
            fatalError("")
        }
    }
}

extension Int: XMLModelCodable{
    
    public static func decode(xmlModel: XMLModel) -> Int {
        if let value = Int(xmlModel.element.text) {
            return value
        }else{
            fatalError("Current ")
        }
    }
}

extension Float: XMLModelCodable{
    
    public static func decode(xmlModel: XMLModel) -> Float {
        if let value = Float(xmlModel.element.text) {
            return value
        }else{
            fatalError("")
        }
    }
    
    
}

extension Bool: XMLModelCodable{
    
    public static func decode(xmlModel: XMLModel) -> Bool {
        return Bool(NSString(string: xmlModel.element.text).boolValue)
    }
    
}

extension XMLModel{
    
    func model<T: XMLModelCodable>() -> [T] {
        if rawType == .error { fatalError() }
        switch rawType {
        case .list:
            return rawlist.map{ T.decode(xmlModel: XMLModel(rootValue:$0)) }
        default:
            fatalError()
        }
    }
    
    func model<T: XMLModelCodable>() -> T {
        if rawType == .error { fatalError() }
        switch rawType {
        case .single:
            return T.decode(xmlModel: self)
        default:
            fatalError()
        }
    }
    
    func model<T: XMLModelCodable>() -> T? {
        if rawType == .error { return nil }
        switch rawType {
        case .single:
            return T.decode(xmlModel: self)
        default:
            return nil
        }
    }
    
}




