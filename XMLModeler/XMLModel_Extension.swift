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

/**
 
 */
extension String: XMLModelCodable{
    
    public static func decode(xmlModel: XMLModel) -> String {
        return xmlModel.element.text
    }
}






