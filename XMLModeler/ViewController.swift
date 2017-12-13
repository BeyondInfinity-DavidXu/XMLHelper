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
        
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let url = Bundle.main.url(forResource: "data_5-23id", withExtension: "xml")
        
        let data = try! Data(contentsOf: url!)
        
        let _ = XMLModelerParser().parse(data)
    }


}

