//
//  ViewController.swift
//  XMLModeler
//
//  Created by 徐伟亭 on 2017/12/12.
//  Copyright © 2017年 TerraNova. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let xmlWithNamespace = """
  <root xmlns:h=\"http://www.w3.org/TR/html4/\"
    xmlns:f=\"http://www.w3schools.com/furniture\">
    <h:table>
      <h:tr>
        <h:td>Apples</h:td>
        <h:td>Bananas</h:td>
      </h:tr>
    </h:table>
    <f:table>
      <f:name>African Coffee Table</f:name>
      <f:width>80</f:width>
      <f:length>120</f:length>
    </f:table>
  </root>
"""
        
        
        let url = Bundle.main.url(forResource: "data_5-23id", withExtension: "xml")
        
        
        
        let model = XMLModel(data: try? Data(contentsOf: url!))
        
        print(model)
        

        
        
        
        
        
    }

    

}

