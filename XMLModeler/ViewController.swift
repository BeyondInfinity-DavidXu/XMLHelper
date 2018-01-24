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
        
        _ = try? XMLHelper(xmlfile: "0P0000UIO4")
    }
    
    
}









