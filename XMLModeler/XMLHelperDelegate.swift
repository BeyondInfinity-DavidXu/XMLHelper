//
//  XMLHelperDelegate.swift
//  XMLModeler
//
//  Created by 徐伟亭 on 2018/1/24.
//  Copyright © 2018年 TerraNova. All rights reserved.
//

import Foundation

internal class XMLHelperDelegate: NSObject,XMLParserDelegate {
    
    struct Stack<Element> {
        
        private var items: [Element] = []
        
        /// Push new element into the stack
        mutating func push(_ element: Element) {
            items.append(element)
        }
        
        @discardableResult
        /// Pop the last element out the stack and return the last element if current stack have one
        mutating func pop() -> Element? {
            if items.isEmpty {
                return nil
            }else{
                return items.removeLast()
            }
        }
        
        /// The top element of the stack if the cyrrent stack have one
        var top: Element?{
            get{
                return items.last
            }
            set{
                if let new = newValue {
                    pop()
                    push(new)
                }
            }
        }
        
        /// The count of stack items
        var count: Int{
            return items.count
        }
    }
    
    var elementStack = Stack<XMLElement>()
    
    var parseError: Error?
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        var attributes: [String: XMLElement.Attribute] = [:]
        
        for (key, value) in attributeDict {
            attributes[key] = XMLElement.Attribute(name: key, text: value)
        }
        
        let element = XMLElement(name: elementName,
                                 level: elementStack.count,
                                 attributes: attributes)
        
        elementStack.top?.addChild(element: element)
        
        elementStack.push(element)
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        let text = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if text.isEmpty { return }
        
        elementStack.top?.text += string
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        elementStack.pop()
    
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError
    }
    
}
