//
//  ViewController.swift
//  XMLModeler
//
//  Created by GeekXiaowei on 2017/12/11.

import UIKit


class ViewController: UIViewController {
    
    var stack = XMLHelperDelegate.Stack<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        parserTest()
        
    }
    
    func parserTest() {
        
        let helper = try! XMLHelper(xmlfile: "data_5-23id")
        
        let element = helper["root"].element
        element.removeEmptyElements()
        
        print(element.dictionary)
        
    }
    
    
}









